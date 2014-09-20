classdef Trajectory < handle
    %TRAJECTORY
    %only 2D
    
    properties
        
        segments = {}
        
    end
    
    methods
        
        function self = Trajectory(varargin)
            for iSeg = 1:nargin
                self.addSegment(varargin{iSeg});
            end
        end
        
        function addSegment(self, segment)
            self.segments{end+1} = segment;
        end
        
        function [X, Y] = get_curve(self, nPointOnSegment)
            if nargin < 2
                nPointOnSegment = 100;
            end
            nSegments = length(self.segments);
            X = cell(1, nSegments);
            Y = cell(1, nSegments);
            for iSeg = 1:nSegments
                [tmpX, tmpY] = self.segments{iSeg}.get_curve(nPointOnSegment);
                X{iSeg} = tmpX;
                Y{iSeg} = tmpY;
            end
        end
        
        function plot(self, nPointOnSegment, varargin)
            hold on
            if nargin < 2
                nPointOnSegment = 100;
            end
            for iSeg = 1:length(self.segments)
                self.segments{iSeg}.plot(nPointOnSegment, varargin{:});
            end
        end
    end
    
    methods(Static)
        function [x0,y0] = intersections(traj1, traj2, nPointOnSegment, robust)
            if nargin < 3
                nPointOnSegment = 100;
            end
            if nargin < 4
                robust = true;
            end

            x0 = [];
            y0 = [];
            for iSeg = 1:length(traj1.segments)
                for jSeg = 1:length(traj2.segments)
                    [tmpx0,tmpy0] = Segment.intersections(traj1.segments{iSeg}, traj2.segments{jSeg}, nPointOnSegment, robust);
                    x0 = [x0; tmpx0];
                    y0 = [y0; tmpy0];
                end
            end
            
            % Remove duplicate intersection points.
            xy0 = [x0, y0];
            [~, index] = unique(xy0,'rows');
            x0 = x0(index);
            y0 = y0(index);
            
        end
        
    end
    
end


