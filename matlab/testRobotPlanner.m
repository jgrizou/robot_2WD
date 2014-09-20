clear all
init

warning('off', 'MATLAB:nearlySingularMatrix')

pl = Planner([-1.5,1.5], [-1.5,1.5], 0.25);
rpl = RobotPlanner(pl);
rpl.add_forbidden_area([0, 0], 0.25);
rpl.build_MDP();

%%
rpl.update_reward(70, 1);
rpl.update_policy();

%%
robot = TwoWheelRobot();
robot.set_state(-1.5, -1.5, 0);
robot.set_nominal_drive(30);

rpl.init_robot_position(robot.x, robot.y, robot.theta)

%%
rpl.update_trajectory(robot.get_ground_sensor_trajectory)

updateTime = 0.1;
posRobot = [];

cnt = 0;
while true
    tstart = tic;
    cnt = cnt + 1;
    rpl.update_trajectory(robot.get_ground_sensor_trajectory)
    robot.follow(rpl.trajectory)
    robot.update_state(updateTime)
    
    trajRobot = robot.get_ground_sensor_trajectory();
    [x0,y0] = Trajectory.intersections(rpl.trajectory, trajRobot);
    
    posRobot = [posRobot; [robot.x, robot.y]];
    if length(posRobot) > 150
       posRobot(1, :) = []; 
    end
    
    clf
    robot.plot()
    rpl.trajectory.plot(100, 'k')
    trajRobot.plot(100, 'g')
    plot(x0, y0, 'r*')
    plot(posRobot(:,1), posRobot(:,2), 'r--')
    
    rpl.planner.plot_nodes(50, 'k', 'filled')
    rpl.planner.forbidden_trajectory.plot(100, 'k')
    
    xlim([-2,2])
    ylim([-2,2])
    drawnow

    
    if cnt > 50
        state = randi(rpl.planner.nS);
        while ~rpl.planner.is_state_usable(state) || ~rpl.planner.is_state_reachable(state)
            state = randi(rpl.planner.nS);
        end
        rpl.update_reward(state, 1);
        tSolve = tic;
        rpl.update_policy(1e-2);
        toc(tSolve)
        cnt = 0;
    end
    
    pause(updateTime - toc(tstart))
end

%%
% clf
% hold on
% rpl.planner.plot_nodes(50, 'k', 'filled')
% rpl.planner.forbidden_trajectory.plot(100, 'k')
% for iS = 1:rpl.planner.nS
%     for iA = 1:rpl.planner.nA
%         if rpl.planner.is_state_action_usable(iS, iA)
%             if rpl.planner.is_state_action_usable(iS, iA)
%                 rpl.planner.plot_segment(iS, iA)
%             end
%         end
%     end
% end
% 
% xlim([-2, 2])
% ylim([-2, 2])