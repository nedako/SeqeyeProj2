function stats = se2_SigTest(Dall , what , varargin)

c=  1;
while(c<=length(varargin))
    switch(varargin{c})
        case {'seqNumb'}
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
            % in what way to test the IPIs
            % 'testBegVsSS' test the start IPIs vs steady state
            % 'testEndVsSS' test the end IPIs vs steady state
            % 'steadyState' test Steady state
            % 'testBegHorz' test if there's an interaction between how many are faster at the beginning and horizon size
            % 'testEndHorz' test if there's an interaction between how many are faster at the end and horizon size
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
seqNumb(seqNumb>1) = 1;
seqNumb = unique(seqNumb);
ANA.seqNumb(ANA.seqNumb == 2) = 1;
ANA.Day(ANA.Day == 3) = 2;
ANA.Day(ismember(ANA.Day , [4,5])) = 3;

Day(Day==3) = 2;
Day(ismember(Day , [4 5])) = 3;
Day = unique(Day);

factors = {'Horizon' , 'Day' , 'seqNumb'};
facInclude = [length(Horizon)>1 , length(Day)>1  , length(seqNumb)>1];
FCTR =  factors(facInclude);

switch what
    case 'MT'
        var = [];
        for f = 1:length(FCTR)
            eval(['var = [var ANA.',FCTR{f},'];']);
        end
        stats = anovaMixed(ANA.MT  , ANA.SN ,'within',var ,FCTR,'intercept',1) ;
        figure('color' , 'white')
        lineplot(var, ANA.MT , 'style_thickline');
        title(['Effect of ' , FCTR , ' on ' , what]);
    case 'IPI'
        switch whatIPI
            case 'steadyState'
                ipi = ANA.IPI(:,4:10);
                %         ipi = ANA.IPI(:,1:3);
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
            case 'testBegVsSS'
                ipiss = ANA.IPI(:,4:10);
                ipibeg = ANA.IPI(:,1:3);
                label = [ones(size(ANA.IPI(:,1:3))) zeros(size(ANA.IPI(:,4:10)))];
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
            case 'testEndVsSS'
            case 'testBegHorz'
            case 'testEndHorz'
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