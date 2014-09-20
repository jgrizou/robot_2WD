function create_event(robotState, teacherSignal)
% robotState ([x, y, theta]) 
% teacherSignal: feature vector

eventFolder = get_events_folder();
eventFile = generate_available_filename(eventFolder);
save(eventFile, 'robotState', 'teacherSignal')
