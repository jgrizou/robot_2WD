function set_robot_random_policy()
% loads robotRandomPolicy
load(get_robot_random_policy_filename())
robotPolicy = robotRandomPolicy;
save(get_robot_policy_filename, 'robotPolicy')

