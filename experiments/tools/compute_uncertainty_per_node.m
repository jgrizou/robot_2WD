function uncertaintyValues = compute_uncertainty_per_node(rec, uncertaintyMethodName, methodInfo)
%COMPUTE_UNCERTAINTY_PER_NODE

filestr = generate_method_filestr(methodInfo);
methodPlanningProba = proba_normalize_row(rec.(['probabilities_', filestr])(end, :));

nAvailableSample = size(rec.teacherSignal, 1);
if nAvailableSample > rec.nSampleUncertaintyPlanning
    idx = randperm(nAvailableSample);
    signalSamples = rec.teacherSignal(idx(1:rec.nSampleUncertaintyPlanning), :);
else
    signalSamples = rec.teacherSignal;
end

[nodeX, nodeY] = rec.robotPlanner.planner.get_node_position();

switch uncertaintyMethodName

    case 'signal_sample'
        uncertaintyValues = sample_signal_uncertainty_per_position(...
            [nodeX, nodeY], ...
            rec.objectPositions, ...
            methodPlanningProba, ...
            signalSamples, ...
            rec.learnerFrame, ...
            rec.(['classifiers_', filestr]), ...
            rec.nCrossValidation);

    otherwise
        error('compute_uncertainty_map:UnknownMethodName', ['"', methodName, ' not handled']) 
end
