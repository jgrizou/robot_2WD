

figure
hold on
for i = 1: length(formattedFingerData)
    scatter(formattedFingerData{i}.X, formattedFingerData{i}.Y)
end

xlim([0, 900])
ylim([0, 1100])