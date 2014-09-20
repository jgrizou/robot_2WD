classdef Planner < handle
    %PLANNER
    
    properties
        
        orientations = [];
        actions = {};
        
        xLim = []
        yLim = []
        step = []
        
        nStepX = 0
        nStepY = 0
        nOrientations = 0
        nActions = 0
        
        forbidden_trajectory = [];
        
        %MDP side
        %the following variable must keep the same name to be used with
        %Value Iteration Solver
        Gamma = 0.95 % Discount factor - for Value Iteration (VI) solver
        nS % Number of state
        nA % Number of action
        P % Transisiton matrix
        R % Reward
        
    end
    
    methods
        
        function self = Planner(xLim, yLim, step, orientations, actions)
            self.xLim = xLim;
            self.yLim = yLim;
            self.step = step;
            
            if nargin > 3
                self.orientations = orientations;
            else
                self.orientations = mod([0, pi/2, pi, 3*pi/2], 2*pi);
            end
            if nargin > 4
                self.actions = actions;
            else
                self.actions = {PlannerAction.CircleQuarter(step, false), ...
                    PlannerAction.CircleQuarter(2*step, false), ...
                    PlannerAction.Straight(step), ...
                    PlannerAction.CircleQuarter(2*step, true), ...
                    PlannerAction.CircleQuarter(step, true)};
            end
            
            self.nStepX = round(diff(self.yLim)/self.step) + 1;
            self.nStepY = round(diff(self.yLim)/self.step) + 1;
            self.nOrientations = length(self.orientations);
            self.nActions = length(self.actions);
        end
        %%
        function isValid = isValid_from_internal_feature(self, iX, iY, observationId, actionId)
            isValid = 1;
            if iX < 1 || iX > self.nStepX
                isValid = 0;
            end
            if iY < 1 || iY > self.nStepY
                isValid = 0;
            end
            if observationId < 1 || observationId > self.nOrientations
                isValid = 0;
            end
            if actionId < 1 || actionId > self.nActions
                isValid = 0;
            end
        end
        
        function maxState = get_max_state(self)
            maxState = self.get_state_from_internal_feature(self.nStepX,self.nStepY, self.nOrientations);
        end
        
        function state = get_state_from_internal_feature(self, iX, iY, orientationId)
            if ~self.isValid_from_internal_feature(iX, iY, orientationId, 1)
                error('input not valid')
            end
            state = round(iX + self.nStepX * (iY-1) + self.nStepX*self.nStepY*(orientationId-1));
        end
        
        function [iX, iY, orientationId] = get_internal_feature_from_state(self, state)
            orientationId = floor((state-1) / (self.nStepX*self.nStepY));
            tmp = state - orientationId*self.nStepX*self.nStepY;
            iY = floor((tmp-1) / self.nStepX);
            iX = tmp - iY*self.nStepX;
            
            orientationId = orientationId + 1;
            iY = iY + 1;
        end
        
        function state = get_state_from_external_feature(self, X, Y, orientationId)
            [iX, iY] = self.project_in_node_space(X, Y);
            if ~self.isValid_from_internal_feature(iX, iY, orientationId, 1)
                error('input not valid')
            end
            state = round(iX + self.nStepX * (iY-1) + self.nStepX*self.nStepY*(orientationId-1));
        end
        
        %%
        function segment = get_segment_internal_feature(self, iX, iY, orientationId, actionId)
            [X, Y] = reconstruct_from_node_space(self, iX, iY);
            theta = self.orientations(orientationId);
            segment = self.actions{actionId}.get_segment(X, Y, theta);
        end
        
        function segment = get_segment_state_action(self, state, action)
            [iX, iY, orientationId] = get_internal_feature_from_state(self, state);
            segment = get_segment_internal_feature(self, iX, iY, orientationId, action);
        end
        
        function [newiX, newiY, newobservationId] = get_action_outcome_internal_feature(self, iX, iY, observationId, actionId)
            [X, Y] = self.reconstruct_from_node_space(iX, iY);
            theta = self.orientations(observationId);
            [newX, newY, newTheta] = self.actions{actionId}.get_outcome(X, Y, theta);
            [newiX, newiY] = project_in_node_space(self, newX, newY);
            newobservationId = find(newTheta == self.orientations);
            if isempty(newobservationId)
                newobservationId = 0;
            end
        end
        
        %%
        function set_forbidden_trajectory(self, trajectory)
            self.forbidden_trajectory = trajectory;
        end
        
        function build_MDP(self)
            self.nS = self.get_max_state();
            self.nA = self.nActions;
            self.P = cell(1, self.nA);
            for iA = 1:self.nA
                self.P{iA} = zeros(self.nS, self.nS);
                for iS = 1:self.nS
                    disp(['Solving for action ', num2str(iA), '/', num2str(self.nA)])
                    disp(['Solving for state ', num2str(iS), '/', num2str(self.nS)])
                    [iX, iY, iO] = self.get_internal_feature_from_state(iS);
                    [newiX, newiY, newiO] = self.get_action_outcome_internal_feature(iX, iY, iO, iA);
                    if self.isValid_from_internal_feature(newiX, newiY, newiO, 1)
                        valid = 1;
                        if ~isempty(self.forbidden_trajectory)
                            trajStateAction = Trajectory(self.get_segment_state_action(iS, iA));
                            [x0, ~] = Trajectory.intersections(trajStateAction, self.forbidden_trajectory, 8);
                            if ~isempty(x0)
                                valid = 0;
                            end
                        end
                        if valid
                            startState = self.get_state_from_internal_feature(iX, iY, iO);
                            endState = self.get_state_from_internal_feature(newiX, newiY, newiO);
                            self.P{iA}(startState, endState) = 1;
                        end
                    end
                end
            end
            disp('Removing dead states')
            self.remove_dead_state_access()
        end
        
        function set_reward_at_state(self, state, reward)
            self.R = zeros(self.nS, 1);
            %no reward in dead state
            for iS = 1:length(state)
                if self.is_state_dead(state(iS)) || ~self.is_state_reachable(state(iS))
                    warning('set_reward_at_state:deadstate', 'tried to set reward in dead state')
                else
                    self.R(state) = reward;
                end
            end
        end
        
        function deadStates = find_dead_states(self)
            tmp = zeros(self.nS, self.nA);
            for iA = 1:self.nA
                tmp(:, iA) = sum(self.P{iA}, 2);
            end
            deadStates = find(sum(tmp,2) == 0);
        end
        
        function isDead = is_state_dead(self, state)
            isDead = 0;
            deadStates = self.find_dead_states();
            if any(deadStates == state)
                isDead = 1;
            end
        end
        
        function remove_dead_state_access(self)
            deadStates = self.find_dead_states();
            for iA = 1:self.nA
                self.P{iA}(:, deadStates) = 0;
            end
        end
        
        function isUsable = is_state_action_usable(self, state, action)
            isUsable = 1;
            if sum(self.P{action}(state, :)) == 0
                isUsable = 0;
            end
        end
        
        function isUsable = is_state_usable(self, state)
            usable = zeros(1, self.nA);
            for iA = 1:self.nA
                usable(iA) = self.is_state_action_usable(state, iA);
            end
            isUsable = any(usable);
        end
        
        function isReachable = is_state_reachable(self, state)
            reachable = zeros(1, self.nA);
            for iA = 1:self.nA
                reachable(iA) = sum(self.P{iA}(:, state)) > 0;
            end
            isReachable = any(reachable);
        end
        
        function [Q, P] = solve_MDP(self, maxerr)
            if nargin < 2
                maxerr = 1e-3;
            end
            [Q, P] = VI(self, maxerr);
        end
        
        %%
        function [iX, iY] = project_in_node_space(self, X, Y)
            iX = (X - self.xLim(1))/self.step + 1;
            iY = (Y -self.yLim(1))/self.step + 1;
        end
        
        function [X, Y] = reconstruct_from_node_space(self, iX, iY)
            X = self.xLim(1) + (iX-1) * self.step;
            Y = self.yLim(1) + (iY-1) * self.step;
        end
        
        %%
        function [X, Y] = get_node_position(self)
            nodeX = [];
            nodeY = [];
            for iX = 1:self.nStepX
                for iY = 1:self.nStepY
                    nodeX = [nodeX; iX];
                    nodeY = [nodeY; iY];
                end
            end
            [X, Y] = self.reconstruct_from_node_space(nodeX, nodeY);
        end
        
        function plot_nodes(self, varargin)
            [X, Y] = self.get_node_position();
            scatter(X, Y, varargin{:});
        end
        
        function plot_segment(self, state, action, varargin)
            segment = self.get_segment_state_action(state, action);
            segment.plot(100, varargin{:});
        end
        
        function plot_state(self, state, varargin)
            [iX, iY, orientationId] = self.get_internal_feature_from_state(state);
            [X, Y] = self.reconstruct_from_node_space(iX, iY);
            theta = self.orientations(orientationId);
            U = cos(theta) * self.step/2;
            V = sin(theta) * self.step/2;
            quiver(X, Y, U, V, varargin{:})
            
        end
        
    end
    
end

