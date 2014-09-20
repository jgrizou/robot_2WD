clear all
init

%%
robot = TwoWheelRobot();
robot.set_state(-1.5, -1.5, 0);
robot.set_nominal_drive(20);
robot.set_curve(0);

updateTime = 0.1;
%%
disp('Ready, waiting for connection...')
[~, port] = get_robot_tcp_info();
tcp = StringTCP('0.0.0.0', port, 'NetworkRole', 'server', 'TimeOut', inf);
tcp.flush()
tcp.open()

%% wait while object not generated
disp('Wait for robot planner...')
while ~exist(get_objects_filename(), 'file')
    pause(0.1)
end
% this load 'objectPositions', 'objectAvoidanceRadius', 'objectRadius'
load(get_objects_filename)

%% events setup
nextEventRange = 50;
nextEventMin = 10;

%generate artificial teaching signals
[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
path = fullfile(pathstr, 'datasets/move_finger.mat');
load(path)
teacherDispatcher = Dispatcher(X, Y, true);
teacherFrame = Object_direction_absolute_frame();

nHypothesis = size(objectPositions, 1);
teacherHypothesis = randi(nHypothesis);
goalObjectPosition = objectPositions(teacherHypothesis, :);

%%
cnt = 0;
nextEvent = randi(nextEventRange) + nextEventMin;
while 1
    disp('###')
    disp(['Teacher object is number ', num2str(teacherHypothesis)])
    cnt = cnt + 1;
    %%
    disp('Sending robot state...')
    [x, y, theta] = robot.get_state();
    robotStateStr = form_robot_state_str(x, y, theta);
    tcp.send(robotStateStr)
    
    %%
    disp('Waiting for curve...')
    robot.set_curve(str2num(tcp.receive()))   
    robot.update_state(updateTime)
    
    %% if cnt>nextEvent send an event
    disp(['New event in ', num2str(nextEvent - cnt) ,' steps'])
    if cnt > nextEvent
        disp('$$$$$')
        disp('Creating event!')
        disp('$$$$$')
        teacherPLabel = teacherFrame.compute_labels(goalObjectPosition, [x, y]);
        teacherLabel = sample_action_discrete_policy(teacherPLabel);
        teacherSignal = teacherDispatcher.get_sample(teacherLabel);
        create_event([x,y,theta], teacherSignal)
        
        %reset next event
        cnt = 0;
        nextEvent = randi(nextEventRange) + nextEventMin;
    end
    
end





