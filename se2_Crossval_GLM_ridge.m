function out  = se2_Crossval_GLM_ridge(what , lambda)


% what  'c' for modeling Chunked sequences 
%       'r' for modeling Random sequences 


baseDir = '/Users/nedakordjazi/Documents/SeqEye/SeqEye2/analyze';     %macbook
% baseDir = '/Volumes/MotorControl/data/SeqEye2/analyze';  % server
baseDir = '/Users/nkordjazi/Documents/SeqEye/SeqEye2/analyze';          %iMac

subj_name = {'AT1' , 'CG1' , 'HB1' , 'JT1' , 'CB1' , 'YM1' , 'NL1' , 'SR1' , 'IB1' , 'MZ1' , 'DW1', 'All'};
%% develope the GLM
horzSize = {1,2,3,4,5,6,7,8,13,[5:13]}; 
switch what
    case 'c'
        load([baseDir , '/se2_TranProb.mat'] , 'C')
        M = C;
        titleSuffix = 'Chunked';
        
    case 'r'
        load([baseDir , '/se2_TranProb.mat'] , 'R')
        M = R;
        titleSuffix = 'Random';
end
% =================== Prepare the Design Matrix
L = length(M.IPI);
M.IPIarrangement(M.IPIarrangement == 0) = 1;
M.X1 = ones(L , 1); % intercept

M.X2 = M.IPIarrangement; % within/between chunk
M.X2(M.X2==1) = 1; % between
M.X2(M.X2==0) = 1; % Random --> set to between
M.X2(M.X2==2) = -1;  % within

% Map 1st, 2nd 3rd transition probabilities to 5 bins and set them as predictors
temp = M.t2Prob_n;
M.X3 = ceil(1.5*(1 + mapminmax(temp')))';

temp = M.t3Prob_n(:,1);
M.X4 = ceil(1.5*(1 + mapminmax(temp')))';

temp = M.t4Prob_n(:,1);
M.X5 = ceil(1.5*(1 + mapminmax(temp')))';

% the learinng regressor - using normalized IPIs, we dont need this
M.X6 = M.BN;

% the repetition regressor
M.X7 = ismember(M.t2 , [21:25])  +1;

% the design mtrix
M.X = [M.X1 M.X2 M.X3 M.X4 M.X5 M.X6 M.X7];


M.Y = M.IPI_norm;
titleSuffix = [titleSuffix , '-norm'];
xx =     {[7]    [2 7] ,   [3 7] ,   [3:4 7]        [3:5,7]          ,[2:3  , 7] ,      [2:4,7]  ,    [2:5 , 7]};
label = {'R'  'C+R',     '1st+R' ,'1st+2nd+R'    '1st+2nd+3rd+R' , 'C+1st+R'  ,  'C+1st+2nd+R'  ,  'Full'};
plotIND = [2:5 , 8]; % the model indices to include in plot

cleanLabel = {'within/between Chunk', '1st order probability' ,'1st + 2nd order probability' ,'1st + 2nd + 3rd order probability' ,'Full Model'};
cat_cleanLabel = categorical(repmat(cleanLabel , length(horzSize)-1 , 1));
% =================== % =================== % =================== %
% =================== Make Modelss
% 3 fold crossvalidation
CVfol = 3;
count = 1;
for h = 1:length(horzSize) % loop over horizons
    for dd = 1:5   % loop over days
        for sn = 1:length(subj_name) - 1   % loop over subjects
            T = getrow(M , ismember(M.SN , sn) & ismember(M.Horizon , horzSize{h}) & ismember(M.Day , dd));
            L = length(T.Y);
            CVI = crossvalind('Kfold', L, CVfol);
            for cvl = 1:CVfol  % loop over CV folds
                Test = getrow(T , CVI==cvl);
                Train = getrow(T , CVI~=cvl);
                params  = xx{1};   % Null Model
                X = Train.X(:,params);
                X = X - repmat(mean(X) , length(X) , 1); % mean subtract the design matrix
                Y = Train.Y - mean(Train.Y);  % mean subtract the output

                % Matlab 2016 onward (iMac)
                % Mdl = fitrlinear(X ,Y,'Lambda',lambda,'Regularization','ridge' , 'FitBias' , false); Matlab 2016 onward
                
                % Matlab 2015 before (mcBook)
                b = ridge(Y,X,lambda);

                
                X = Test.X(:,params);
                X = X - repmat(mean(X) , length(X) , 1); % mean subtract the design matrix
                Ypred0 = X * b; % prediction of the null model
                for ml = 1:length(xx)
                    params  = xx{ml};
                    X = Train.X(:,params);
                    X = X - repmat(mean(X) , length(X) , 1); % mean subtract the design matrix
                    Y = Train.Y - mean(Train.Y);  % mean subtract the output
                    
                    % Matlab 2016 onward (iMac)
                    % Mdl = fitrlinear(X ,Y,'Lambda',lambda,'Regularization','ridge' , 'FitBias' , false); Matlab 2016 onward
                    
                    % Matlab 2015 before (mcBook)
                    b = ridge(Y,X,lambda);
                    
                    X = Test.X(:,params);
                    X = X - repmat(mean(X) , length(X) , 1); % mean subtract the design matrix
                    Y = Test.Y - mean(Test.Y);  % mean subtract the output
                    
                    Ypred = X * b;  % prediction of the alternative model
                    
                    out.R2(count,:)   = se2_R2ModelComp(Y , Ypred0 , Ypred);
                    
                    out.hor(count , 1) = h;
                    out.subj(count , 1) = sn;
                    temp = corrcoef(Y , Ypred);
                    out.corYY (count , 1) = temp(2);
                    out.day(count , 1) = dd;
                    out.xx(count , 1) = ml;
                    out.cv (count , 1) = cvl;
                    count = count+1;
                    disp(['Model ' , num2str(ml) , ' - Day ' , num2str(dd) , ' - Subject ' , num2str(sn) , ' - Horizon ' , num2str(h)])
                end
            end
        end
    end
end

Mdl = out;
save([baseDir , '/se2_CrossvalIPI_',titleSuffix,'_RR.mat'] , 'Mdl' , '-v7.3')


    
 