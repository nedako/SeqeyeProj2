
function out  = se2_pubFigs(Dall , what, nowWhat , varargin)

subj_name = {'AT1' , 'CG1' , 'HB1' , 'JT1' , 'CB1' , 'YM1' , 'NL1' , 'SR1' , 'IB1' , 'MZ1' , 'DW1', 'RA1' ,'CC1', 'All'};
%% Define defaults
subjnum = length(subj_name); % all subjects
Repetition = [1 2];
poolDays = 0;
%% Deal with inputs
c = 1;
while(c<=length(varargin))
    switch(varargin{c})
        case {'subjnum'}
             % define the subject 
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'Repetition'}
            % Repetitions to include
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'poolDays'}
            % pool together days 2,3 and days 4 5
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        otherwise
            error('Unknown option: %s',varargin{c});
    end
end

%%
prefix = 'se1_';
baseDir = '/Users/nedakordjazi/Documents/SeqEye/SeqEye2/analyze';     %macbook
% baseDir = '/Users/nkordjazi/Documents/SeqEye/SeqEye2/analyze';          %iMac


colors = [0 0 1;...
    0 1 0;...
    1 0 0;...
    0 1 1;...
    1 0 1;...
    1 0.69 0.39;...
    0.6 0.2 0;...
    0 0.75 0.75;...
    0.22 0.44 0.34;...
    0.32 0.19 0.19];
if subjnum == length(subj_name)
    %     subjnum = [1 3:length(subj_name)-1];
    subjnum = 1:length(subj_name)-1;
end


days  = {1 ,2 ,3 ,4 ,5,[1:5] ,[2:5] [2:3] [4:5],[3:5]};
if poolDays
    dayz = {1 [2 3] [4 5]};
else
    dayz = {[1] [2] [3] [4] [5]};
