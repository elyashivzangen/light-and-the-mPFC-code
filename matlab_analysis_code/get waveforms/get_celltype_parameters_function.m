function CTparameters = get_celltype_parameters_function(path, file, exp_id)
cd(path)
mkdir cell_type_parameters
selected_dir = 'cell_type_parameters';

spike_clusters = readNPY('spike_clusters.npy');
spike_times = readNPY('spike_times.npy');
w = tdfread('cluster_info.tsv');

if ~exist("file", "var")
    if isfile('temp_wh.dat')
        file = 'temp_wh.dat';
    else
        disp(cd)
        disp("no .dat file")
    end
end


binsize = 1; %sec
samp_rate = 40; %smapling rate in ms
ploting = 0; %if to plot all waveforms


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

gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
gwfparams.nCh = 32;                      % Number of channels that were streamed to disk in .dat file
gwfparams.wfWin = [-80 150];              % Number of samples before and after spiketime to include in waveform
gwfparams.nWf = 1000;                    % Number of waveforms per unit to pull out
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
%% alterntivaly get wf from templates.npy
% A = readNPY('templates.npy');
% for i = length(gwfparams.good_id)
%     wf.waveFormsMean = A(:, w.id


%%
wm = wf.waveFormsMean;
error_cells = [];
for i = 1: size(wm, 1)
    try

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
        valley_to_peak = peak_time;
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
        corossing_point =  peak_time + find(waveform(peak_time:end)<0); %find the first value after the peak that is negative
        if isempty(corossing_point)
            corossing_point = length(waveform);
        end

        [~ , midtime_after_peak] = min(abs(waveform(peak_time:corossing_point) - (peak/2))); % chack what is the closest point betwen valley to peak that is in the value of half the peak

        midtime_after_peak = midtime_after_peak + peak_time - 1;
        half_peak_duration = midtime_after_peak - midtime_to_peak;

        %plot all points
        if ploting
            figure;
            %             subplot(1,2,1)
            title({gwfparams.good_id(i)})
            subtitle({'half valley duration '  half_valley_duration ...
                'half peak: ' half_peak_duration  'firing rate: ' gwfparams.fr(i)})
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
        if isempty(midtime_after_peak)
            midtime_after_peak = NaN;
        end
        m2v(i) = midvalue_to_valley;
        mav(i) = midvalue_after_valley;
        m2p(i) = midtime_to_peak;
        map(i) = midtime_after_peak;
        %     td(i) =  half_peak_duration + half_valley_duration; %total duration
        hvd(i) = half_valley_duration;
        hpd(i) = half_peak_duration;
        v2p(i) = valley_to_peak;
        pv(i) = peak;
        vv(i) = valley_value;
        %pt(i) = peak_time; %peak time
        %vt(i) = valley;

    catch
        disp(['problem finding peak or valley in cell: ', num2str(gwfparams.good_id(i))]);
        error_cells = [error_cells gwfparams.good_id(i)];
        hvd(i) = NaN;
        hpd(i) = NaN;
        v2p(i) = NaN;
        pv(i) = NaN;
        vv(i) = NaN;
        continue
    end
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
    %     set(0, 'CurrentFigure', h(i))
    %     subplot(1,2,2)
    %
    %     plot(aoutocorr(i, :))
    %     hold on
    %     plot(post_spike_supression(i), aoutocorr(i, post_spike_supression(i)), 'o')
end

%plot the 3 variables
% scatter3(low_ISI, busrt_ISI, post_spike_supression)
% xlabel('low_ISI')
% ylabel('busrt_ISI')
% zlabel('post_spike_supression')



%% save all files
cd(selected_dir)
save('waveforms.mat', 'wf')

%save('ISIs.mat', 'ISIs')
save('autocorrelation', 'aoutocorr')
filename =   [exp_id{1} '_cell_type_parameters.mat'];

save('error_cells', 'error_cells')
files_path = repmat(path, length(gwfparams.good_id), 1);

exp_id_rep = repmat(exp_id, length(gwfparams.good_id), 1);

CTparameters = table(exp_id_rep, gwfparams.good_id, low_ISI', busrt_ISI', post_spike_supression', hvd', hpd', wf.fr, files_path, 'VariableNames',{'experiment_id' ,'id','low_isi','busrt_ISI', 'post_spike_supression', 'half_valley_duration', 'half_peak_duration', 'firing_rate', 'files_path'});
CTparameters.waveforms = mat2cell(wm, ones(1, size(wm, 1)));
CTparameters.aoutocorr = mat2cell(aoutocorr, ones(1, size(aoutocorr, 1)));


% if error_cells(end) == CTparameters.id(end)
%     CTparameters = CTparameters(1:end-1, :);
% end

CTparameters.m2p = m2p';
CTparameters.map = map';
CTparameters.m2v = m2v';
CTparameters.mav = mav';
CTparameters.valley_to_peak = v2p';
CTparameters.valley_value =  vv';
CTparameters.peak_value = pv';
if error_cells
    error_rows = find(sum(CTparameters.id == error_cells, 2));
    CTparameters(error_rows, :) = [];
end
% save('low_ISI')
% save('busrt_ISI')



save(filename, 'CTparameters')

all_datafile = fullfile('E:\2023 - ledramp\all_analysis_cell_display\CTP', filename);
save(all_datafile, 'CTparameters')


% %% cluster the variables
% % bursting = 0;
%  for i = 1:length(ISI)
%      if ISI(i) < 10 && ISI(i+1) < 10
%          isi(count)
%          bursting = bursting + 1;
%     end
%  end
%
%
%   X = [low_ISI; busrt_ISI; post_spike_supression; wf.fr'; hvd;  hpd];
%  X=X';
%  idx = kmeans(X, 3);
%
%  color = {'red', 'green', 'blue'};
%  for i = 1:length(idx)
%      scatter3(X(i, 1), X(i, 2), X(i, 3), 'MarkerFaceColor' , color{idx(i)})
%      hold on
%      subplot(1,3,idx(i))
%      plot (aoutocorr(i, :))
%  end
%%
% [file, path] = uigetfile('CTparameters.mat');
% datafile = fullfile(path, file);
% load(datafile)
% selected_dir = uigetdir('cell_type_parameters');
% exp_id_rep = repmat(selected_dir, length(CTparameters.id), 1);
% CTparameters.files_path = exp_id_rep;
% CTparameters = [CTparameters(:,1:8) CTparameters(:,15) CTparameters(:, 9:14)];
% save(datafile, 'CTparameters')
%%

end