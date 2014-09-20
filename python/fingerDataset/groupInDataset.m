[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
folder = fullfile(pathstr, 'featuredData');

saveFolder = fullfile(pathstr, 'datasets');
if~exist(saveFolder, 'dir')
    mkdir(saveFolder)
end

matFiles = getfilenames(folder, 'refiles', '*.mat');


dataX = [];
Y = [];
cnt = 0;
for iMat = 1:length(matFiles)
    
    [~, fname,~] = fileparts(matFiles{iMat});
    
    m = input(['Use ', fname, '? ']);
%     m = 1;
    if m
        cnt = cnt + 1;
        load(matFiles{iMat})
        dataX = [dataX; X];
        Y = [Y; ones(size(X,1), 1)*cnt];
    end
    
end

X = dataX;

fname = 'all_finger';
fname = input(['Dataset name? ']);
save(fullfile(saveFolder, fname), 'X', 'Y')