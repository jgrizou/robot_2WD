classdef Object_direction_absolute_frame < handle
    %OBJECTDIRECTIONABSOLUTE
    
    properties
        errorRate = 0;
        labelsNames = {'up', 'down', 'right', 'left'}
        labelsTheta = [pi/2, -pi/2, 0, pi]
    end
    
    methods
        
        function self = Object_direction_absolute_frame(errorRate)
            % The error rate model the error rate (default is 0)
            if nargin > 0
                self.errorRate = errorRate;
            end
        end
        
        function labels = compute_labels(self, objectPosition, robotPosition)
            U = objectPosition(1) - robotPosition(1);
            V = objectPosition(2) - robotPosition(2);
            theta = atan2(V, U);
            
            labels = zeros(1, length(self.labelsTheta));
            if ~isnan(theta)
                diffTheta = mod(theta - self.labelsTheta, 2*pi);
                diffTheta(diffTheta > pi) = diffTheta(diffTheta > pi) - 2*pi;
                labels = -abs(diffTheta)/(pi/2) + 1;
                labels(labels < 0) = 0;
            end
            labels = apply_noise(labels, self.errorRate);
        end
    end
end