warning('off', 'ensure_positive_semidefinite:NegativeEigenvalues')
warning('off', 'ensure_symmetry:ComplexInfNaN')
warning('off', 'process_options:argUnused')
warning('off', 'cross_validation:NotEnoughData')

% We choose to use a Logger as a kind of workspace to store and retrieve usefull variable
% It also allow to easilly creates history of data and retrieve then as easilly
% You may get confuse at first but compare this file with the
% demo_no_recorder to see the benefit of it
% rec is the only short name variable that you should see and stand for
% recorder, a Logger instance.
rec = Logger();

%% shuffle random seed according to current time
seed = init_random_seed(); % init seed with current time
rec.log_field('randomSeed', seed);

%% wait while object not generated
disp('Wait for robot planner...')
while ~exist(get_objects_filename(), 'file')
    pause(0.1)
end
% this load 'objectPositions', 'objectAvoidanceRadius', 'objectRadius'
load(get_objects_filename)

rec.logit(objectPositions)
rec.logit(objectAvoidanceRadius)
rec.logit(objectRadius)

%% wait while robot planner not generated
disp('Wait for robot planner...')
while ~exist(get_robot_planner_filename(), 'file')
    pause(0.1)
end
% this load the robot planner as robotPlanner
load(get_robot_planner_filename())
% the MDP shoudl be prebuilt with forbidden area included
rec.logit(robotPlanner)

%%
rec.log_field('nHypothesis', size(rec.objectPositions, 1));
hypothesisRecordNames = cell(1, rec.nHypothesis);
for iHyp = 1:rec.nHypothesis
    hypothesisRecordNames{iHyp} = ['plabelHyp', num2str(iHyp)];
end
rec.logit(hypothesisRecordNames)


%% Learner side
% choose which frames of interaction the learner uses
rec.log_field('learnerFrame', Object_direction_absolute_frame(0.05))

% choose classifier to use
rec.log_field('blankClassifier', @() GaussianUninformativePrior_classifier('diag', 1e-6));

%% Setup experiment
% I declare those variable this way to be sure to not use it from the workspace
% Otherwise an other method would be
% nSteps = 100; rec.logit(nSteps)

rec.log_field('nInitSteps', 15) %minPointNeeded

actionSelectionInfo = struct;
actionSelectionInfo.method = 'uncertainty';
actionSelectionInfo.initMethod = 'random';
actionSelectionInfo.confidentMethod = 'greedy';
actionSelectionInfo.epsilon = 0;
actionSelectionInfo.nStepBetweenUpdate = 1;
rec.log_field('actionSelectionInfo', actionSelectionInfo)

rec.log_field('uncertaintyMethod', 'signal_sample')
rec.log_field('nSampleUncertaintyPlanning', 20)

rec.log_field('nCrossValidation', 10)

rec.log_field('confidenceLevel', 0.99)

methodInfo = struct;
methodInfo.classifierMethod = 'online';
methodInfo.samplingMethod = 'one_shot';
methodInfo.estimateMethod = 'matching';
methodInfo.cumulMethod = 'filter';
methodInfo.probaMethod = 'pairwise';
rec.log_field('methodInfo', methodInfo)

%% init policy
set_robot_random_policy()

