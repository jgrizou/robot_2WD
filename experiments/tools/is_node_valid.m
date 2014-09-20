function atLeastOneValidState = is_node_valid(planner, X, Y)

atLeastOneValidState = 0;
for iOr = 1:planner.nOrientations
    iState = planner.get_state_from_external_feature(X, Y, iOr);
    if ~planner.is_state_dead(iState) && planner.is_state_reachable(iState)
        atLeastOneValidState = 1;
    end
end