clear all
init

pl = Planner([-1.5,1.5], [-1.5,1.5], 0.5);

s1 = Segment.circle([0, 0], 0.45, 0, 2*pi);
traj1 = Trajectory(s1);
pl.set_forbidden_trajectory(traj1);

pl.build_MDP();

%%
pl.set_reward_at_state(2, 1);
[Q, P] = pl.solve_MDP();

%%
clf
hold on
pl.plot_nodes(50, 'k', 'filled')
traj1.plot(100, 'k')
xlim([-2, 2])
ylim([-2, 2])

state = randi(pl.nS);
while ~pl.is_state_usable(state) || ~pl.is_state_reachable(state)
    state = randi(pl.nS);
end
for i = 1:50
    pl.plot_state(state)
    action = greedy_action_discrete_policy(P, state);
    pl.plot_segment(state, action, 'r')
    state = greedy_action_discrete_policy(pl.P{action}, state);
end

%%
% clf
% hold on
% for iS = 1:pl.nS
%     for iA = 1:pl.nA
%         if pl.is_state_action_usable(iS, iA)
%             if pl.is_state_action_usable(iS, iA)
%                 pl.plot_segment(iS, iA)
%             end
%         end
%     end
% end





