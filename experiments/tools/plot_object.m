function plot_object(position, radius, varargin)
%draw a little circle for the robot
rectangle('Position',[position(1) - radius, position(2) - radius, radius*2, radius*2],...
    'Curvature',[1,1], varargin{:});