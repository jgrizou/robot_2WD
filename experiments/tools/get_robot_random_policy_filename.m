function policyFilename = get_robot_random_policy_filename()
sharedFolder = get_shared_folder();
policyFilename = fullfile(sharedFolder, 'robotRandomPolicy.mat');