%%
% choose which object is the one taught by the teacher
isConfident = false;
iStep = 0;
while 1
    %% start loop
    stepTime = tic;
    iStep = iStep + 1;
    disp('####')
    fprintf('Step %4d\n',iStep);
    rec.logit(iStep)
    
    %% wait for events
    disp('Wait for events...')
    while isempty(getfilenames(get_events_folder(), 'refiles', '*.mat'))
        pause(0.1)
    end
    eventsFile = getfilenames(get_events_folder(), 'refiles', '*.mat');
    % treat only one event each time
    %this load robotState ([x, y, theta]) and teacherSignal
    load(eventsFile{1})
    rec.log_field('robotState', robotState)
    rec.log_field('robotPosition', [robotState(1), robotState(2)])
    rec.log_field('teacherSignal', teacherSignal)
    %remove file to not use it twice
    delete(eventsFile{1})
    
    %% compute hypothetic plabels
    hypothesisPLabel = arrayfun(@(iHyp) rec.learnerFrame.compute_labels(rec.objectPositions(iHyp, :), rec.robotPosition(end,:)), 1:rec.nHypothesis, 'UniformOutput', false);
    rec.log_multiple_fields(rec.hypothesisRecordNames, hypothesisPLabel)
    
    %% compute hypothesis probabilities
    disp('Updating proba...')
    recorder_compute_proba(rec, rec.methodInfo)
    
    %% detect confidence
    [isConfident, bestHypothesis] = recorder_check_confidence(rec, rec.methodInfo);
    rec.logit(isConfident)
    rec.logit(bestHypothesis)
    
    if isConfident
        % send message to robot
        break
        % reset the learning process
        recorder_reset_proba(rec, bestHypothesis, rec.methodInfo)
    end
    
    %% compute uncertainty and update policy
    if isempty(getfilenames(get_events_folder(), 'refiles', '*.mat'))
        if strcmp(rec.actionSelectionInfo.method, 'uncertainty')
            if length(rec.iStep) > rec.nInitSteps
                
                disp('Computing uncertainty...')
                uncertaintyValues = compute_uncertainty_per_node(rec, rec.uncertaintyMethod, rec.methodInfo);
                
                %
                [X, Y] = robotPlanner.planner.get_node_position();
                state = 1:robotPlanner.planner.nS;
                reward = zeros(robotPlanner.planner.nS, 1);
                
                %go at max uncertainty
                [~, idx] = max(uncertaintyValues);
                while ~is_node_valid(robotPlanner.planner, X(idx), Y(idx))
                    uncertaintyValues(idx) = 0;
                    if all(uncertaintyValues == zeros(length(X), 1))
                        break
                    else
                        [~, idx] = max(uncertaintyValues);
                    end
                end
                uncertaintyValues = zeros(length(X), 1);
                uncertaintyValues(idx) = 1;
                
                %compute full map
                atLeastOneValidState = 0;
                for iOr = 1:robotPlanner.planner.nOrientations
                    for i = 1:length(X)
                        iState = robotPlanner.planner.get_state_from_external_feature(X(i), Y(i), iOr);
                        reward(iState) = uncertaintyValues(i);
                        if reward(iState) > 0
                            if ~robotPlanner.planner.is_state_dead(iState) && robotPlanner.planner.is_state_reachable(iState)
                                atLeastOneValidState = 1;
                            end
                        end
                    end
                end
                
                %
                disp('Updating policy...')
                if atLeastOneValidState
                    warning('off', 'set_reward_at_state:deadstate')
                    update_robot_policy(state, reward)
                else
                    uncertaintyValues = zeros(length(X), 1);
                    set_robot_random_policy()
                end
                
            else
                [X, Y] = robotPlanner.planner.get_node_position();
                uncertaintyValues = zeros(length(X), 1);
            end
        end
    else
        if ~exist('uncertaintyValues', 'var')
            [X, Y] = robotPlanner.planner.get_node_position();
            uncertaintyValues = zeros(length(X), 1);
        end
    end
    
    %% plot
    clf
    subplot(2,2,[1,3])
    filestr = generate_method_filestr(rec.methodInfo);
    plot(rec.(['probabilities_', filestr]))
    xlim([0, length(rec.iStep)+1])
    ylim([-0.05, 1.05])
    
    subplot(2,2,2)
    robotPlanner.planner.plot_nodes(100, uncertaintyValues, 'filled')
    minX = robotPlanner.planner.xLim(1) - robotPlanner.planner.step/2;
    maxX = robotPlanner.planner.xLim(2) + robotPlanner.planner.step/2;
    minY = robotPlanner.planner.yLim(1) - robotPlanner.planner.step/2;
    maxY = robotPlanner.planner.yLim(2) + robotPlanner.planner.step/2;
    xlim([minX, maxX])
    ylim([minY, maxY])
    daspect([1,1,1])
    
    subplot(2,2,4)
    plot_all_objects(rec.(['probabilities_', filestr])(end,:))
    xlim([minX, maxX])
    ylim([minY, maxY])
    daspect([1,1,1])
    
    drawnow
    
    %% end loop
    rec.log_field('stepTime', toc(stepTime))
end

[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
folder = fullfile(pathstr, 'results');
if ~exist(folder, 'dir')
    mkdir(folder)
end
recFilename = generate_timestamped_filename(folder, 'mat');
rec.save(recFilename)


