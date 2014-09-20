classdef TwoWheelRobot < handle
    %2WD_ROBOT
    
    properties
        
        robotRadius = 0.127/2; % in m
        wheelRadius = 0.021; % in m, 21 mm
        wheelGap = 0.089; % in m, 89 mm
        
        groundSensorShift = [0.127/2, 0]; % [x,y] in m
        groundSensorRot = 0; % in rad
        groundSensorSpan = 0.127*2; % in m
        
        followGain = 100;
        
        x = 0; %in m
        y = 0; %in m
        theta = 0; %in radian
        
        nominalDrive = 0;
        curve = 0;
        driveLeft = 0; % in RPM
        driveRight = 0; % in RPM
        
        dt = 1e-2; % simulation time
        
    end
    
    methods
        
        function self = TwoWheelRobot(robotRadius, wheelRadius, wheelGap, dt)
            if nargin > 0
                self.robotRadius = robotRadius;
            end
            if nargin > 1
                self.wheelRadius = wheelRadius;
            end
            if nargin > 2
                self.wheelGap = wheelGap;
            end
            if nargin > 3
                self.dt = dt;
            end
        end
        
        function set_state(self, x, y, theta)
            self.x = x;
            self.y = y;
            self.theta = theta;
        end
        
        function [x, y, theta] = get_state(self)
            x = self.x;
            y = self.y;
            theta = self.theta;
        end
        
        function set_wheelDrive(self, driveLeft, driveRight)
            self.driveLeft = driveLeft;
            self.driveRight = driveRight;
        end
        
        function set_nominal_drive(self, drive)
            self.nominalDrive = drive;
        end
        
        function set_curve(self, curve)
            %curve between -1 and 1
            self.curve = curve;
            if curve > 0
                if curve > 1
                    curve = 1;
                end
                self.driveLeft = self.nominalDrive;
                self.driveRight = (1 - 2*curve) * self.nominalDrive;
            else
                if curve < -1
                    curve = -1;
                end
                curve = -curve;
                self.driveLeft = (1 - 2*curve) * self.nominalDrive;
                self.driveRight = self.nominalDrive;
            end
        end
        
        %%
        function traj = get_ground_sensor_trajectory(self)
            % shift: x, y shift of the sensor wrt the cente rof the robot
            % rot: angular rotation of the sensor, 0 mean parallel to the
            % wheel axis
            % span: total length of the sensor
            tmpmatRot = [  cos(self.theta), sin(self.theta); ...
                -sin(self.theta), cos(self.theta)];
            shift = self.groundSensorShift * tmpmatRot;
            
            tmpTheta = self.theta + self.groundSensorRot;
            matRot = [  cos(tmpTheta), sin(tmpTheta); ...
                -sin(tmpTheta), cos(tmpTheta)];
            
            currentPos = [self.x, self.y];
            
            start = [0, -self.groundSensorSpan/2] * matRot + shift + currentPos;
            finish = [0, self.groundSensorSpan/2] * matRot + shift + currentPos;
            
            seg = Segment.line(start, finish);
            traj = Trajectory(seg);
        end
        
        
        function sensorDists = compute_sensor_dist(self, intersectPoint)
            tmpmatRot = [  cos(self.theta), sin(self.theta); ...
                -sin(self.theta), cos(self.theta)];
            shift = self.groundSensorShift * tmpmatRot;
            currentPos = [self.x, self.y];
            sensorCenter = shift + currentPos;
            
            nIntersects = size(intersectPoint, 1);
            sensorDists = zeros(nIntersects, 1);
            for iInt = 1:nIntersects
                U = intersectPoint(iInt, :) - sensorCenter;
                V = [cos(self.theta), sin(self.theta)];
                crossUV = cross([U, 0], [V, 0]);
                sensorDists(iInt) = norm(U) * crossUV(3);
            end
        end
        
        function update_drive_from_sensor_dist(self, sensorDist)
            % K is the gain
            self.set_curve(self.followGain * sensorDist);
        end
        
        function follow(self, trajToFollow)
            trajRobot = self.get_ground_sensor_trajectory();
            [x0,y0] = Trajectory.intersections(trajToFollow, trajRobot);
            if ~isempty(x0)
                sensorDists = self.compute_sensor_dist([x0, y0]);
                [~, idx] = min(abs(sensorDists));
                self.update_drive_from_sensor_dist(sensorDists(idx))
            else
                self.update_drive_from_sensor_dist(0)
            end
        end
        
        %%
        function update_state(self, timeToSimulate)
            driveSum = self.driveLeft + self.driveRight;
            driveDiff = self.driveRight - self.driveLeft;
            
            nIteration = round(timeToSimulate/self.dt);
            for i = 1:nIteration
                dx = (self.wheelRadius/2) * driveSum * cos(self.theta) * self.dt;
                dy = (self.wheelRadius/2) * driveSum * sin(self.theta) * self.dt;
                dtheta = (self.wheelRadius/self.wheelGap) * driveDiff * self.dt;
                
                self.x = self.x + dx;
                self.y = self.y + dy;
                self.theta = self.theta + dtheta;
            end
        end
        
        function plot(self)
            hold on
            
            u = cos(self.theta) * self.robotRadius;
            v = sin(self.theta) * self.robotRadius;
            quiver(self.x, self.y, u, v)
            
            %draw a little circle for the robot
            rectangle('Position',[self.x - self.robotRadius, self.y - self.robotRadius, self.robotRadius*2, self.robotRadius*2],...
                'Curvature',[1,1]);
            
            %draw a little rectangle for the robot wheels
            width = self.wheelRadius*2;
            height = self.robotRadius/3;
            
            matRot = [cos(self.theta), sin(self.theta); -sin(self.theta), cos(self.theta)];
            
            leftRect = [0, self.wheelGap/2] * matRot;
            rightRect = [0, -self.wheelGap/2] * matRot;
            
            leftRectCenter = [self.x+leftRect(1), self.y+leftRect(2)];
            rightRectCenter = [self.x+rightRect(1), self.y+rightRect(2)];
            
            oriented_rectangle(leftRectCenter, width, height, self.theta, true, 'k')
            oriented_rectangle(rightRectCenter, width, height, self.theta, true, 'k')
            
        end
    end
    
end
