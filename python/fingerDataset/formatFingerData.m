function formattedFingerData = formatFingerData(fingerData)
%FORMATFINGERDATA

formattedFingerData = {};
for i = 1:size(fingerData, 1)
    formattedFingerData{i} = struct;
    formattedFingerData{i}.X = fingerData{i,1};
    formattedFingerData{i}.Y = fingerData{i,2};
    formattedFingerData{i}.T = double(fingerData{i,3});
end


