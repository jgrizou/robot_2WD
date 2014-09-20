function sharedFolder = get_shared_folder()
[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
sharedFolder = fullfile(pathstr, '../shared');
if ~exist(sharedFolder, 'dir')
    mkdir(sharedFolder)
end
