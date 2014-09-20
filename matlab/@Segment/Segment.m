classdef Segment < handle
    %SEGMENT
    
    properties
        
        type
        %line - requires start and finish
        
        %circle - requires the center, the radius
        % the segment is define from startAngle to finishAngle rotating in positive angle direction
        
        %ellipse - requires the center, the a and b param of an allipse, its rotation phi,
        %the segment is define from startAngle to finishAngle rotating in positive angle direction
        
        params = struct
        
    end
    
    methods
        
        function self = Segment(type, varargin)
            self.type = type;
            switch self.type
                case 'line'
                    [start, finish] = ...
                        process_options(varargin, ...
                        'start', [], ...
                        'finish', []);
                    
                    self.params.start = start;
                    self.params.finish = finish;
                    
                case 'circle'
                    [center, radius, startAngle, finishAngle] = ...
                        process_options(varargin, ...
                        'center', [], ...
                        'radius', [], ...
                        'startAngle', [], ...
                        'finishAngle', []);
                    
                    self.params.center = center;
                    self.params.radius = radius;
                    self.params.startAngle = startAngle;
                    self.params.finishAngle = finishAngle;
                    
                case 'ellipse'
                    [center, a, b, phi, startAngle, finishAngle] = ...
                        process_options(varargin, ...
                        'center', [], ...
                        'a', [], ...
                        'b', [], ...
                        'phi', [], ...
                        'startAngle', [], ...
                        'finishAngle', []);
                    
                    self.params.center = center;
                    self.params.a = a;
                    self.params.b = b;
                    self.params.phi = phi;
                    self.params.startAngle = startAngle;
                    self.params.finishAngle = finishAngle;
                    
                otherwise
                    error('not handled')
                    
            end
        end
        
        function [X, Y] = get_curve(self, nPointOnSegment)
            if nargin < 2
                nPointOnSegment = 100;
            end
            
            switch self.type
                case 'line'
                    X = [self.params.start(1); ...
                        self.params.finish(1)];
                    Y = [self.params.start(2); ...
                        self.params.finish(2)];
                    
                case 'circle'
                    t = linspace(self.params.startAngle, self.params.finishAngle, nPointOnSegment)';
                    X = self.params.radius*cos(t) + self.params.center(1);
                    Y = self.params.radius*sin(t) + self.params.center(2);
                    
                case 'ellipse'
                    t = linspace(self.params.startAngle, self.params.finishAngle, nPointOnSegment)';
                    X = self.params.center(1) + (self.params.a * cos(t) * cos(self.params.phi) - self.params.b * sin(t) * sin(self.params.phi));
                    Y = self.params.center(2) + (self.params.a * cos(t) * sin(self.params.phi) + self.params.b * sin(t) * cos(self.params.phi));
                      
                otherwise
                    error('not handled')   
            end
            
        end
        
        function plot(self, nPointOnSegment, varargin)
            if nargin < 2
                nPointOnSegment = 100;
            end
            [X, Y] = self.get_curve(nPointOnSegment);
            plot(X, Y, varargin{:})
        end
    end
    
    methods(Static)
        function segment = line(start, finish)
            segment = Segment('line', 'start', start, 'finish', finish);
        end
        
        function segment = circle(center, radius, startAngle, finishAngle)
            segment = Segment('circle', 'center', center, 'radius', radius, ...
                'startAngle', startAngle, 'finishAngle', finishAngle);
        end
        
        function segment = ellipse(center, a, b, phi, startAngle, finishAngle)
            segment = Segment('ellipse', 'center', center, 'a', a, 'b', b, ...
                'phi', phi, 'startAngle', startAngle, 'finishAngle', finishAngle);
        end
        
        function [x0,y0] = intersections(seg1, seg2, nPointOnSegment, robust)
            if nargin < 3
                nPointOnSegment = 100;
            end
            if nargin < 4
                robust = true;
            end
            [x1, y1] = seg1.get_curve(nPointOnSegment);
            [x2, y2] = seg2.get_curve(nPointOnSegment);
            [x0,y0] = intersections(x1,y1,x2,y2,robust);
        end
    end
    
end

