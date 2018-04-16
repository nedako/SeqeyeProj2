function stats = se2_SigTest(Dall , what , varargin)

c=  1;
PoolSequences = 0;
PoolDays = 1;
PoolHorizons = [];
while(c<=length(varargin))
    switch(varargin{c})
        case {'seqNumb'}
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'PoolSequences'}
            % whether to pool together all the sequences
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'PoolDays'}
            % whether to pool together 2,3 and 4,5
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'PoolHorizons'}
            % whether to pool together 4 - full
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'Day'}
            % defines the length of the sequence
            % default is 10
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'Horizon'}
            % defines the number of sequences to be simulated Default = 200
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'whatIPI'}
            % required when what = 'IPI'
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'ipiOfInterest'}
            % in the case of 'ipiOfInterest' IPI of interest to test --> Steady State =[4:10]
            % in the case of 'compareLearning' 0 1 2
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'poolIPIs'}
            % in the case of 'compareLearning'
            % 'Pool [Random and Between (1)] , [within and between (2) , [nothing (0)]]
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        otherwise
            error(sprintf('Unknown option: %s',varargin{c}));
    end
end

ANA = getrow(Dall , Dall.isgood & ~Dall.isError & ...
    ismember(Dall.Horizon , Horizon) & ...
    ismember(Dall.Day , Day) & ismember(Dall.seqNumb , seqNumb));
ANA.RT = ANA.AllPressTimes(:,1);
ANA.seqNumb(ANA.seqNumb>1) = 1;
if PoolSequences
    ANA.seqNumb = zeros(size(ANA.seqNumb));
end
if PoolDays
    ANA.Day(ANA.Day == 3) = 2;
    ANA.Day(ismember(ANA.Day , [4,5])) = 3;
end

if ~isempty(PoolHorizons)
    ANA.Horizon(ismember(ANA.Horizon ,PoolHorizons)) = 13;
    Horizon = unique(ANA.Horizon);
end

factors = {'Horizon' , 'Day' , 'seqNumb'};
facInclude = [length(Horizon)>1 , length(unique(ANA.Day))>1  , length(unique(ANA.seqNumb))>1];
FCTR =  factors(facInclude);

