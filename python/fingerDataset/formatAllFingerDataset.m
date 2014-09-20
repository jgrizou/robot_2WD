
[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
folder = fullfile(pathstr, 'fingerData');


saveFormattedFolder = fullfile(pathstr, 'formattedData');
if~exist(saveFormattedFolder, 'dir')
    mkdir(saveFormattedFolder)
end

saveFeaturedFolder = fullfile(pathstr, 'featuredData');
if~exist(saveFeaturedFolder, 'dir')
    mkdir(saveFeaturedFolder)
end

matFiles = getfilenames(folder, 'refiles', '*.mat');


for iMat = 1:length(matFiles)
    
    load(matFiles{iMat})
    formattedFingerData = formatFingerData(fingerData);
    nData = length(formattedFingerData);
    
    [~, fname,~] = fileparts(matFiles{iMat});
    save(fullfile(saveFormattedFolder, fname), 'formattedFingerData')
    
    X = [];
    for i = 1:nData
        tmp = formattedFingerData{i};
        X = [X; formatFinger(tmp.X, tmp.Y, tmp.T)];
    end
    
    save(fullfile(saveFeaturedFolder, fname), 'X')
    
end