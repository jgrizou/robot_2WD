function update_robot_policy(state, reward)
% UPDATE_ROBOT_POLICY

% this load the robot planner as robotPlanner
load(get_robot_planner_filename())
% the MDP shoudl be prebuilt with forbidden area included
robotPlanner.update_reward(state, reward);
robotPlanner.update_policy();

robotPolicy = robotPlanner.policy;
save(get_robot_policy_filename, 'robotPolicy')


