function plot_all_objects(colorValues)
% this load 'objectPositions', 'objectAvoidanceRadius', 'objectRadius'
load(get_objects_filename)
nObjects = size(objectPositions, 1);

if nargin < 1
    colorList = jet(nObjects);
else
    colorList = values_to_colors(colorValues);
end

for iObj = 1:nObjects
    plot_object(objectPositions(iObj, :), objectRadius, 'FaceColor', colorList(iObj, :))
end

