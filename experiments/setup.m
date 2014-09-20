clear all

planner = Planner([-1.5,1.5], [-1.5,1.5], 0.25);

%%
objectPositions = [ -0.5, -0.5; ...
                    -0.5, 0.5; ...
                    0.5, 0.5; ...
                    0.5, -0.5];
nObjects = size(objectPositions, 1);
objectAvoidanceRadius = 0.2;
objectRadius = 0.1;
save(get_objects_filename, 'objectPositions', 'objectAvoidanceRadius', 'objectRadius')


%% compute robotPlanner
warning('off', 'MATLAB:nearlySingularMatrix')
robotPlanner = RobotPlanner(planner);
for iObject = 1:nObjects
    robotPlanner.add_forbidden_area(objectPositions(iObject, :), objectAvoidanceRadius);
end
robotPlanner.build_MDP();
save(get_robot_planner_filename(), 'robotPlanner')

%% compute random policy
[X, Y] = robotPlanner.planner.get_node_position();
uncertaintyValues = ones(length(X), 1);

state = 1:robotPlanner.planner.nS;
reward = zeros(robotPlanner.planner.nS, 1);
for iOr = 1:robotPlanner.planner.nOrientations
    for i = 1:length(X)
        iState = robotPlanner.planner.get_state_from_external_feature(X(i), Y(i), iOr);
        reward(iState) = uncertaintyValues(i);
    end
end
warning('off', 'set_reward_at_state:deadstate')
robotPlanner.update_reward(state, reward);
robotPlanner.update_policy();

robotRandomPolicy = robotPlanner.policy;
save(get_robot_random_policy_filename(), 'robotRandomPolicy')


