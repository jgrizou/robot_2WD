function plannerFilename = get_robot_planner_filename()
sharedFolder = get_shared_folder();
plannerFilename = fullfile(sharedFolder, 'robotPlanner.mat');