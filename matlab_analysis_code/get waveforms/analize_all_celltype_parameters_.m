clear
clc

%% add togethter meny WF files
[filename path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
datafile = fullfile(path, filename); %save path
%%
CTP = [];
for i = 1:length(datafile)
%     CTparameters.

   load(datafile{i});
   CTparameters.files_path = cellstr(CTparameters.files_path); 
%    if sum(strcmp('files_path',fieldnames(CTparameters)))
%         CTparameters.files_path = [];
%    end
    CTP = [CTP; CTparameters]; 
end



%% calulate true to peak
for i = 1:length(CTP.waveforms)
    wf = CTP.waveforms{i};
    [peak, peaktime] = min(wf);
    [valley, valleytime] = max(wf(peaktime:end));
    trough2peak = valleytime/40*1000;
    if trough2peak > 1200 || trough2peak<200 || CTP.m2v(i)<65 ||  CTP.m2v(i)>85
        figure
        plot(wf)
        title(CTP.experiment_id{i})
        subtitle(trough2peak)
        
    end
    CTP.trough2peak(i) = trough2peak;
end
%%
plot(CTP.trough2peak, CTP.firing_rate, 'o')
xlabel('trough2peak (us)')
ylabel('firing rate (HZ)')


%% take out cells with low fr
CTP(CTP.firing_rate <0.5, :)= [];


%%
save_CTP = CTP;
CTP = CTP(CTP.trough2peak<1000, :);
%% use 5 parameters and trou2peak
X = table2array(CTP(:, [3:5 8 16]) );
idx = kmeans(X, 2);
%% use only thru2peak
idx = kmeans(X(:,5), 2);

%% use only waveform fetures
X = table2array(CTP(:, [6:8 ,16]));
idx = kmeans(X, 2);

figure
color = {'red', 'green', 'blue'};
for i = 1:2
    
    cidx = idx == i; %index for each cluster
    scatter3(X(cidx, 1), X(cidx, 3), X(cidx, 4), 'MarkerFaceColor' , color{i})
    hold on
    xlabel('half peak')
    ylabel('fr')
    zlabel('t2p')

%     subplot(1,3,idx(i))
%     plot (aoutocorr(i, :))
end
%%
FSI = CTP(idx == 1 ,:);
MSN = CTP(idx == 2 ,:);
FSI_TAN = table2array(FSI(:, 3:5));
FSI_idx = kmeans(FSI_TAN, 2);

figure
color = {'red', 'green', 'blue'}; 

for i = 1:3
    
    cidx = FSI_idx == i; %index for each cluster
    scatter3(FSI_TAN(cidx, 1), FSI_TAN(cidx, 2), FSI_TAN(cidx, 3), 'MarkerFaceColor' , color{i})
    hold on
    xlabel('low_ISI')
    ylabel('busrt_ISI')
    zlabel('post_spike_supression')

%     subplot(1,3,idx(i))
%     plot (aoutocorr(i, :))
end
newFSI = FSI;
FSI = FSI(FSI_idx == 2 ,:);
TAN = newFSI(FSI_idx == 1, :);


MSN_TAN = table2array(MSN(:, 3:5));
MSN_idx = kmeans(MSN_TAN, 2);

figure
color = {'red', 'green', 'blue'};
for i = 1:3
    
    cidx = MSN_idx == i; %index for each cluster
    scatter3(MSN_TAN(cidx, 1), MSN_TAN(cidx, 2), MSN_TAN(cidx, 3), 'MarkerFaceColor' , color{i})
    hold on
    xlabel('low_ISI')
    ylabel('busrt_ISI')
    zlabel('post_spike_supression')

%     subplot(1,3,idx(i))
%     plot (aoutocorr(i, :))
end

newMSN = MSN;
MSN = MSN(MSN_idx == 2 ,:);
TAN = [TAN; newMSN(MSN_idx == 1, :)];

%% use all 6 parameters

Z  = table2array(CTP(:, 3:8));
idx = kmeans(Z, 3);

%% MANUALLY SET PARAMETERS 
idx = (X(:,5) <=500)+1;
FSI = CTP(find(idx==2), :);


 %% cluster to 2 clusters only based on the waveform parameters
 relevant_row =[3 5 16 4 8];
X  = table2array(CTP(:, [3 5 16 4 8]));
idx = kmeans(Z(:,3:6), 2);

%%

figure
color = {'red', 'green', 'blue'};
for i = 1:3
    
    cidx = idx == i; %index for each cluster
    scatter3(X(cidx, 1), X(cidx, 2), X(cidx, 3), 'MarkerFaceColor' , color{i})
    hold on
    xlabel('low_ISI')
    ylabel('busrt_ISI')
    zlabel('post_spike_supression')

%     subplot(1,3,idx(i))
%     plot (aoutocorr(i, :))
end
%%

figure
color = {'red', 'green', 'blue'};
for i = 1:3
    
    cidx = idx == i; %index for each cluster
    scatter3(Z(cidx, 1), Z(cidx, 2), Z(cidx, 3), 'MarkerFaceColor' , color{i})
    hold on
    xlabel('low_ISI')
    ylabel('busrt_ISI')
    zlabel('post_spike_supression')

%     subplot(1,3,idx(i))
%     plot (aoutocorr(i, :))
end

%%
figure
for i = 1:3
    cidx = idx == i; %index for each cluster
    scatter3(Z(cidx, 4), Z(cidx, 5), Z(cidx, 6), 'MarkerFaceColor' , color{i})
    hold on
    xlabel('half valley duration')
    ylabel('half peak duration')
    zlabel('firing rate')

%     subplot(1,3,idx(i))
%     plot (aoutocorr(i, :))
end
%% for5 parmas
figure
for i = 1:3
    cidx = idx == i; %index for each cluster
    scatter3(X(cidx, 4), X(cidx, 5), X(cidx, 3), 'MarkerFaceColor' , color{i})
    hold on
    xlabel('firing rate')
    ylabel('trou2peak')
    zlabel('pss')

%     subplot(1,3,idx(i))
%     plot (aoutocorr(i, :))
end

%%
Y = [];
STD = [];
for i = 1:3
    Y(i, :) = mean(X(idx == i, :), 1);
    STD(i, :) = std(X(idx == i, :), 1);
end
%%
Y = [];
STD = [];
for i = 1:3
    Y(i, :) = mean(Z(idx == i, :), 1);
    STD(i, :) = std(Z(idx == i, :), 1);
   
end
%%
for i = 1:3
 p2v(i) = mean(CTP.trough2peak(CTP.idx == i));
end
%%
for i = 1:6
    figure
    x = 1:3;
    bar(Y(:, i))
    title(CTP.Properties.VariableNames{relevant_row(i)});
    hold on
    er = errorbar(x, Y(:, i), Y(:, i)+STD(:, i),  Y(:, i)-STD(:, i));
    er.Color = [0,0,0];
    er.LineStyle='none';
end
    
 %% plot all waveforms
 for i = 1:60
    figure
    title([num2str(CTP.id(i)) " " CTP.experiment_id{i}])
    subtitle({'half valley duration '  CTP.half_valley_duration(i) ...
        'half peak: ' CTP.half_peak_duration(i)  'firing rate: ' CTP.firing_rate(i)})
    hold on
    
    plot(CTP.waveforms{i})
    plot( CTP.m2v(i), CTP.waveforms{i}(CTP.m2v(i)), 'o')
    plot( CTP.m2p(i), CTP.waveforms{i}(CTP.m2p(i)), 'o')
    plot( CTP.mav(i), CTP.waveforms{i}(CTP.mav(i)), 'o')
    plot( CTP.map(i), CTP.waveforms{i}(CTP.map(i)), 'o')

 end

%% CELLS NEEDEDD TO ERASE
% Y = [1010 934 919 767 752 577 553 536 535 530 522 466 413 270 269 218];
% x = Y +8
CTP = [CTP table(idx)];
CTP_MEAN = table(Y);
CTP_STD = table(STD);
CTPmeanstd = [CTP_MEAN CTP_STD ];
writetable(CTPmeanstd,fullfile('E:\2022\all_cell_parameters',['mean.csv']))


CLUSTERS_MEAN = table(Y(:, 1:6) , 'VariableNames',  {'low_isi', 'busrt_ISI', 'post_spike_supression', 'half_valley_duration', 'half_peak_duration', 'firing_rate'});
% CLUSTERS_MEAN.Properties.VariableNames = ('low_isi', 'busrt_ISI', 'post_spike_supression', 'half_valley_duration', 'half_peak_duration', 'firing_rate') ;


