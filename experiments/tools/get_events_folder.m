function eventFolder = get_events_folder()
sharedFolder = get_shared_folder();
eventFolder = fullfile(sharedFolder, 'events');
if ~exist(eventFolder, 'dir')
    mkdir(eventFolder)
end