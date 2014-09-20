classdef RobotPlanner < handle
    %ROBOTPLANNER
    
    properties
        
        robot
        planner
        trajectoryToAvoid = Trajectory()
        
        currentState
        currentAction
        currentSegment
        
        nextState
        nextAction
        nextSegment
        
        trajectory
        policy
        
        
        
    end
    
    methods
        
        function self = RobotPlanner(planner)
            self.planner = planner;
        end
        
        function add_forbidden_area(self, center, radius)
            r = self.planner.step/3:self.planner.step/3:radius;
            for i = 1:length(r)
                s = Segment.circle(center, r(i), 0, 2*pi);
                self.trajectoryToAvoid.addSegment(s)
            end
            
            matRot = @(theta) [cos(theta), sin(theta); -sin(theta), cos(theta)];
            
            theta = 0:pi/8:2*pi;
            for i = 1:length(theta)
                start = [-radius, 0] * matRot(theta(i)) + center;
                finish = [radius, 0] * matRot(theta(i)) + center;
                s = Segment.line(start, finish);
                self.trajectoryToAvoid.addSegment(s)
            end
            
            self.planner.set_forbidden_trajectory(self.trajectoryToAvoid)
        end
        
        function build_MDP(self)
            self.planner.build_MDP();
        end
        
        function state = find_state(self, robotX, robotY, robotTheta)
            [iX, iY] = self.planner.project_in_node_space(robotX, robotY);
            iX = round(iX);
            iY = round(iY);
            [~, iO] = min(abs(mod(robotTheta, 2*pi) - self.planner.orientations));
            state = self.planner.get_state_from_internal_feature(iX, iY, iO);
        end
        
        function init_robot_position(self, robotX, robotY, robotTheta)
            self.currentState = self.find_state(robotX, robotY, robotTheta);
            self.currentAction = greedy_action_discrete_policy(self.policy, self.currentState);
            self.currentSegment = self.planner.get_segment_state_action(self.currentState, self.currentAction);
            
            self.nextState = greedy_action_discrete_policy(self.planner.P{self.currentAction}, self.currentState);
            self.nextAction = greedy_action_discrete_policy(self.policy, self.nextState);
            self.nextSegment = self.planner.get_segment_state_action(self.nextState, self.nextAction);
            
            self.trajectory = Trajectory(self.currentSegment, self.nextSegment);
            
        end
        
        function update_trajectory(self, sensorTraj)
            
            [x, ~] = Trajectory.intersections(Trajectory(self.currentSegment), sensorTraj);
            if isempty(x)
                self.currentState = self.nextState;
                self.currentAction = self.nextAction;
                self.currentSegment = self.nextSegment;
                
                self.nextState = greedy_action_discrete_policy(self.planner.P{self.currentAction}, self.currentState);
                self.nextAction = greedy_action_discrete_policy(self.policy, self.nextState);
                self.nextSegment = self.planner.get_segment_state_action(self.nextState, self.nextAction);
                
                self.trajectory = Trajectory(self.currentSegment, self.nextSegment);
            end
        end
        
        function update_reward(self, state, reward)
            self.planner.set_reward_at_state(state, reward);
        end
        
        function update_policy(self, maxerr)
            if nargin < 2
                maxerr = 1e-3;
            end
            [~, self.policy] = self.planner.solve_MDP(maxerr);
        end
        
        function set_policy(self, newPolicy)
            self.policy = newPolicy;
        end
        
    end
end

