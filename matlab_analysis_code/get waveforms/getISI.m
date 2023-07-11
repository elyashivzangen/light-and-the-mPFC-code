clear;
clc;

binsize = 1; %sec
samp_rate = 40; %smapling rate in ms
%% load files
% [file, path] = uigetfile('*.mat');
% datafile = fullfile(path, file);
% load(datafile)

[file, path] = uigetfile('spike_clusters.npy');
datafile = fullfile(path, file);
spike_clusters = readNPY(datafile);
cd(path)

[file, path] = uigetfile('spike_times.npy');
datafile = fullfile(path, file);
spike_times = readNPY(datafile);

[file, path] = uigetfile('cluster_info.tsv');
datafile = fullfile(path, file);
w = tdfread(datafile);

[file, path] = uigetfile('temp_wh.dat');



%% detect good cells

% good_id = [];
% best_channels = [];
% fr = [];
%
% for i = 1:length(w.id)
%     if strcmp(w.group(i), 'g')
%         good_id = [good_id; w.id(i)];
%         best_channels = [best_channels; w.ch(i)+1];
%         fr = [fr ; w.fr(i)];
%     elseif strcmp(w.KSLabel(i), 'g') && ~strcmp(w.group(i), 'n') && ~strcmp(w.group(i), 'm')
%         good_id = [good_id; w.id(i)];
%         best_channels = [best_channels; (w.ch(i)+1)];
%         fr = [fr ; w.fr(i)];
%
%     end
% end
%% extract waveforms of good units
gwfparams.dataDir = path;    % KiloSort/Phy output folder
gwfparams.fileName = file;         % .dat file containing the raw
[file,path] = uiputfile('exeriment_name_Cell_Type_parameters.mat');

gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
gwfparams.nCh = 32;                      % Number of channels that were streamed to disk in .dat file
gwfparams.wfWin = [-80 150];              % Number of samples before and after spiketime to include in waveform
gwfparams.nWf = 5000;                    % Number of waveforms per unit to pull out
gwfparams.spikeTimes = spike_times; % Vector of cluster spike times (in samples) same length as .spikeClusters
gwfparams.spikeClusters = spike_clusters; % Vector of cluster IDs (Phy nomenclature)   same length as .spikeTimes
% gwfparams.spiketamplate = readNPY('spike_templates.npy');
gwfparams.good_id = [];
gwfparams.best_channels = [];
gwfparams.fr = [];


for i = 1:length(w.id)
    if strcmp(w.group(i), 'g')
        gwfparams.good_id = [gwfparams.good_id; w.id(i)];
        gwfparams.best_channels = [gwfparams.best_channels; w.ch(i)+1];
        gwfparams.fr = [gwfparams.fr ; w.fr(i)];
    elseif strcmp(w.KSLabel(i), 'g') && ~strcmp(w.group(i), 'n') && ~strcmp(w.group(i), 'm')
        gwfparams.good_id = [gwfparams.good_id; w.id(i)];
        gwfparams.best_channels = [gwfparams.best_channels; (w.ch(i)+1)];
        gwfparams.fr = [gwfparams.fr ; w.fr(i)];
        
        
    end
end

%%
wf = getbestWaveForms(gwfparams);


%%
wm = wf.waveFormsMean;
ploting = 0;
for i = 1: size(wm, 1)
    waveform = wm(i, :)';
    if sum(isnan(waveform))
        continue
    end
    baseline = mean(waveform(1:30)); % try to create a basline signal - not very acurete
    waveform = waveform - baseline; %nomalize waveform
    [valley_value, valley] = min(waveform); %the spikes negative peak
    [befor_valley_peaks, peak_times] = findpeaks(waveform(1:valley));
    % רלוונטי רק אם אני רוצה לחשב את הפיקים החיוביים - ולא רק את האמפליטודה
    % השלילית
    deflection_time = peak_times(end);
    deflection_value = befor_valley_peaks(end); %where the spike starts
    
    [peak, peak_time] = max(waveform(valley:end));%the spikes positive peak after the dipolarization
    peak_time = peak_time + valley; %total time till peak after valey
    amplitude = 0 - valley_value; %if i want to calculate the amplitude including the positeve curent i nead to use deflection value
    % find the time of half of the amplitude from first peak to valley and
    % from the valley to the seconed peak
    [~ , midvalue_to_valley] = min(abs(waveform(deflection_time:valley) - (0 - amplitude/2)));
    midvalue_to_valley = deflection_time + midvalue_to_valley - 1;
    [~ , midvalue_after_valley] = min(abs(waveform(valley:peak_time) - (0 - amplitude/2)));
    midvalue_after_valley = midvalue_after_valley + valley - 1;
    half_valley_duration = midvalue_after_valley - midvalue_to_valley;
    
    %find the duration of half peak time.
    [~ , midtime_to_peak] = min(abs(waveform(valley:peak_time) - (peak/2))); % chack what is the closest point betwen valley to peak that is in the value of half the peak
    midtime_to_peak = midtime_to_peak + valley - 1;
    corossing_point =  peak_time + find(waveform(peak_time:end)<0 | waveform(end), 1); %find the first value after the peak that is negative
    
    
    [~ , midtime_after_peak] = min(abs(waveform(peak_time:corossing_point) - (peak/2))); % chack what is the closest point betwen valley to peak that is in the value of half the peak
    
    midtime_after_peak = midtime_after_peak + peak_time - 1;
    half_peak_duration = midtime_after_peak - midtime_to_peak;
    
    %plot all points
    if ploting
        figure
        title({good_cells.id(i) 'amplitude: ' good_cells.amplitude(i)  'true amplitude: ' amplitude})
        subtitle({'half valley duration '  half_valley_duration ...
            'half peak: ' half_peak_duration  'firing rate: ' good_cells.n_spikes(i)})
        hold on
        
        plot(waveform)
        plot( midvalue_to_valley, (0 - amplitude/2), 'o')
        plot( midvalue_after_valley, (0 - amplitude/2),'o')
        plot(valley, valley_value, 'o')
        plot(peak_time, peak, 'o')
        
        plot( midtime_to_peak, peak/2, 'o')
        plot( midtime_after_peak, peak/2, 'o')
        
        
    end
    
    %     dt(i) = deflection_time;
    %     dv(i) = deflection_value;
    %     vt(i) = valley;
    %     vv(i) = valley_value;
    %     amp(i) = amplitude;
    %     m2v(i) = midvalue_to_valley;
    %     mav(i) = midvalue_after_valley;
    %     m2p(i) = midtime_to_peak;
    %     map(i) = midtime_after_peak;