end
switch what
    
    case 'MT'
         ANA = getrow(Dall , ismember(Dall.SN , subjnum) & Dall.isgood & ismember(Dall.seqNumb , [0 1 2]) & ~Dall.isError);
        ANA.seqNumb(ANA.seqNumb == 2) = 1;
        MT  = ANA;%tapply(ANA , {'Horizon' , 'Day' ,'SN' , 'seqNumb','BN'} , {'MT' , 'nanmedian(x)'});
        
        MT = getrow(MT , MT.MT <= 9000 );
        h1 = figure('color' , 'white');
        for d=  1:length(dayz)
            hc = 1;
            [xcoords{d},PLOTs{d},ERRORs{d}] = lineplot(MT.Horizon,MT.MT , 'plotfcn' , 'nanmedian' , 'subset' , MT.seqNumb == 1 & ismember(MT.Day , dayz{d}));
            hold on
            [xcoordr{d},PLOTr{d},ERRORr{d}] = lineplot(MT.Horizon,MT.MT , 'plotfcn' , 'nanmedian' , 'subset' , MT.seqNumb == 0 & ismember(MT.Day , dayz{d}));
            
        end
        close(h1);

      
        colz_s = {[153, 194, 255]/255 , [77, 148, 255]/255,[0, 102, 255]/255,[0, 71, 179]/255, [0, 41, 102]/255};
        colz_r = {[255, 153, 179]/255 , [255, 77, 121]/255,[255, 0, 64]/255,[179, 0, 45]/255, [102, 0, 26]/255};
        if poolDays
            sigSeq = [NaN 3 2];
            sigMT  = [3 4 5;4 5 4];
        else
            sigSeq = [NaN 3 3 2 2];
            sigMT  = [3 4 4 6 3;4 3 4 4 4];
        end
        
        switch nowWhat
            case 'RandvsStructCommpare'
                figure('color' , 'white');
                for d=  1:length(dayz)
                    subplot(1,length(dayz),d)
                    h1 = plotshade(xcoords{d}',PLOTs{d} , ERRORs{d},'transp' , .5 , 'patchcolor' , colz_s{d} ,...
                        'linecolor' ,colz_s{d} , 'linewidth' , 3 );
                    hold on
                    h2 = plotshade(xcoordr{d}',PLOTr{d} , ERRORr{d},'transp' , .5 , 'patchcolor' , colz_r{d} , 'linecolor' , colz_r{d} , 'linewidth' , 3 );
                    set(gca,'FontSize' , 40 , 'XTick' , [1:8,13] , 'XTickLabel' , {'1' '2' '3' '4' '5' '6' '7' '8' '13'} , ...
                        'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [2400 7000],'YTick' , [4000 5000 6000] ,...
                        'YTickLabels' , [4 5 6] , 'YGrid' , 'on','XLim' , [1 13]);
                    %             title(['Execution time - Training Session(s) ' , num2str(dayz{d})])
                    ylabel('Sec' )
                    xlabel('Viewing Horizon Size' )
                    hold on
                    plot(xcoords{d},PLOTs{d} , 'o' , 'MarkerSize' , 10 , 'color' , colz_s{d},'MarkerFaceColor',colz_s{d})
                    plot(xcoords{d},PLOTr{d} , 'o' , 'MarkerSize' , 10 , 'color' , colz_r{d},'MarkerFaceColor',colz_r{d})
                    patch([sigSeq(d) 13 13 sigSeq(d)],[2400 2400 2600 2600] , (colz_s{d}+colz_r{d})/2,'EdgeColor' , 'none','FaceAlpha',1)
                    line([sigSeq(d) sigSeq(d)] , [2400 6800] , 'color' , (colz_s{d}+colz_r{d})/2 , 'LineWidth' , 3 , 'LineStyle' , ':')
                    %             legend([h1 h2] ,{'Structured Sequences' , 'Random Sequences'})
                end
            case 'RandStructAcrossDays'
                figure('color' , 'white');
                subplot(1,2,1);hold on
                for d=1:length(dayz)
                    h1 = plotshade(xcoords{d}',PLOTs{d} , ERRORs{d},'transp' , .5 , 'patchcolor' , colz_s{d} , 'linecolor' , colz_s{d} , 'linewidth' , 3);
                    plot(xcoords{d},PLOTs{d} , 'o' , 'MarkerSize' , 10 , 'color' , colz_s{d},'MarkerFaceColor',colz_s{d});
                    patch([1 sigMT(2,d) sigMT(2,d) 1],[6800+(d-1)*200 6800+d*200 6800+d*200 7000+(d-1)*200] , colz_s{d},'EdgeColor' , 'none','FaceAlpha',.6)
                    line([sigMT(2,d) sigMT(2,d)] , [PLOTs{d}(sigMT(2,d)) 7000+(d-1)*200] , 'color' , colz_s{d} , 'LineWidth' , 3 , 'LineStyle' , ':')
                end
                set(gca,'FontSize' , 20 , 'XTick' , [1:8,13] , 'XTickLabel' , {'1' '2' '3' '4' '5' '6' '7' '8' '13'} , ...
                    'GridAlpha' , .2 , 'Box' , 'off' , 'XLim' , [1 13], 'YLim' , [3500 8000],'YTick' ,...
                    [ 4000 5000 6000] , 'YTickLabels' , [4 5 6], 'YGrid' , 'on');
                title(['Execution time for Structured Sequences'])
                ylabel('Sec' )
                xlabel('Viewing Horizon' )
%                 legend([h1 h2 h3] ,{'Training Session 1' , 'Training Sessions 2,3' , 'Training Sessions 4,5'})
                
                subplot(1,2,2);hold on
                for d=1:length(dayz)
                    h1 = plotshade(xcoordr{d}',PLOTr{d} , ERRORr{d},'transp' , .5 , 'patchcolor' , colz_r{d} , 'linecolor' , colz_r{d} , 'linewidth' , 3);
                    plot(xcoordr{d},PLOTr{d} , 'o' , 'MarkerSize' , 10 , 'color' , colz_r{d},'MarkerFaceColor',colz_r{d});
                    patch([1 sigMT(1,d) sigMT(1,d) 1],[6800+(d-1)*200 6800+d*200 6800+d*200 7000+(d-1)*200] , colz_r{d},'EdgeColor' , 'none','FaceAlpha',.6)
                    line([sigMT(1,d) sigMT(1,d)] , [PLOTr{d}(sigMT(1,d)) 7000+(d-1)*200] , 'color' , colz_r{d} , 'LineWidth' , 3 , 'LineStyle' , ':')
                end
                set(gca,'FontSize' , 20 , 'XTick' , [1:8,13] , 'XTickLabel' , {'1' '2' '3' '4' '5' '6' '7' '8' '13'} , ...
                    'GridAlpha' , .2 , 'Box' , 'off' , 'XLim' , [1 13], 'YLim' , [3500 8000],'YTick' ,...
                    [4000 5000 6000] , 'YTickLabels' , [4 5 6] , 'YGrid' , 'on');
                ylabel('Sec' )
                xlabel('Viewing Horizon' )
%                 legend([h1 h2 h3] ,{'Session 1' , 'Sessions 2,3' , 'Sessions 4,5'})
                title(['Execution time for Random Sequences'])
            case 'BoxAcrossDays'
                %% THE BOX PLOTS
                
                xs = zeros(3,9);
                % text x locations
                xs(1,:) = 1:2.4:2.4*9;
                for xx = 1:9
                    for d = 2:length(dayz)
                        xs(d,xx) = xs(d-1,xx)+.7;
                    end
                end
                xs = xs(:);
                % text colors
                d_cols = repmat([1:3]' , 1 , 9);
                d_cols = d_cols(:);
                % star or no star
                sigstars_r = cell(3,9);
                sigstars_r(1,:) = {'*' , '*' , '*' ,'','','','','',''};
                sigstars_r(2,:) = {'*' , '*' , '*' ,'','','','','',''};
                sigstars_r(3,:) = {'*' , '*' , '*' ,'*','','','','',''};
                sigstars_r = sigstars_r(:);
                sigstars_s = cell(3,9);
                sigstars_s(1,:) = {'*' , '*' , '*' ,'','','','','',''};
                sigstars_s(2,:) = {'*' , '*' , '*' ,'','','','','',''};
                sigstars_s(3,:) = {'*' , '*' , '*' ,'','','','','',''};
                sigstars_s = sigstars_s(:);
                ystar_r = zeros(3,9);
                ystar_s = zeros(3,9);
                c = 1;
                for h = [1:8,13]
                    for d = 1:3
                        M = getrow(MT , MT.seqNumb==0 & ismember(MT.Day , dayz{d}) & MT.Horizon==h);
                        ystar_r(d,c) = (std(M.MT)/sqrt(length(M.MT)))+max(M.MT);
                        M = getrow(MT , MT.seqNumb~=0 & ismember(MT.Day , dayz{d}) & MT.Horizon==h);
                        ystar_s(d,c) = (std(M.MT)/sqrt(length(M.MT)))+max(M.MT);
                    end
                    c = c+1;
                end
                ystar_r = ystar_r(:);
                ystar_s = ystar_s(:);
                
                
                figure('color' , 'white');
                xs_labs = repmat({'S1' , 'S2,3' , 'S4,5'} , 1, 9);
                
                subplot(211);hold on
                M = getrow(MT , MT.seqNumb~=0);
                M.Day(ismember(M.Day , [2 3])) = 2;
                M.Day(ismember(M.Day , [4 5])) = 3;
                myboxplot(M.Horizon ,M.MT, 'notch',1 ,'plotall',0, 'fillcolor',colz_s,'linecolor',colz_s,...
                    'whiskerwidth',3,'split' , M.Day,'xtickoff' );
                hold on
                for xl = 1:length(xs)
                    text(xs(xl) , ystar_s(xl) , sigstars_s{xl} ,'FontSize' , 40,'color',colz_s{d_cols(xl)})
                end
                
                % title('Structured')
                set(gca,'FontSize' , 40 ,  ...
                    'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [0 9000],...
                    'YTick' , [1000 2000 3000 4000 5000 6000 7000 8000] , 'YTickLabels' , [1 2 3 4 5 6 7 8],...
                    'XTickLabelRotation' , 30, 'YGrid' , 'on');%,'XTick' , xs , 'XTickLabel' , xs_labs ,);
                ylabel('Sec')
                subplot(212);hold on
                M = getrow(MT , MT.seqNumb==0);
                M.Day(ismember(M.Day , [2 3])) = 2;
                M.Day(ismember(M.Day , [4 5])) = 3;
                myboxplot(M.Horizon ,M.MT, 'notch',1 ,'plotall',0, 'fillcolor',colz_r,'linecolor',colz_r,...
                    'whiskerwidth',3,'split' , M.Day,'xtickoff');
                ylabel('Sec')
                % title('Random')
                
                set(gca,'FontSize' , 40 ,  ...
                    'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [0 9000],...
                    'YTick' , [1000 2000 3000 4000 5000 6000 7000 8000] , 'YTickLabels' , [1 2 3 4 5 6 7 8],...
                    'XTickLabelRotation' , 30, 'YGrid' , 'on');%,'XTick' , xs , 'XTickLabel' , xs_labs ,);
                
                hold on
                for xl = 1:length(xs)
                    text(xs(xl) , ystar_r(xl) , sigstars_r{xl} ,'FontSize' , 40,'color',colz_r{d_cols(xl)})
                end
            case 'BoxAcrosSeqType'
                %% BOX PLOT 2
                xs = zeros(2,9);
                % text x locations
                xs(1,:) = 1:1.7:1.7*9;
                for xx = 1:9
                    xs(2,xx) = xs(1,xx)+.7;
                end
                xs = xs(:);
                % text colors
                d_cols = repmat([1 2]' , 1 , 9);
                d_cols = d_cols(:);
                % star or no star
                sigstars(1,:) = {'' , '' , '' ,'','','','','','','' , '' , '' ,'','','','','',''};
                sigstars(2,:) = {'' , '' , '' ,'','*','*','*','*','*','*' , '*' , '*' ,'*','*','*','*','*','*'};
                sigstars(3,:) = {'' , '' , '*' ,'*','*','*','*','*','*','*' , '*' , '*' ,'*','*','*','*','*','*'};
                
                figure('color' , 'white');
                colz_s = {[128, 223, 255]/255 , [26, 198, 255]/255, [0, 134, 179]/255};
                colz_r = {[255, 128, 159]/255 , [255, 26, 83]/255, [179, 0, 45]/255};
                for d = 1:length(dayz)
                    cols = {colz_r{d} colz_s{d}};
                    subplot(3,1,d);hold on
                    M = getrow(MT , ismember(MT.Day , dayz{d}));
                    myboxplot(M.Horizon ,M.MT, 'notch',1 ,'plotall',0, 'fillcolor',cols,'linecolor',cols,...
                        'whiskerwidth',3,'split' , M.seqNumb,'xtickoff');
                    hold on
                    ystar = zeros(2,9);
                    c = 1;
                    for h = [1:8,13]
                        for sn = 0:1
                            M = getrow(MT , MT.seqNumb==0 & ismember(MT.Day , dayz{d}) & MT.Horizon==h);
                            ystar(sn+1,c) = (std(M.MT)/sqrt(length(M.MT)))+max(M.MT);
                            M = getrow(MT , MT.seqNumb~=0 & ismember(MT.Day , dayz{d}) & MT.Horizon==h);
                            ystar(sn+1,c) = (std(M.MT)/sqrt(length(M.MT)))+max(M.MT);
                        end
                        c = c+1;
                    end
                    ystar = ystar(:);
                    for xl = 1:length(xs)
                        text(xs(xl) , ystar(xl) , sigstars{d,xl} ,'FontSize' , 40,'color',cols{d_cols(xl)})
                    end
                    xs_labs = repmat({'Random' , 'Structured'} , 1, 9);
                    % title('Structured')
                    set(gca,'FontSize' , 30 ,  ...
                        'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [0 9000],...
                        'YTick' , [1000 2000 3000 4000 5000 6000 7000 8000] , 'YTickLabels' , [1 2 3 4 5 6 7 8],...
                        'XTickLabelRotation' , 30,'YGrid' , 'on');%'XTick' , xs , 'XTickLabel' , xs_labs )
                    ylabel('Sec')
                end
            case 'LearningEffectHeat'
                %%
                
                h1 = figure('color' , 'white');
                hold on
                M.Day = MT.Day;
                %         M.Day(ismember(M.Day ,[2,3])) = 2;
                %         M.Day(ismember(M.Day,[4,5])) = 3;
                h = 1;
                for hc  = [1:8 13]
                    [xcoords_med{h},PLOTs_med{h},ERRORs_med{h}] = lineplot([MT.seqNumb M.Day],MT.MT , 'plotfcn' , 'nanmean' , 'subset' ,  ismember(MT.Horizon , [hc]) & ismember(MT.seqNumb , 1));
                    [xcoordr_med{h},PLOTr_med{h},ERRORr_med{h}] = lineplot([MT.seqNumb M.Day],MT.MT , 'plotfcn' , 'nanmean' , 'subset' ,  ismember(MT.Horizon , [hc]) & ismember(MT.seqNumb , 0));
                    h  = h + 1;
                end
                close(h1)
                
                
                subplot(121)
                imagesc(cell2mat(PLOTs_med') , [2500 7000])
                set(gca , 'XTick' , [1:length(unique(M.Day))] , 'YTick', [1:9] , 'YTickLabels' , [1 :8 , 13],'FontSize' , 20)
                title('Execution Time in  Structured Sequences')
                ylabel('Viewing Horizon Size')
                xlabel('Training Session')
                
                subplot(121)
                imagesc(cell2mat(PLOTr_med'), [2500 7000])
                colorbar
                set(gca , 'XTick' , [1:length(unique(M.Day))] , 'YTick', [1:9] , 'YTickLabels' , [1 :8 , 13],'FontSize' , 20)
                title('Execution Time in  Random Sequences')
                ylabel('Viewing Horizon Size')
                xlabel('Training Session')
            case 'LearningEffectShade'
                % lump h = 6 and  up together
                MT.Horizon(MT.Horizon>5) = 5;
                h1 = figure('color' , 'white');
                for d=  1:length(dayz)
                    hc = 1;
                    [xcoords{d},PLOTs{d},ERRORs{d}] = lineplot(MT.Horizon,MT.MT , 'plotfcn' , 'nanmedian' , 'subset' , MT.seqNumb == 1 & ismember(MT.Day , dayz{d}));
                    hold on
                    [xcoordr{d},PLOTr{d},ERRORr{d}] = lineplot(MT.Horizon,MT.MT , 'plotfcn' , 'nanmedian' , 'subset' , MT.seqNumb == 0 & ismember(MT.Day , dayz{d}));
                end
                close(h1);
                figure('color' , 'white');
                subplot(121)
                hold on
                P = cell2mat(PLOTs')';
                E = cell2mat(ERRORs')';
                X = cell2mat(xcoords')';
                % the patch color represents the horizon size
                horzcolor = linspace(0.2,.8 , length(unique(MT.Horizon)));
                for i = 1:length(unique(MT.Horizon))
                    h1 = plotshade([1:length(dayz)],P(i,:) , E(i,:),'transp' , .5 , 'patchcolor' , repmat(horzcolor(i) , 1,3) , 'linecolor' , colz_s{3} , 'linewidth' , 3);
                    plot([1:length(dayz)],P(i,:) , '-o' , 'MarkerSize' , 10 , 'color' , colz_s{3},'MarkerFaceColor',repmat(horzcolor(i) , 1,3) , 'LineWidth' , 3);
                end
                set(gca,'FontSize' , 20 , 'XTick' , [1:length(dayz)] , ...
                    'GridAlpha' , .2 , 'Box' , 'off' , 'XLim' , [1 length(dayz)], 'YLim' , [2500 7000],'YTick' ,...
                    [3000 4000 5000 6000] , 'YTickLabels' , [3 4 5 6] , 'YGrid' , 'on');
                ylabel('Sec' )
                xlabel('Training Session')
                
                subplot(122)
                hold on
                P = cell2mat(PLOTr')';
                E = cell2mat(ERRORr')';
                X = cell2mat(xcoordr')';
                % the patch color represents the horizon size
                horzcolor = linspace(0.2,.8 , length(unique(MT.Horizon)));
                for i = 1:length(unique(MT.Horizon))
                    h1 = plotshade([1:length(dayz)],P(i,:) , E(i,:),'transp' , .5 , 'patchcolor' , repmat(horzcolor(i) , 1,3) , 'linecolor' , colz_r{3} , 'linewidth' , 3);
                    plot([1:length(dayz)],P(i,:) , '-o' , 'MarkerSize' , 10 , 'color' , colz_r{3},'MarkerFaceColor',repmat(horzcolor(i) , 1,3), 'LineWidth' , 3);
                end
                set(gca,'FontSize' , 20 , 'XTick' , [1:length(dayz)] , ...
                    'GridAlpha' , .2 , 'Box' , 'off' , 'XLim' , [1 length(dayz)], 'YLim' , [2500 7000],'YTick' ,...
                    [3000 4000 5000 6000] , 'YTickLabels' , [3 4 5 6] , 'YGrid' , 'on');
                ylabel('Sec' )
                xlabel('Training Session')

                
            case 'compareLearning'
                MT.Horizon(MT.Horizon>5) = 5;
                h1 = figure('color' , 'white');
                for d=  1:length(dayz)
                    hc = 1;
                    [xcoords{d},PLOTs{d},ERRORs{d}] = lineplot(MT.Horizon,MT.MT , 'plotfcn' , 'nanmedian' , 'subset' , MT.seqNumb == 1 & ismember(MT.Day , dayz{d}));
                    hold on
                    [xcoordr{d},PLOTr{d},ERRORr{d}] = lineplot(MT.Horizon,MT.MT , 'plotfcn' , 'nanmedian' , 'subset' , MT.seqNumb == 0 & ismember(MT.Day , dayz{d}));
                end
                close(h1);
                horzcolor = linspace(0.2,.8 , length(unique(MT.Horizon)));
                As = cell2mat(PLOTs');
                Bs = cell2mat(ERRORs');
                Ar = cell2mat(PLOTr');
                Br = cell2mat(ERRORr');
                horz = {[1] [2] [3] [4] [5:9]};
                hlab = repmat({'1' , '2' , '3' , '4'  , '5 - 13'} , 1 , length(dayz));
                figure('color' , 'white')
                hold on
                allX = [];
                for i = [1: length(dayz)]
                    X = ((i-1)*(length(horz)))+[1:length(horz)];
                    plotshade(X , As(i,:) , Bs(i,:),'transp' , .5 , 'patchcolor' , colz_s{i}  , 'linecolor' , colz_s{i} , 'linewidth' , 3);
                    plot(X , As(i,:) , '-o' , 'MarkerSize' , 10 , 'color' , colz_s{i} ,'MarkerFaceColor',colz_s{i}  , 'LineWidth' , 3);
                    plotshade(X , Ar(i,:) , Br(i,:),'transp' , .5 , 'patchcolor' , colz_r{i}  , 'linecolor' , colz_r{i} , 'linewidth' , 3);
                    plot(X , Ar(i,:) , '-o' , 'MarkerSize' , 10 , 'color' , colz_r{i} ,'MarkerFaceColor',colz_r{i}  , 'LineWidth' , 3);
                    allX = [allX X];
                end
                set(gca,'FontSize' , 20 , 'XTick' , allX , ...
                    'GridAlpha' , .2 , 'Box' , 'off' , 'XLim' , [1 max(X)], 'YLim' , [2500 7000],'YTick' ,...
                    [3000 4000 5000 6000] , 'YTickLabels' , [3 4 5 6] , 'YGrid' , 'on','XTickLabels',hlab);
                    xlabel('Viewing Window Size')
                    ylabel('sec')
        end
        out = [];
    case 'IPI'
        structNumb = input('Which structure? (1/2)');
        %         plotfcn = input('nanmean or nanmedian?' , 's');
        %% IPIs vs horizon
        % this is the output of the case: 'transitions_All' that is saved to disc
        if ~ calc
            load([baseDir , '/se2_TranProb.mat'] , 'All');
            newANA = All;
            newANA = getrow(newANA , ismember(newANA.Day , days{day}));
        else
            ANA = getrow(Dall , ismember(Dall.SN , subjnum) & Dall.isgood & ismember(Dall.seqNumb , [0 , structNumb])  & ~Dall.isError & ismember(Dall.Day , days{day}));
            
            for tn = 1:length(ANA.TN)
                n = (ANA.AllPressIdx(tn , sum(~isnan(ANA.AllPressIdx(tn , :))))  - ANA.AllPressIdx(tn , 1)) / 1000;
                nIdx(tn , :) = (ANA.AllPressIdx(tn , :) - ANA.AllPressIdx(tn , 1))/n;
                ANA.IPI_norm(tn , :) = diff(nIdx(tn ,:) , 1 , 2);
            end
            for tn  = 1:length(ANA.TN)
                ANA.ChunkBndry(tn , :) = diff(ANA.ChnkArrang(tn,:));
                a = find(ANA.ChunkBndry(tn , :));
                ANA.ChunkBndry(tn , a-1) = 3;
                ANA.ChunkBndry(tn , end) = 3;
                ANA.ChunkBndry(tn , ANA.ChunkBndry(tn , :) == 0) = 2;
                ANA.ChunkBndry(tn , 1:2) = [-1 -1];  % dont account for the first and last sseqeuce presses
                ANA.ChunkBndry(tn , end-1:end) = [-2 -2];% dont account for the first and last sseqeuce presses
                ANA.IPI_Horizon(tn , :) = ANA.Horizon(tn)*ones(1,13);
                ANA.IPI_SN(tn , :) = ANA.SN(tn)*ones(1,13);
                ANA.IPI_Day(tn , :) = ANA.Day(tn)*ones(1,13);
                ANA.IPI_prsnumb(tn , :) = [1 :13];
                ANA.IPI_seqNumb(tn , :) = ANA.seqNumb(tn)*ones(1,13);
            end
            
            newANA.IPI = reshape(ANA.IPI , numel(ANA.IPI) , 1);
            newANA.ChunkBndry = reshape(ANA.ChunkBndry , numel(ANA.IPI) , 1);
            newANA.Horizon = reshape(ANA.IPI_Horizon , numel(ANA.IPI) , 1);
            newANA.SN  = reshape(ANA.IPI_SN , numel(ANA.IPI) , 1);
            newANA.Day = reshape(ANA.IPI_Day , numel(ANA.IPI) , 1);
            newANA.prsnumb = reshape(ANA.IPI_prsnumb , numel(ANA.IPI) , 1);
            newANA.seqNumb = reshape(ANA.IPI_seqNumb , numel(ANA.IPI) , 1);
            newANA.ChunkBndry(newANA.ChunkBndry>2) = 2;
        end
        IPItable  = tapply(newANA , {'Horizon' , 'Day' ,'SN' , 'seqNumb' , 'ChunkBndry' , 'prsnumb'} , {'IPI' , 'nanmedian(x)'});
        
        lineplot([IPItable.ChunkBndry IPItable.Day], IPItable.IPI, 'subset' , ismember(IPItable.Horizon,[3:13]) & ismember(IPItable.seqNumb, structNumb) & ~ismember(IPItable.ChunkBndry, [-1 , -2]))
        
        h0 = figure;
        hC = 1;
        for h = [1:8 , 13]
            [IPI0_x(hC,:),IPI0_plot(hC,:) , IPI0_plot_error(hC,:)] = lineplot(IPItable.prsnumb ,IPItable.IPI , 'subset' , IPItable.Horizon == h & ismember(IPItable.seqNumb , 0),'plotfcn' , 'nanmean');
            hold on
            [IPI1_x(hC,:),IPI1_plot(hC,: ), IPI1_plot_error(hC,:)] = lineplot(IPItable.prsnumb ,IPItable.IPI  , 'subset' , IPItable.Horizon == h & ismember(IPItable.seqNumb , structNumb) ,'plotfcn' , 'nanmean');
            hC = hC+1;
        end
        close(h0)
        
        
        h0 = figure;
        [x1 , plot1 , error1] = lineplot(IPItable.Horizon , IPItable.IPI , 'subset' , IPItable.ChunkBndry == 1 ,'plotfcn' , 'nanmean');
        hold on
        [x2 , plot2 , error2] = lineplot(IPItable.Horizon , IPItable.IPI , 'subset' , IPItable.ChunkBndry == 2 ,'plotfcn' , 'nanmean');
        
        close(h0)
        ChunkedIPI  = pivottable(newANA.Horizon, newANA.ChunkBndry, newANA.IPI ,'nanmedian(x)' , 'subset' , ~ismember(newANA.ChunkBndry ,[-1 -2]));
        
        
        out.IPI_allh = anovaMixed(IPItable.IPI , IPItable.SN , 'within' , [IPItable.ChunkBndry , IPItable.Horizon] , {'within/between' , 'horizon'} , 'subset' ,...
            ismember(IPItable.Horizon,[1:13]) & ismember(IPItable.seqNumb, structNumb) & ~ismember(IPItable.ChunkBndry, [-1 , -2]));
        for h = [1:8]
            temp = anovaMixed(IPItable.IPI , IPItable.SN , 'within' , [IPItable.ChunkBndry , IPItable.Horizon] , {'within/between' , 'horizon'} , 'subset' ,...
                ~ismember(IPItable.Horizon,[1:h]) & ismember(IPItable.seqNumb, structNumb) & ~ismember(IPItable.ChunkBndry, [-1 , -2]));
            out.W_B_IPI_not_h(h,1) = temp.eff(2).p;
        end
        out.W_B_IPI_not_h(h+1,1) = out.IPI_allh.eff(2).p;
        
        disp(['Effect of Between/within chunk on Chunked IPIs including all Horizons p val = ' , num2str(out.IPI_allh.eff(2).p)])
        for h  = [1:8]
            disp(['Effect of Between/within chunk on Chunked IPIs Excluding Horizons ',num2str([1:h]),' p val = ' , num2str(out.W_B_IPI_not_h(h))])
        end
        
        figure('color' , 'white');
        subplot(2,2,1)
        imagesc(IPI1_plot, [100 600]);
        colorbar
        hold on
        title(['Structure ' , num2str(structNumb) ,' - IPI vs Horizons'])
        xlabel('Press Number')
        set(gca,'FontSize' , 16, 'XTick' , [1:13] ,'YTick' , [1:9] , 'YTickLabel' ,...
            fliplr({'H = 13' 'H = 8' 'H = 7' 'H = 6' 'H = 5' 'H = 4' 'H = 3' 'H = 2' 'H = 1' }));
        axis square
        
        
        subplot(2,2,2)
        imagesc(IPI0_plot , [100 600]);
        colorbar
        title(['Random - IPI vs Horizons'])
        xlabel('Press Number'  ,'FontSize' , 10)
        ax.XTick = [1:13];
        set(gca,'FontSize' , 16, 'XTick' , [1:13] ,'YTick' , [1:9], ...
            'YTickLabel', fliplr({'H = 13' 'H = 8' 'H = 7' 'H = 6' 'H = 5' 'H = 4' 'H = 3' 'H = 2' 'H = 1' }));
        axis square
        
        
        
        
        subplot(2,2,3)
        for horzz = 1:9
            errorbar(IPI1_x(horzz,:)',IPI1_plot(horzz,:) , IPI1_plot_error(horzz,:) , 'LineWidth' , 3 , 'color' , colors(horzz  , :))
            hold on
        end
        
        title(['Structure ' , num2str(structNumb) , ' - Day ' , num2str(days{day})])
        grid on
        xlabel('Presses')
        ylabel('msec')
        set(gca,'FontSize' , 16, 'XTick' , [1:13] , 'YLim' , [100 600] , 'Box' , 'off' , 'GridAlpha' , 1);
        
        subplot(2,2,4)
        for horzz = 1:9
            errorbar(IPI0_x(horzz,:)',IPI0_plot(horzz,:) , IPI0_plot_error(horzz,:) , 'LineWidth' , 3 , 'color' , colors(horzz  , :))
            hold on
        end
        legend(fliplr({'H = 13' 'H = 8' 'H = 7' 'H = 6' 'H = 5' 'H = 4' 'H = 3' 'H = 2' 'H = 1' }))
        title(['Random - Day ' , num2str(days{day})])
        grid on
        xlabel('Presses')
        ylabel('msec')
        set(gca,'FontSize' , 16, 'XTick' , [1:13], 'YLim' , [100 600] , 'Box' , 'off' , 'GridAlpha' , 1);
        %%
        figure('color' , 'white');
        subplot(1,2,1)
        imagesc(ChunkedIPI);
        colorbar
        hold on
        set(gca,'FontSize' , 16 , 'XTick' , [1 :2] , 'XTickLabel' , {'First' , 'Middle' } , ...
            'YTickLabel' , fliplr({'H = 13' 'H = 8' 'H = 7' 'H = 6' 'H = 5' 'H = 4' 'H = 3' 'H = 2' 'H = 1' }))
        title('Median IPI vs Horizons in the Chunked sequences')
        
        
        subplot (1,2,2)
        h1 = plotshade(x1',plot1,error1,'transp' , .2 , 'patchcolor' , 'b' , 'linecolor' , 'b' , 'linewidth' , 3 , 'linestyle' , ':')
        hold on
        h2 = plotshade(x2',plot2,error2,'transp' , .2 , 'patchcolor' , 'm' , 'linecolor' , 'm' , 'linewidth' , 3 , 'linestyle' , ':')
        %errorbar(xcoord1,PLOT1,ERROR1,'LineWidth' , 3)
        %hold on
        %errorbar(xcoord2,PLOT2,ERROR2,'LineWidth' , 3)
        %errorbar(xcoord3,PLOT3,ERROR3,'LineWidth' , 3)
        hold on
        ax = gca;
        title('Chunked sequence IPIs vs horizon')
        xlabel('Horizon')
        ylabel('msec')
        legend([h1 h2] , {'First Chunk Press' , 'Middle Chunk Press' })
        grid on
        ax.XLim = [0 9];
        ax.FontSize = 16;
    case 'RT'
        ANA = getrow(Dall , ismember(Dall.SN , subjnum) & Dall.isgood & ~Dall.isError);
        RT = tapply(ANA , {'Horizon' , 'Day' ,'SN' , 'seqNumb','BN'} , {'pressTime0' , 'nanmedian(x)'});
        RT.pressTime0 = RT.pressTime0 - 1500;
        RT.seqNumb(RT.seqNumb == 2) = 1;
        dayz = {1 [2 3] [4 5]};
        figure('color' , 'white')
        for d=  1:length(dayz)
            h=figure('color' , 'white');
            [xcoord1,ePLOT1,ERROR1] = lineplot(RT.Horizon , RT.pressTime0 ,'subset', ismember(RT.seqNumb , [1]) & ismember(RT.Day , dayz{d}));
            hold on
            [xcoord0,ePLOT0,ERROR0] = lineplot(RT.Horizon , RT.pressTime0 ,'subset', ismember(RT.seqNumb , [0]) & ismember(RT.Day , dayz{d}));
            close(h)
            subplot(1,3,d)
            h1 = plotshade(xcoord1',ePLOT1,ERROR1,'transp' , .2 , 'patchcolor' , 'b' , 'linecolor' , 'b' , 'linewidth' , 3 , 'linestyle' , ':');
            hold on
            h2 = plotshade(xcoord0',ePLOT0,ERROR0,'transp' , .2 , 'patchcolor' , 'r' , 'linecolor' , 'r' , 'linewidth' , 3 , 'linestyle' , ':');
            grid on
            title(['initial reaction time - Training Session(s) ' , num2str(dayz{d})])
            ylabel('msec' )
            xlabel('Viewing Horizon' )
            legend([h1 h2] ,{'Structured Sequences' , 'Random Sequences'})
            set(gca ,'XTick' ,[1:8 , 13],'FontSize' , 20,'YLim', [600 850] , 'Box' , 'off');
        end
        out = [];
   
    case 'MT_asymptote'
        Hex = input('What horizons to exclude? (0 = include all)');
        ANA = getrow(Dall , Dall.isgood & ismember(Dall.seqNumb , [0 1 2]) & ~Dall.isError &~ismember(Dall.Horizon , Hex));
        ANA.seqNumb(ANA.seqNumb == 2) = 1;
        MT  = tapply(ANA , {'Horizon' , 'Day' ,'SN' , 'seqNumb'} , {'MT' , 'nanmedian(x)'});
        MT.MT_pred = zeros(size(MT.MT));
        MT.b1 = zeros(size(MT.MT));
        MT.b2 = zeros(size(MT.MT));
        MT.b3 = zeros(size(MT.MT));
        
        for d = 1:5
            for subjnum = 1:length(subj_name)-1
                [d subjnum 1]
                id = ismember(MT.SN , subjnum) & ismember(MT.Day , d) & ismember(MT.seqNumb , [1]);
                MTsn = getrow(MT , id);
                exp_model1 = @(b,x) b(1) + (b(2) - b(1))*exp(-(x-1)/b(3)); % Model Function
                %                 exp_model1 = @(b,x) b(1) + b(2)*exp(b(3)*x); % Model Function
                x = [1:length(unique(MTsn.Horizon))];
                yx = MTsn.MT';                                    % this would be a typical MT vs Horizon vector: [5422 3548 2704 2581 2446 2592 2418 2528 2500]
                OLS = @(b) sum((exp_model1(b,x) - yx).^2);                % Ordinary Least Squares cost function
                opts = optimset('MaxIter', 300,'TolFun',1e-5);
                [B1 Fval] = fminsearch(OLS,[3500 7500  1], opts);        % Use ?fminsearch? to minimise the ?OLS? function
                MT.MT_pred(id) = exp_model1(B1,x);
                MT.b1(id) = B1(1);
                MT.b2(id) = B1(2);
                MT.b3(id) = B1(3);
                
                
                [d subjnum 2]
                id = ismember(MT.SN , subjnum) & ismember(MT.Day , d) & ismember(MT.seqNumb , [0]);
                MTsn = getrow(MT , id);
                exp_model0 = @(b,x) b(1) + (b(2) - b(1))*exp(-(x-1)/b(3)); % Model Function
                yx = MTsn.MT';                                    % this would be a typical MT vs Horizon vector: [5422 3548 2704 2581 2446 2592 2418 2528 2500]
                OLS = @(b) sum((exp_model0(b,x) - yx).^2);                % Ordinary Least Squares cost function
                opts = optimset('MaxIter', 300,'TolFun',1e-5);
                B0 = fminsearch(OLS,[3500 7500 1], opts);        % Use ?fminsearch? to minimise the ?OLS? function
                MT.MT_pred(id) = exp_model0(B0,x);
                MT.b1(id) = B0(1);
                MT.b2(id) = B0(2);
                MT.b3(id) = B0(3);
            end
            [coo1(:,d),plot1(:,d),err1(:,d)] = lineplot([MT.Horizon] , MT.MT , 'subset' , ismember(MT.seqNumb , [1])  & ismember(MT.Day , d));
            [coo0(:,d),plot0(:,d),err0(:,d)] = lineplot([MT.Horizon] , MT.MT , 'subset' , ismember(MT.seqNumb , [0]) & ismember(MT.Day , d));
            
            [coo1_pred(:,d),plot1_pred(:,d),err1_pred(:,d)] = lineplot([MT.Horizon] , MT.MT_pred , 'subset' , ismember(MT.seqNumb , [1]) & ismember(MT.Day , d));
            [coo0_pred(:,d),plot0_pred(:,d),err0_pred(:,d)] = lineplot([MT.Horizon] , MT.MT_pred , 'subset' , ismember(MT.seqNumb , [0]) & ismember(MT.Day , d));
        end
        %% if you wanted to d othe parameter estimation in NonLinearModel:
        %         % New Model
        %         exp_model1 = @(b,x) b(1) + (b(2) - b(1))*exp((x-1)/b(3)); % Model Function
        %         opts1 = statset('Display','final','TolFun',1e-5, 'MaxIter', 100);
        %         % regressing out the horizon effect, i.e the exponential decrease in the MT
        %         % Horizon number is the input and MT is the output
        %         nlmf1 = NonLinearModel.fit([1:8 13], MTsn.MT, exp_model1, initial_values, 'Options', opts1);
        %         MT.MT_pred(id) = nlmf1.Fitted;
        %         MT.b1(id) = nlmf1.Coefficients.Estimate(1)*ones(sum(id),1);
        %         MT.b2(id) = nlmf1.Coefficients.Estimate(2)*ones(sum(id),1);
        %         MT.b3(id) = nlmf1.Coefficients.Estimate(3)*ones(sum(id),1);
        %
        
        
        %%
        h0 = figure;
        [coo1_b1,plot1_b1,err1_b1] = lineplot([MT.Day] , MT.b1 , 'subset' , ismember(MT.seqNumb , [1]) );
        [coo0_b1,plot0_b1,err0_b1] = lineplot([MT.Day] , MT.b1 , 'subset' , ismember(MT.seqNumb , [0]) );
        
        [coo1_b2,plot1_b2,err1_b2] = lineplot([MT.Day] , MT.b2 , 'subset' , ismember(MT.seqNumb , [1]) );
        [coo0_b2,plot0_b2,err0_b2] = lineplot([MT.Day] , MT.b2 , 'subset' , ismember(MT.seqNumb , [0]) );
        
        [coo1_b3,plot1_b3,err1_b3] = lineplot([MT.Day] , MT.b3 , 'subset' , ismember(MT.seqNumb , [1]) );
        [coo0_b3,plot0_b3,err0_b3] = lineplot([MT.Day] , MT.b3 , 'subset' , ismember(MT.seqNumb , [0]) );
        
        [coo1_invb3,plot1_invb3,err1_invb3] = lineplot([MT.Day] , (MT.b3).^-1 , 'subset' , ismember(MT.seqNumb , [1]) );
        [coo0_invb3,plot0_invb3,err0_invb3] = lineplot([MT.Day] , (MT.b3).^-1 , 'subset' , ismember(MT.seqNumb , [0]) );
        close(h0)
        for d = 1:5
            id1  = MT.Day == d & MT.seqNumb ==1;
            id2  = MT.Day == d & MT.seqNumb ==0;
            [~,out.b1_significance(d)] = ttest2(MT.b1(id1) , MT.b1(id2));
            [~,out.b2_significance(d)] = ttest2(MT.b2(id1) , MT.b2(id2));
            [~,out.b3_significance(d)] = ttest2(MT.b3(id1) , MT.b3(id2));
        end
        
        figure('color' , 'white')
        for d = 1:5
            subplot(2,3,d)
            errorbar(coo1(:,d)',plot1(:,d)',err1(:,d)' , 'LineWidth' , 3);
            hold on
            errorbar(coo0(:,d)',plot0(:,d)',err0(:,d)' , 'LineWidth' , 3);
            set(gca, 'YLim' , [3000 , 8000] , 'XTick' , [1:8 , 13], 'FontSize' , 20, 'GridAlpha' , 1)
            hold on
            xlabel('Horizon')
            ylabel('msec')
            title(['Chunked MT vs. Random on Day ' , num2str(d)])
            grid on
        end
        legend({'Chunked' , 'Random'}, 'Box' , 'off')
        
        figure('color' , 'white')
        for d = 1:5
            subplot(2,3,d)
            errorbar(coo1_pred(:,d)',plot1_pred(:,d)',err1_pred(:,d)' , 'LineWidth' , 3);
            hold on
            errorbar(coo0_pred(:,d)',plot0_pred(:,d)',err0_pred(:,d)' , 'LineWidth' , 3);
            set(gca, 'YLim' , [3000 , 8000] , 'XTick' , [1:8 , 13], 'FontSize' , 20, 'GridAlpha' , 1)
            hold on
            xlabel('Horizon')
            ylabel('msec')
            title(['fitted Chunked vs. fitted Random- Day ' , num2str(d)])
            grid on
        end
        legend({'Chunked' , 'Random'}, 'Box' , 'off')
        
        figure('color' , 'white')
        for d = 1:5
            subplot(2,3,d)
            errorbar(coo1(:,d)',plot1(:,d)',err1(:,d)' , 'LineWidth' , 3,'color','r');
            hold on
            errorbar(coo1_pred(:,d)',plot1_pred(:,d)',err1_pred(:,d)' , 'LineWidth' , 3 ,'color','c','LineStyle',':');
            set(gca, 'YLim' , [3000 , 8000] , 'XTick' , [1:8 , 13], 'FontSize' , 20, 'GridAlpha' , 1 , 'Box' , 'off')
            hold on
            xlabel('Horizon')
            ylabel('msec')
            title(['Chunked vs. fitted - Day ' , num2str(d)])
            grid on
        end
        legend({'Chunked' , 'Fitted Chunked'})
        
        figure('color' , 'white')
        for d = 1:5
            subplot(2,3,d)
            errorbar(coo0(:,d)',plot0(:,d)',err0(:,d)' , 'LineWidth' , 3,'color','r');
            hold on
            errorbar(coo0_pred(:,d)',plot0_pred(:,d)',err0_pred(:,d)' , 'LineWidth' ,3,'color','c','LineStyle',':');
            set(gca, 'YLim' , [3000 , 8000] , 'XTick' , [1:8 , 13], 'FontSize' , 20, 'GridAlpha' , 1, 'Box' , 'off')
            hold on
            xlabel('Horizon')
            ylabel('msec')
            title(['Random vs. fitted Random- Day ' , num2str(d)])
            grid on
        end
        legend({'Random' , 'Fitted Random'}, 'Box' , 'off')
        
        
        figure('color' , 'white')
        subplot(221)
        for d = 1:5
            errorbar(coo1(:,d)',plot1(:,d)',err1(:,d)' , 'LineWidth' , 3);
            hold on
        end
        set(gca, 'YLim' , [3000 , 8000] , 'XTick' , [1:8 , 13], 'FontSize' , 20, 'GridAlpha' , 1, 'Box' , 'off')
        hold on
        xlabel('Horizon')
        ylabel('msec')
        title('Chunked MT vs. Horizon')
        grid on
        
        subplot(222)
        for d = 1:5
            errorbar(coo0(:,d)',plot0(:,d)',err0(:,d)' , 'LineWidth' , 3);
            hold on
        end
        set(gca, 'YLim' , [3000 , 8000] , 'XTick' , [1:8 , 13],'FontSize' , 20, 'GridAlpha' , 1, 'Box' , 'off')
        xlabel('Horizon')
        ylabel('msec')
        title('Random MT vs. Horizon')
        legend({'Day1' , 'Day2' ,'Day3','Day4','Day5'}, 'Box' , 'off')
        grid on
        
        subplot(223)
        for d = 1:5
            errorbar(coo1_pred(:,d)',plot1_pred(:,d)',err1_pred(:,d)' , 'LineWidth' , 3);
            hold on
        end
        set(gca, 'YLim' , [3000 , 8000] , 'XTick' , [1:8 , 13],'FontSize' , 20, 'GridAlpha' , 1, 'Box' , 'off')
        hold on
        xlabel('Horizon')
        ylabel('msec')
        title('Fitted Chunked MT vs. Horizon')
        grid on
        
        subplot(224)
        for d = 1:5
            errorbar(coo0_pred(:,d)',plot0_pred(:,d)',err0_pred(:,d)' , 'LineWidth' , 3);
            hold on
        end
        set(gca, 'YLim' , [3000 , 8000] , 'XTick' , [1:8 , 13],'FontSize' , 20 , 'GridAlpha' , 1, 'Box' , 'off')
        xlabel('Horizon')
        title('Fitted Random MT vs. Horizon')
        grid on
        
        figure('color' , 'white')
        subplot(141)
        errorbar(coo1_b1,plot1_b1,err1_b1 , 'LineWidth' , 3);
        hold on
        errorbar(coo0_b1,plot0_b1,err0_b1 , 'LineWidth' , 3);
        set(gca, 'XTick' , [1:5],'FontSize' , 20, 'Box' , 'off','GridAlpha' , 1)
        hold on
        xlabel('Day')
        title('b1 Coefficient')
        grid on
        
        subplot(142)
        errorbar(coo1_b2,plot1_b2,err1_b2 , 'LineWidth' , 3);
        hold on
        errorbar(coo0_b2,plot0_b2,err0_b2 , 'LineWidth' , 3);
        set(gca, 'XTick' , [1:5],'FontSize' , 20, 'Box' , 'off','GridAlpha' , 1)
        hold on
        xlabel('Day')
        title('b2 Coefficient')
        grid on
        
        subplot(143)
        errorbar(coo1_b3,plot1_b3,err1_b3 , 'LineWidth' , 3);
        hold on
        errorbar(coo0_b3,plot0_b3,err0_b3 , 'LineWidth' , 3);
        set(gca, 'XTick' , [1:5],'FontSize' , 20, 'Box' , 'off','GridAlpha' , 1)
        hold on
        xlabel('Day')
        ylabel('msec')
        title('b3 Coefficient')
        grid on
        legend({'Chunked' , 'Random'}, 'Box' , 'off')
        
        subplot(144)
        errorbar(coo1_invb3,plot1_invb3,err1_invb3 , 'LineWidth' , 3);
        hold on
        errorbar(coo0_invb3,plot0_invb3,err0_invb3 , 'LineWidth' , 3);
        set(gca, 'XTick' , [1:5],'FontSize' , 20, 'Box' , 'off','GridAlpha' , 1)
        hold on
        xlabel('Day')
        ylabel('msec')
        title('1/b3 (Decay constant)')
        grid on
        legend({'Chunked' , 'Random'}, 'Box' , 'off')
        
        x = [1:10];
        b1 = 6;
        b2 = 10;
        figure('color' , 'white')
        %         subplot(121)
        for b3 = .2:.1:.7
            plot(x , b1 + (b2 - b1)*exp(-(x-1)/b3) ,'LineWidth' , 3)
            hold on
        end
        legend({'b3  = 0.2' , 'b3  = 0.3' ,'b3  = 0.4' ,'b3  = 0.5' ,'b3  = 0.6' , 'b3 = 0.7'}, 'Box' , 'off')
        title(['b1 + (b2 - b1)*exp(-(x-1)/b3)         for          b1 = ' ,num2str(b1)  , ',     b2 = ' ,num2str(b2)])
        set(gca , 'FontSize' , 20, 'Box' , 'off', 'GridAlpha' , 1, 'Box' , 'off')
        grid on
        x = [1:35];
        b1 = 6000;
        b3 = 3;
        %         figure('color' , 'white')
        subplot(122)
        for b2 = 0:20000:10^5
            plot(x , b1 + (b2 - b1)*exp(-(x-1)/b3) ,'LineWidth' , 3)
            hold on
        end
        legend({'b2  = 0' , 'b2  = 20000 ' ,'b2  = 40000' ,'b2  = 60000' ,'b2  = 80000' ,'b2  = 100000'}, 'Box' , 'off')
        title(['b1 = ' ,num2str(b1)  , ',     b3 = ' ,num2str(b3)])
        set(gca , 'FontSize' , 20 , 'Box' , 'off', 'GridAlpha' , 1)
        grid on
    case 'test_MT_asymptote'
        Hex = input('What horizons to exclude? (0 = include all)');
        ANA = getrow(Dall , Dall.isgood & ismember(Dall.seqNumb , [0 1 2]) & ~Dall.isError &~ismember(Dall.Horizon , Hex) & ismember(Dall.Day , [3:5]));
        ANA.seqNumb(ANA.seqNumb == 2) = 1;
        MT  = tapply(ANA , {'Horizon' , 'seqNumb'} , {'MT' , 'nanmedian(x)'});
        MT.MT_pred = zeros(size(MT.MT));
        MT.b1 = zeros(size(MT.MT));
        MT.b2 = zeros(size(MT.MT));
        MT.b3 = zeros(size(MT.MT));
        subjnum = 1 : length(subj_name) - 1;
        init_val = [3500 7500];   % [b1 b2]
        purt = 50*rand(1,100);
        itermax = [20 50 80 110 200 300];
        
        for i = 1:length(purt)
            d = 1
            id = ismember(MT.seqNumb , [1]);
            MTsn = getrow(MT , id);
            exp_model1 = @(b,x) b(1) + (b(2) - b(1))*exp(-(x-1)/b(3)); % Model Function
            %                 exp_model1 = @(b,x) b(1) + b(2)*exp(b(3)*x); % Model Function
            x = [1:length(unique(MTsn.Horizon))];
            yx = MTsn.MT';                                    % this would be a typical MT vs Horizon vector: [5422 3548 2704 2581 2446 2592 2418 2528 2500]
            OLS = @(b) sum((exp_model1(b,x) - yx).^2);                % Ordinary Least Squares cost function
            for j = 1:length(itermax)
                opts = optimset( 'MaxIter', itermax(j),'TolFun',1e-5);
                [B1{j}(:,i) Fval1{j}(i)] = fminsearch(OLS,[init_val+purt(i)*init_val 1], opts);        % Use ?fminsearch? to minimise the ?OLS? function
                MT_pred1{j}(i,:) = exp_model1(B1{j}(:,i),x);
            end
            
            id = ismember(MT.seqNumb , [0]);
            MTsn = getrow(MT , id);
            exp_model0 = @(b,x) b(1) + (b(2) - b(1))*exp(-(x-1)/b(3)); % Model Function
            yx = MTsn.MT';                                    % this would be a typical MT vs Horizon vector: [5422 3548 2704 2581 2446 2592 2418 2528 2500]
            OLS = @(b) sum((exp_model0(b,x) - yx).^2);                % Ordinary Least Squares cost function
            for j = 1:length(itermax)
                opts = optimset('MaxIter', itermax(j),'TolFun',1e-5);
                [B0{j}(:,i) fval0{j}(i)]= fminsearch(OLS,[init_val+purt(i)*init_val 1], opts);        % Use ?fminsearch? to minimise the ?OLS? function
                MT_pred0{j}(i,:) = exp_model0(B0{j}(:,i),x);
            end
        end
        figure('color' , 'white')
        for j = 1:length(itermax)
            subplot(2,3,j)
            plot(fval0{j} , purt , '*' , 'MarkerSize' , 5)
            set(gca, 'FontSize' , 20)
            xlabel('MSE')
            ylabel('percentage')
            
            
            hold on
            plot(Fval1{j} , purt , '*' , 'MarkerSize' , 5)
            set(gca, 'FontSize' , 20)
            xlabel('MSE')
            ylabel('percentage')
            grid on
            legend({'Random' , 'Chunked'})
            title(['SSE with iteration of ' ,num2str(itermax(j))])
        end
        
    case 'Errors'
        for tn = 1:length(Dall.TN)
            Dall.MT(tn , 1) = Dall.AllPressTimes(tn , Dall.seqlength(tn)) - Dall.AllPressTimes(tn , 1);
        end
        err = [];
        err0 = [];
        proberr = [];
        proberr0 = [];
        figure('color' , 'white')
        for h = [1:8]
            errh = [];
            errh0 = [];
            
            for sub = subjnum
                errhs = [];
                errhs0 = [];
                ANA = getrow(Dall , ismember(Dall.SN , sub) & ismember(Dall.seqNumb , [1:2]) & Dall.isError  & ismember(Dall.Day , days{day}) & ismember(Dall.Horizon , h));
                ANA0 = getrow(Dall , ismember(Dall.SN , sub) & ismember(Dall.seqNumb , 0) & Dall.isError  & ismember(Dall.Day , days{day}) & ismember(Dall.Horizon , h));
                
                for tn  = 1:length(ANA.TN)
                    ANA.ChunkBndry(tn , :) = diff(ANA.ChnkArrang(tn,:));
                    a = find(ANA.ChunkBndry(tn , :));
                    ANA.ChunkBndry(tn , a-1) = 3;
                    ANA.ChunkBndry(tn , end) = 3;
                    ANA.ChunkBndry(tn , ANA.ChunkBndry(tn , :) == 0) = 2;
                    ANA.ChunkBndry(tn , 1:2) = [-1 -1];  % dont account for the first and last sseqeuce presses
                    ANA.ChunkBndry(tn , end-1:end) = [-1 -1];% dont account for the first and last sseqeuce presses
                    ANA.IPI_Horizon(tn , :) = ANA.Horizon(tn)*ones(1,13);
                    a = find(ANA.AllPress(tn,:) ~= ANA.AllResponse(tn,:));
                    err = [err ; [a(1) ANA.ChnkPlcmnt(tn,a(1)), ANA.Horizon(tn) , ANA.SN(tn) ]];
                    errh = [errh ; [a(1) ANA.ChnkPlcmnt(tn,a(1)), ANA.Horizon(tn) , ANA.SN(tn) ]];
                    errhs = [errhs ; [a(1) ANA.ChnkPlcmnt(tn,a(1)), ANA.Horizon(tn) , ANA.SN(tn) ]];
                end
                
                for tn  = 1:length(ANA0.TN)
                    a = find(ANA0.AllPress(tn,:) ~= ANA0.AllResponse(tn,:));
                    err0 = [err0 ; [a(1) 0, ANA0.Horizon(tn) , ANA0.SN(tn) ]];
                    errh0 = [errh0 ; [a(1) 0, ANA0.Horizon(tn) , ANA0.SN(tn) ]];
                    errhs0 = [errhs0 ; [a(1) 0, ANA0.Horizon(tn) , ANA0.SN(tn) ]];
                end
                for p = 1:14
                    proberr  = [proberr  ; 100*sum(errhs(:,1) == p)/size(errhs,1) sub h p];
                    proberr0 = [proberr0 ; 100*sum(errhs0(:,1) == p)/size(errhs0,1) sub h p];
                end
            end
            subplot(2,4,h)
            ax = gca;
            hold on
            histogram(errh(:,2) , 'Normalization' , 'probability');
            ylabel('Probability');
            xlabel('Chunk placement')
            title(['Errors in different chunk placements, H = ' , num2str(h)])
            ax.YLim =[0: 1];
            ax.XTick = [1:3];
            ax.XTickLabel = {'First' , 'Middle' , 'Last'};
        end
        
        out.Po1 = anovan(err(:,2) , err(:,3), 'display' , 'off' , 'model' , 'full' , 'varnames' , {'Horizon'});
        
        temp = pivottable(proberr(:,3) , proberr(:,4) , proberr(:,1) , 'nanmean');
        figure('color' , 'white')
        subplot(1,2,1)
        imagesc(temp , [0 50])
        colorbar
        hold on
        ax = gca;
        ax.XTick = [1:14];
        xlabel('Presses')
        ax.YTickLabel  = fliplr({ 'H = 8' 'H = 7' 'H = 6' 'H = 5' 'H = 4' 'H = 3' 'H = 2' 'H = 1' });
        title('%Errors per press in chunked sequences')
        
        temp0 = pivottable(proberr0(:,3) , proberr0(:,4) , proberr0(:,1) , 'nanmean');
        subplot(1,2,2)
        imagesc(temp0 , [0 50])
        colorbar
        hold on
        ax = gca;
        ax.XTick = [1:14];
        xlabel('Presses')
        ax.YTickLabel  = fliplr({ 'H = 8' 'H = 7' 'H = 6' 'H = 5' 'H = 4' 'H = 3' 'H = 2' 'H = 1' });
        title('%Errors per press in Random sequences')
        
        %% error percetanges
        errp = [];
        
        for h = [1:8]
            for sub = subjnum
                ANA = getrow(Dall , ismember(Dall.SN , sub) & ismember(Dall.seqNumb , [1:6])& ismember(Dall.Rep , Repetition) & ismember(Dall.Day , days{day}) & ismember(Dall.Horizon , h));
                ANA0 = getrow(Dall , ismember(Dall.SN , sub) & ismember(Dall.seqNumb , 0) & ismember(Dall.Rep , Repetition) & ismember(Dall.Day , days{day}) & ismember(Dall.Horizon , h));
                errp = [errp ; 100*sum(ANA.isError)/length(ANA.TN) h sub 1];
                errp = [errp ; 100*sum(ANA0.isError)/length(ANA0.TN) h sub 0];
            end
        end
        h1 = figure;
        [xcoor1,PLOT1,ERROR1] = lineplot(errp(:,2) , errp(:,1) , 'subset' , errp(:,4) ==1);
        hold on
        [xcoor0,PLOT0,ERROR0] = lineplot(errp(:,2) , errp(:,1) , 'subset' , errp(:,4) ==0);
        close(h1)
        
        out.EP = anovan(errp(:,1) , errp(:,[2,4]), 'display' , 'off' , 'model' , 'full' , 'varnames' , {'Horizon' , 'Rand/Chunk'});
        figure('color' , 'white')
        h1 = plotshade(xcoor1',PLOT1,ERROR1,'transp' , .2 , 'patchcolor' , 'b' , 'linecolor' , 'b' , 'linewidth' , 3 , 'linestyle' , ':');
        hold on
        h0 = plotshade(xcoor0',PLOT0,ERROR0,'transp' , .2 , 'patchcolor' , 'm' , 'linecolor' , 'm' , 'linewidth' , 3 , 'linestyle' , ':');
        
        title(['Error rate,  p(r/c) = ' , num2str(out.EP(2)) , '       No horizon effect, no interaction'])
        legend([h1,h0] , {'Chunked' , 'Randon'})
        hold on
        ax = gca;
        ax.XTick = [1:8];
        xlabel('Horizon')
        ylabel('Percent of Error trial');
        grid on
    
        
        
        out = [];
end


