function features = formatFinger(X, Y, T)
%FORMATXYFINGER

%%
[~,uniId] = unique(T);
X = X(uniId);
Y = Y(uniId);
T = T(uniId);

%%
minX = 50;
maxX = 750;
X(X<minX) = minX;
X(X>maxX) = maxX;
X = (X-minX) / (maxX-minX);

%
minY = 100;
maxY = 1000;
Y(Y<minY) = minY;
Y(Y>maxY) = maxY;
Y = (Y-minY) / (maxY-minY);


if length(X) > 1
    T = T-T(1);
    dX = diff(X);
    dY = diff(Y);
    dT = diff(T);
    Travel = sum(sqrt(dX.^2 + dY.^2));
    Speed = sqrt(dX.^2 + dY.^2)./dT;
    %%
%     X = (X(2:end)+X(1:end-1))/2;
%     Y = (Y(2:end)+Y(1:end-1))/2;
    
else
    T = 0;
    dT = 0;
    Speed = 0;
    Travel = 0;
end


%%
% cutX = 0:1/3:1;
% cntX = histc(X, cutX);
% cntX(end-1) = cntX(end-1) + cntX(end);
% cntX = cntX(1:end-1);
% 
% cutY = 0:1/3:1;
% cntY = histc(Y, cutY);
% cntY(end-1) = cntY(end-1) + cntY(end);
% cntY = cntY(1:end-1);
% 
% cutSpeed = [0, Inf];
% cntSpeed = histc(Speed, cutSpeed);
% cntSpeed(end-1) = cntSpeed(end-1) + cntSpeed(end);
% cntSpeed = cntSpeed(1:end-1);

%%
features = [];
% for iCntX = 1:length(cntX)
%     for iCntY = 1:length(cntY)
%         for iCntSpeed = 1:length(cntSpeed)
%             tmp = [cntX(iCntX), cntY(iCntY), cntSpeed(iCntSpeed)];
%             features(length(features)+1) = min(tmp);
%         end
%     end
% end
features(length(features)+1) = X(1);
features(length(features)+1) = X(end);
features(length(features)+1) = Y(1);
features(length(features)+1) = Y(end);

features(length(features)+1) = X(end) - X(1);
features(length(features)+1) = Y(end) - Y(1);

features(length(features)+1) = median(X);
features(length(features)+1) = median(Y);

features(length(features)+1) = sqrt((X(end)-X(1))^2 + (Y(end)-Y(1))^2);
features(length(features)+1) = Travel;

if T(end) ~= 0
    features(length(features)+1) = Travel/T(end)*100;
else
    features(length(features)+1) = 0;
end

% features(length(features)+1) = length(X);

% features(length(features)+1) = mean(Speed);
% features(length(features)+1) = std(Speed);

% features = proba_normalize_row(features);