%     td(i) =  half_peak_duration + half_valley_duration; %total duration
    hvd(i) = half_valley_duration;
    hpd(i) = half_peak_duration;   
end

%% calculate ISI and barst and postspike spretion for each cell
for i = 1:length(gwfparams.good_id)
    cell_spikes = spike_times(spike_clusters == gwfparams.good_id(i));
    ISI = double((cell_spikes(2:end) - cell_spikes(1:end-1)))/samp_rate;
    %ISIs(i, :) = ISI;
    
    low_ISI(i) = sum(ISI < 100)*100/length(ISI);%calculate isi precent < 100ms
    
%     busrts = find(ISI(1:end-1) < 10 & ISI(2:end) < 10); %find all consecutive ISIs that are < 10ms
    busrts = find(ISI < 10); %find all burstings (with less than 10 ISI)
    start_of_burst = sum(busrts(1:end-1)+1 ~= busrts(2:end)); %add number of spikes in a bigining of a burst series (all the spikes that have no short ISI before them).
    busrt_ISI(i) = ((length(busrts) + start_of_burst)*100)/length(cell_spikes); %sum all spikes in the burst and clculate precent of all spikes
    
    %     figure
    %     histogram(ISI)
    %     title({"number of spikes " + length(cell_spikes)})
    %     subtitle({"low_ISI%: " low_ISI(i) " bursting spikes%: "  busrt_ISI(i) })
    %
    % calculate post spike suppression
    
    %create a 1 ms binned spike train
    spike_train = zeros(cell_spikes(end), 1);
    spike_train(cell_spikes) = 1;
    spike_train = spike_train(1: floor(double(cell_spikes(end))/(binsize*samp_rate))*(binsize*samp_rate)); %cut end
    bind_spike_train = (sum(reshape(spike_train,[], length(spike_train)/(binsize*samp_rate))))/binsize; %bin spike train
    
    xc = xcorr(bind_spike_train,1000); % calculate crooscorolationw =
    xc = xc(ceil(length(xc)/2 +1):end); %save only the time ahed of the spike (form 0 to 1 sec)
    %smooth with humming window
    w = hamming(50);
    %   aoutocorr = xc_windowed(ceil(length(xc)/2 +1):end); %save only the time ahed of the spike (form 0 to 1 sec)
    
    aoutocorr(i, :) = conv(xc,w/sum(w),'same');
    % xc_mean = mean(w);
    %find post spike suppression.
    mean_fr = mean(aoutocorr(i, :)); %caculate the mean fr
%     pss = find(aoutocorr(i, :) > mean_fr);
    post_spike_supression(i) = find(aoutocorr(i, :) > mean_fr, 1);
    %autocorrelation =
end

%plot the 3 variables
% scatter3(low_ISI, busrt_ISI, post_spike_supression)
% xlabel('low_ISI')
% ylabel('busrt_ISI')
% zlabel('post_spike_supression')



%% save all files
save('waveforms.mat', 'wf')

%save('ISIs.mat', 'ISIs')
save('autocorrelation', 'aoutocorr')


CTparameters = table(gwfparams.good_id, low_ISI', busrt_ISI', post_spike_supression', hvd', hpd', wf.fr, 'VariableNames',{'id','low_isi','busrt_ISI', 'post_spike_supression', 'half_valley_duration', 'half_peak_duration', 'firing_rate'});

% save('low_ISI')
% save('busrt_ISI')

datafile = fullfile(path, file);

save(datafile, 'CTparameters')



%% cluster the variables
% bursting = 0;
% for i = 1:length(ISI)
%     if ISI(i) < 10 && ISI(i+1) < 10
%         isi(count
%         bursting = bursting + 1;
%     end
% end
%
%
%  X = [low_ISI; busrt_ISI; post_spike_supression; wf.fr'; hvd;  hpd];
% X=X';
% idx = kmeans(X, 3);
% 
% color = {'red', 'green', 'blue'};
% for i = 1:length(idx)
% %     scatter3(X(i, 1), X(i, 2), X(i, 3), 'MarkerFaceColor' , color{idx(i)})
%     hold on
%     subplot(1,3,idx(i))
%     plot (aoutocorr(i, :))
% end