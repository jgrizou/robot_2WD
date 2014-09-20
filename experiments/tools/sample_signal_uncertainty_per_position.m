function uncertaintyValues = sample_signal_uncertainty_per_position(positions, objectPositions, objectProbabilities, signalSamples, frame, classifiers, nCrossValidation)
%SAMPLE_SIGNAL_UNCERTAINTY_PER_NODE

nPositions = size(positions, 1);
nHypothesis = length(objectProbabilities);
nSamples = size(signalSamples, 1);
nLabels = size(frame.compute_labels(objectPositions(1, :), positions(1, :)), 2);

correctedPredictedPLabel = zeros(nSamples, nLabels, nHypothesis);
for iHypothesis = 1:nHypothesis
    %the correction from confusion matrix is not needed here, only matters
    %the ordering not the absolute value
    predictedPLabel = classifiers{iHypothesis}.logpredict(signalSamples);
    confusionMatrix = classifiers{iHypothesis}.compute_proba_empirical_confusion_matrix(nCrossValidation);
    % normalize it per column!  may be optimized
    confusionMatrix = proba_normalize_row(confusionMatrix')';
    correctedPredictedPLabel(:,:, iHypothesis) = (confusionMatrix * predictedPLabel')';
end

uncertaintyValues = zeros(nPositions, 1);
for iPos = 1:nPositions

    expectationMatching = zeros(nSamples, nHypothesis);
    for iHypothesis = 1:nHypothesis
        expectedPLabel = frame.compute_labels(objectPositions(iHypothesis, :), positions(iPos, :));
        expectedPLabel = repmat(expectedPLabel, nSamples, 1);
        expectationMatching(:, iHypothesis) = sum(expectedPLabel .* correctedPredictedPLabel(:, :, iHypothesis), 2);
    end
    uncertaintyValues(iPos) = sum(var(expectationMatching, objectProbabilities, 2));
end