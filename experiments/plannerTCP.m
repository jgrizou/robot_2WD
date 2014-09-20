clear all
init
warning('off', 'MATLAB:nearlySingularMatrix')

%% wait while robot planner not generated
disp('Wait for robot planner...')
while ~exist(get_robot_planner_filename(), 'file')
    pause(0.1)
end
% this load the robot planner as robotPlanner
load(get_robot_planner_filename())
% the MDP shoudl be prebuilt with forbidden area included

%% wait while policy not generated
disp('Wait for robot policy...')
while ~exist(get_robot_policy_filename(), 'file')
    pause(0.1)
end
% this load the new policy as robotPolicy
load(get_robot_policy_filename())
%set policy
robotPlanner.set_policy(robotPolicy)
%we remove the file to see next update
delete(get_robot_policy_filename())

%% init TCP communication
%the robot server should be ready
disp('Connect to robot side...')
[host, port] = get_robot_tcp_info();
tcp = StringTCP(host, port, 'NetworkRole', 'client', 'TimeOut', inf);
tcp.flush()
tcp.open()

%the server immediately sends back the initial robot position
disp('Waiting for robot state...')
robotState = eval(tcp.receive());
robotPlanner.init_robot_position(robotState(1), robotState(2), robotState(3));

%% create the simulated robot
robot = TwoWheelRobot();
robot.set_state(robotState(1), robotState(2), robotState(3));

%% start planning
rec = Logger();
while true
    disp('###')
    
    %% send first orders to robot
    disp('Sending curve to robot...')
    trajRobot = robot.get_ground_sensor_trajectory();
    robotPlanner.update_trajectory(trajRobot)
    robot.follow(robotPlanner.trajectory)
    tcp.send(num2str(robot.curve))
    
    %% now we wait for the robot to send back its new state
    % the server side manage the timing
    % in the mean time we plot and check for policy update
    
    %log
    rec.log_field('robotX', robot.x)
    rec.log_field('robotY', robot.y)
    rec.log_field('robotTheta', robot.theta)
    rec.log_field('robotCurve', robot.curve)
    
    % check for policy update
    if exist(get_robot_policy_filename(), 'file')
        disp('$$$$$')
        disp('Updating policy...')
        % this load the new policy as robotPolicy
        load(get_robot_policy_filename())
        %set policy
        robotPlanner.set_policy(robotPolicy)
        %we remove the file to see next update
        delete(get_robot_policy_filename())
        disp('$$$$$')
    end
    
    % plot
    clf
    robot.plot()
    robotPlanner.trajectory.plot(100, 'k')
    trajRobot.plot(100, 'g')
    
    [x0,y0] = Trajectory.intersections(robotPlanner.trajectory, trajRobot);
    plot(x0, y0, 'r*')
    
    robotPlanner.planner.plot_nodes(50, 'k', 'filled')
    robotPlanner.planner.forbidden_trajectory.plot(100, 'k')
    
    minX = robotPlanner.planner.xLim(1) - robotPlanner.planner.step/2;
    maxX = robotPlanner.planner.xLim(2) + robotPlanner.planner.step/2;
    minY = robotPlanner.planner.yLim(1) - robotPlanner.planner.step/2;
    maxY = robotPlanner.planner.yLim(2) + robotPlanner.planner.step/2;
    
    xlim([minX, maxX])
    ylim([minY, maxY])
    daspect([1,1,1])
    drawnow

    
    %% wait and apply new robot state
    disp('Waiting for robot state...')
    robotState = eval(tcp.receive());
    robot.set_state(robotState(1), robotState(2), robotState(3));
    
end

%% save



