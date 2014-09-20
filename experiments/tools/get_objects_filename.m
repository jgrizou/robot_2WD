function objectFilename = get_objects_filename()
sharedFolder = get_shared_folder();
objectFilename = fullfile(sharedFolder, 'objects.mat');