switch what
    case 'MT'
        var = [];
        for f = 1:length(FCTR)
            eval(['var = [var ANA.',FCTR{f},'];']);
        end
        stats = anovaMixed(ANA.MT  , ANA.SN ,'within',var ,FCTR,'intercept',1) ;
        %         anovan(ANA.MT,var,'model','interaction','varnames',FCTR)  % between subject
        figure('color' , 'white')
        lineplot(var, ANA.MT , 'style_shade' , 'markertype' , 'o'  , ...
            'markersize' , 10 , 'markerfill' , 'w');
        tAdd = FCTR{1};
        for f =2:length(FCTR)
            tAdd = [tAdd , ' and ' , FCTR{f}];
        end
        title(['Effect of ' , tAdd ,' on Execution Time']);
        grid on
        set(gca , 'FontSize' , 20 , 'Box' , 'off')
        xlabel(FCTR{end})
        ylabel('msec')
    case 'IPI'
        switch whatIPI
            case 'ipiOfInterest'
                ipi = ANA.IPI(:,ipiOfInterest);
                A.IPI = reshape(ipi , numel(ipi) , 1);
                A.Horizon = repmat(ANA.Horizon , size(ipi , 2) , 1);
                A.Day = repmat(ANA.Day , size(ipi , 2) , 1);
                A.seqNumb = repmat(ANA.seqNumb , size(ipi , 2) , 1);
                A.SN = repmat(ANA.SN , size(ipi , 2) , 1);
                var = [];
                for f = 1:length(FCTR)
                    eval(['var = [var A.',FCTR{f},'];']);
                end
                stats = anovaMixed(A.IPI  , A.SN ,'within',var ,FCTR,'intercept',1) ;
                figure('color' , 'white')
                lineplot(var, A.IPI, 'style_thickline');
                title(['Effect of ' , FCTR , ' on ' , what]);
            case 'ipiOfInterestToSS'
                figure('color' , 'white')
                ANA1 = getrow(Dall , Dall.isgood & ~Dall.isError & ...
                    ismember(Dall.Day , Day) & ismember(Dall.seqNumb , seqNumb));
                subplot(211)
                ipiNum = repmat([1:size(ANA1.AllPress , 2)-1] , size(ANA1.IPI , 1) , 1);
                ipiNum(ismember(ipiNum , [4:10])) = 7 ; % steady state
                H = repmat(ANA1.Horizon , 1 , size(ANA1.AllPress , 2)-1);
                index = fliplr([reshape(ipiNum , numel(ipiNum) , 1) reshape(H, numel(H) , 1)]);
                data  = reshape(ANA1.IPI , numel(ANA1.IPI) , 1);
                lineplot(index , data , 'style_shade');
                hold on
                midPlaces = [3.1 : 5.2:3.1+8*5.2];
                for m = 1:length(midPlaces)
                    line([midPlaces(m) midPlaces(m)],[min(min(ANA1.IPI)) max(max(ANA1.IPI))] , 'color' , 'k')
                end
                
                ipiss = ANA.IPI(:,4:10);
                ipibeg = ANA.IPI(:,ipiOfInterest);
                
                label = [ones(numel(ipibeg) , 1) ;zeros(numel(ipiss) ,1)];
                A.IPI = [reshape(ipibeg , numel(ipibeg) , 1);reshape(ipiss , numel(ipiss) , 1)];
                A.Horizon = repmat(ANA.Horizon , size(ipibeg , 2)+size(ipiss , 2) , 1);
                A.Day = repmat(ANA.Day , size(ipibeg , 2)+size(ipiss , 2) , 1);
                A.seqNumb = repmat(ANA.seqNumb , size(ipibeg , 2)+size(ipiss , 2) , 1);
                A.SN = repmat(ANA.SN , size(ipibeg , 2)+size(ipiss , 2) , 1);
                var = [];
                for f = 1:length(FCTR)
                    eval(['var = [var A.',FCTR{f},'];']);
                end
                var = [var label];
                FCTR = [FCTR , 'beg/end vs SS'];
                tAdd = FCTR{1};
                for f =2:length(FCTR)
                    tAdd = [tAdd , ' and ' , FCTR{f}];
                end
                stats = anovaMixed(A.IPI  , A.SN ,'within',var ,FCTR,'intercept',1) ;
                subplot(212)
                lineplot(var, A.IPI, 'style_thickline');
                title(['Effect of ' , tAdd , ' on ' , what ,' , 0 is steady state']);
            case 'AllToSS'
                calc = 0;
                if calc
                    if poolDays
                        Day = {[1] , [2 3] , [4 5]};
                    else
                        Day = {[1] [2] [3] [4] , [5]};
                    end
                    H =[1:8 , 13];
                    ipi = [1 2 3 11 12 13];
                    for sn = 0:2
                        for h = 1:length(H)
                            for d = 1:length(Day)
                                for p = 1:length(ipi)
                                    stats = se2_SigTest(Dall , 'IPI' , 'seqNumb' , [sn] , 'Day' , Day{d} , 'Horizon' , [H(h)],'PoolSequences' , 1,...
                                        'PoolDays' , 1,'whatIPI','ipiOfInterestToSS','PoolHorizons',0,'ipiOfInterest' , ipi(p));
                                    pval{sn+1 , d}(h,p) = stats.eff(2).p;
                                    close all
                                    
                                end
                            end
                        end
                    end
                    save('/Users/nkordjazi/Documents/SeqEye/SeqEye2/analyze/se2_IPIsigTest.mat' , 'pval')
                else
                    load('/Users/nkordjazi/Documents/SeqEye/SeqEye2/analyze/se2_IPIsigTest.mat')
                end
                i = 1;
                SN = {'Random' , 'Sructure 1,4 4 3 3' , 'Structure 2, 3 4 3 4'};
                Days = {'Day 1' , 'Days 2, 3' , 'Days 4, 5'};
                figure('color' , 'white')
                for d = 1:3
                    for sn = 1:3
                        subplot(3,3,i)
                        A = ones(9,13);
                        A (:,1:3)   = pval{sn , d}(:,1:3);
                        A (:,11:13) = pval{sn , d}(:,4:6);
                        A(A<=0.05) = 2;
                        A(A~=2 & A~=1) = 0;
                        imagesc(A)
                        title([SN{sn} , ' on ' , Days{d}])
                        hold on
                        for h = .5:1:11.5
                            line([h+1 h+1], [.5 9.5] , 'color' , 'k' , 'LineWidth' , 2);
                        end
                        for p = .5:1:7.5
                            line([.5 13.5] ,[p+1 p+1], 'color' , 'k' , 'LineWidth' , 2);
                        end
                        set(gca , 'XTick' , [1:13] , 'YTick' , [1:9] , 'YTickLabel' , [1:8 , 13] , 'FontSize' , 16);
                        xlabel('IPI number')
                        ylabel('Viewing Horizon Size')
                        i = i +1;
                    end
                end
                
                stats = pval;
            case 'WithBetRand'
                ipiss = ANA.IPI(:,4:10);
                FCTR = FCTR(~strcmp(FCTR,'seqNumb'));
                nn= ipiOfInterest;
                mm= poolIPIs;
                ipiLab = {'Random' , 'Between','Within'};
                ipiLab = ipiLab(nn+1);
                L = ipiLab{1};
                for l = 2:length(ipiLab)
                    L = [L,'/',ipiLab{l}];
                end
                A.IPIArr= reshape(ANA.IPIarrangement(:,4:10) , numel(ipiss) , 1);
                switch mm
                    case{1}
                        A.IPIArr(A.IPIArr==1) = 0;
                    case {2}
                        A.IPIArr(A.IPIArr==2) = 1;
                end
                A.IPI = reshape(ipiss , numel(ipiss) , 1);
                A.Horizon = repmat(ANA.Horizon , size(ipiss , 2) , 1);
                A.Day = repmat(ANA.Day , size(ipiss , 2) , 1);
                A.seqNumb = repmat(ANA.seqNumb , size(ipiss , 2) , 1);
                A.SN = repmat(ANA.SN , size(ipiss , 2) , 1);
                A = getrow(A , ismember(A.IPIArr , nn));
                %% sig test on the IPIs
                var = [];
                for f = 1:length(FCTR)
                    eval(['var = [var A.',FCTR{f},'];']);
                end
                if length(ipiLab)>1
                    var = [A.IPIArr var];
                    FCTR = [L FCTR];
                end
                stats = anovaMixed(A.IPI  , A.SN ,'within',var ,FCTR,'intercept',1) ;
                %% sig test on the median IPIs
