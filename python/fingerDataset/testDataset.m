load('datasets/all_finger.mat')
% load('datasets/dot_finger.mat')
% load('datasets/move_finger.mat')
% load('datasets/sign_finger.mat')


pY = label_to_plabel(Y, 1, max(Y));

%%
tic; cl = Gaussian_classifier('diag', 1e-6); cl.fit(X, pY); toc
% tic; cl = LogisticRegression_classifier(); cl.fit(X, pY); toc
% tic; cl = SVM_classifier(); cl.fit(X, pY); toc


%%
confu = cl.compute_hard_empirical_confusion_matrix(10);
sum(diag(confu))
imagesc(confu)


%%

[B,dev,stats] = mnrfit(X, Y, 'model','hierarchical');
[pihat,dlow,hi] = mnrval(B, X, stats, 'model','hierarchical');