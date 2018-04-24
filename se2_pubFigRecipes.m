 %% MT
 
out  = se2_pubFigs(Dall , 'MT','RandvsStructCommpare'); 
out  = se2_pubFigs(Dall , 'MT','RandStructAcrossDays' , 'poolDays' , 0); 
out  = se2_pubFigs(Dall , 'MT','compareLearning' , 'poolDays' , 0);
out  = se2_pubFigs(Dall , 'MT','LearningEffectShade' , 'poolDays' , 0);
out  = se2_pubFigs(Dall , 'MT','BoxFirstLastDays' , 'poolDays' , 0);


out  = se2_pubFigs(Dall , 'RT','RandvsStructCommpare','poolDays' , 1); 
out  = se2_pubFigs(Dall , 'RT','RandStructAcrossDays' , 'poolDays' , 0); 
out  = se2_pubFigs(Dall , 'RT','BoxAcrossDays' , 'poolDays' , 1);
out  = se2_pubFigs(Dall , 'RT','BoxAcrosSeqType' , 'poolDays' , 1);
out  = se2_pubFigs(Dall , 'RT','LearningEffectHeat' , 'poolDays' , 0);
out  = se2_pubFigs(Dall , 'RT','LearningEffectShade' , 'poolDays' , 1);
out  = se2_pubFigs(Dall , 'RT','compareLearning' , 'poolDays' , 1);


out  = se2_pubFigs(Dall , 'MT_asymptote','Actual&fitHorz', 'poolDays' , 0, 'MaxIter' , 150);
out  = se2_pubFigs(Dall , 'MT_asymptote','Actual&fitDayz', 'poolDays' , 0, 'MaxIter' , 50);
out  = se2_pubFigs(Dall , 'MT_asymptote','Actual&fit%ChangeDayzTotalLearning', 'poolDays' , 0, 'MaxIter' , 50);
out  = se2_pubFigs(Dall , 'MT_asymptote','Actual&fit%ChangeDay2Day', 'poolDays' , 0, 'MaxIter' , 50);
out  = se2_pubFigs(Dall , 'MT_asymptote','Actual&fit%ChangeSeqType', 'poolDays' , 0, 'MaxIter' , 50);
out  = se2_pubFigs(Dall , 'MT_asymptote','plotCoef', 'poolDays' , 0, 'MaxIter' , 150);


out  = se2_pubFigs(Dall , 'IPI_asymptote','Actual&fitHorz', 'poolDays' , 0, 'MaxIter' , 150);
out  = se2_pubFigs(Dall , 'IPI_asymptote','plotCoef', 'poolDays' , 0, 'MaxIter' , 200);


out  = se2_pubFigs(Dall , 'IPI','IPIFullDispHeat', 'poolDays' , 0);
out  = se2_pubFigs(Dall , 'IPI','IPIFullDispShade', 'poolDays' , 0);
out  = se2_pubFigs(Dall , 'IPI','compareLearning', 'poolDays' , 0);
out  = se2_pubFigs(Dall , 'IPI','compareLearning_histogram', 'poolDays' , 0);


out  = se2_pubFigs(Dall , 'test_MT_asymptote','', 'poolDays' , 1);


%% MT seg test
clear hpval
S = {[0] , [1:2]};
% dayz = {[1] [2 3] [4 5]};
dayz = {[1] [2] [ 3] [4] [ 5]};
for s = 1:length(S)
    for d = 1:length(dayz)
        for h = 1:5
            stats = se2_SigTest(Dall , 'MT'  , 'seqNumb' , S{s} , 'Day' , dayz{d} , 'Horizon' , [h:13],...
                'PoolDays' , 1,'whatIPI','WithinBetweenChunk','PoolSequences' , 0 ,...
                'PoolHorizons' , [6:13]);
            close all
            hpval{s}(d,h) = stats.eff(2).p;
        end
    end
    hpval{s}( hpval{s}<=0.05) = 1;
    hpval{s}( hpval{s}~=1) = 0;
end

%% SeqType sig test
clear hpval
horz = {[1] [2] [3] [4] [5] [6:13]};
for h = [1:8,13]
    for d  = 1:5
        stats = se2_SigTest(Dall , 'MT' , 'seqNumb' , [0:2] , 'Day' , d , 'Horizon' , [h],...
            'PoolDays' , 0,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
            'PoolHorizons' , [],'ipiOfInterest' , [] , 'poolIPIs' , 0 , 'subjnum' , [1:13]);
        hpval(d,h) = stats.eff(2).p;
        close all
    end
end
pval = hpval;
pval(pval>0.05) = NaN;
%%
stats = se2_SigTest(Dall , 'MT' , 'seqNumb' , [1:2] , 'Day' , [1:5] , 'Horizon' , [2:13],...
    'PoolDays' , 0,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
    'PoolHorizons' , [],'ipiOfInterest' , [] , 'poolIPIs' , 0 , 'subjnum' , [1:13]);

%%
stats = se2_SigTest(Dall , 'IPI' , 'seqNumb' , [0:2] , 'Day' , [1:5] , 'Horizon' , [1:13],...
    'PoolDays' , 0,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
    'PoolHorizons' , [],'ipiOfInterest' , [0:2] , 'poolIPIs' , 0 , 'subjnum' , [1:13]);
%%

stats = se2_SigTest(Dall , 'PerSubjMTHorz' , 'seqNumb' , [0:2] , 'Day' , [5] , 'Horizon' , [1:13],...
    'PoolDays' , 0,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
    'PoolHorizons' , [],'ipiOfInterest' , [0 2] , 'poolIPIs' , 0 , 'subjnum' , [1:13]);

%% 
stats = se2_SigTest(Dall , 'PercentseqType' , 'seqNumb' , [0:2] , 'Day' , [1:5] , 'Horizon' , [1:13],...
    'PoolDays' , 0,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
    'PoolHorizons' , [],'ipiOfInterest' , [] , 'poolIPIs' , 0 , 'subjnum' , [1:13]);


%%


out  = se2_pubFigs(Dall , 'MT_asymptote','', 'poolDays' , 0, 'MaxIter' , 150);
        
        
        
        
        
        
        
        
