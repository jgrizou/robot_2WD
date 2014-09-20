classdef PlannerAction < handle
    %PLANNERACTION
    
    properties
        shiftFromZero
        thetaFromZero
        segmentFromZero
    end
    
    methods
        
        function self = PlannerAction(shiftFromZero, thetaFromZero, segmentFromZero)
            self.shiftFromZero = shiftFromZero;
            self.thetaFromZero = thetaFromZero;
            self.segmentFromZero = segmentFromZero;
        end
        
        function [newX, newY, newTheta] = get_outcome(self, X, Y, theta)
            out = self.shiftFromZero(theta);
            newX = out(1) + X;
            newY = out(2) + Y;
            newTheta = mod(self.thetaFromZero(theta), 2*pi);
        end
        
        function segment = get_segment(self, X, Y, theta)
            segment = self.segmentFromZero(X, Y, theta);
        end
    end
    
    methods(Static)
        function plannerAction = CircleQuarter(radius, isGoingUp)
            % don't kwon how to put serious variable name
            % increasingAngle is true or false
            matRot = @(theta) [cos(theta), sin(theta); -sin(theta), cos(theta)];
            if isGoingUp
                shiftFromZero = @(theta) [radius, radius] * matRot(theta);
                thetaFromZero = @(theta) theta + pi/2;
                circleCenter = @(X,Y,theta) [X, Y] + [0, radius] * matRot(theta);
                thetaStart = @(theta) theta - pi/2;
                thetaFinish = @(theta) theta;
            else
                shiftFromZero = @(theta) [radius, -radius] * matRot(theta);
                thetaFromZero = @(theta) theta-pi/2;
                circleCenter = @(X,Y,theta) [X, Y] + [0, -radius] * matRot(theta);
                thetaStart = @(theta) theta;
                thetaFinish = @(theta) theta + pi/2;
            end
            segmentFromZero = @(X, Y, theta) Segment.circle(circleCenter(X,Y,theta), radius, thetaStart(theta), thetaFinish(theta));
            plannerAction = PlannerAction(shiftFromZero, thetaFromZero, segmentFromZero);
        end
        
        function plannerAction = Straight(distance)
            % don't kwon how to put serious variable name
            % increasingAngle is true or false
            matRot = @(theta) [cos(theta), sin(theta); -sin(theta), cos(theta)];
            
            shiftFromZero = @(theta) [distance, 0] * matRot(theta);
            thetaFromZero = @(theta) theta;
            lineFinish = @(X,Y,theta) [X, Y] + [distance, 0] * matRot(theta);
            
            segmentFromZero = @(X, Y, theta) Segment.line([X,Y], lineFinish(X, Y, theta));
            plannerAction = PlannerAction(shiftFromZero, thetaFromZero, segmentFromZero);
        end
        
    end
end

