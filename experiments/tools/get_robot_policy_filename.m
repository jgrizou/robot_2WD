function policyFilename = get_robot_policy_filename()
sharedFolder = get_shared_folder();
policyFilename = fullfile(sharedFolder, 'robotPolicy.mat');