%                 B = tapply(A , {'Horizon' , 'Day' ,'SN' , 'seqNumb','IPIArr'} , {'IPI' , 'nanmedian(x)'});
%                 var = [];
%                 for f = 1:length(FCTR)
%                     eval(['var = [var B.',FCTR{f},'];']);
%                 end
%                 if length(ipiLab)>1
%                     var = [B.IPIArr var];
%                     FCTR = [L FCTR];
%                 end
%                 stats = anovaMixed(B.IPI  , B.SN ,'within',var ,FCTR,'intercept',1) ;
                %%
                
                var = [];
                for f = 1:length(FCTR)
                    eval(['var = [var A.',FCTR{f},'];']);
                end
                if length(ipiLab)>1
                    var = [A.IPIArr var];
                    FCTR = [L FCTR];
                end
                figure('color' , 'white')
                lineplot(var, A.IPI , 'style_shade' , 'markertype' , 'o'  , ...
                    'markersize' , 10 , 'markerfill' , 'w');
                tAdd = FCTR{1};
                for f =2:length(FCTR)
                    tAdd = [tAdd , ' and ' , FCTR{f}];
                end
                title(['Effect of ' , tAdd ,' on Execution Time']);
                grid on
                set(gca , 'FontSize' , 20 , 'Box' , 'off')
                xlabel(FCTR{end})
                ylabel('msec')
        end
    case 'RT'
        var = [];
        for f = 1:length(FCTR)
            eval(['var = [var ANA.',FCTR{f},'];']);
        end
        stats = anovaMixed(ANA.RT  , ANA.SN ,'within',var ,FCTR,'intercept',1) ;
        figure('color' , 'white')
        lineplot(var, ANA.RT-1500, 'style_thickline');
        title(['Effect of ' , FCTR , ' on ' , what]);
end