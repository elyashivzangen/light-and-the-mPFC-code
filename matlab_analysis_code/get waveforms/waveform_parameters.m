clear;
clc;
%%

[file, path] = uigetfile('best_waveform.mat');
datafile = fullfile(path, file);
load(datafile)

cd(path)
wm =  best_waveform.mean;


[file, path] = uigetfile('cluster_info.tsv');
datafile = fullfile(path, file);
w = tdfread(datafile);






%% plot all waveforms
for i = 20:30
    figure
    plot(wm(i, :))
end
%% keep only good unites
good_cells.id = [];
good_cells.fr = [];
good_cells.wf = [];
good_cells.amplitude = [];
for i = 1:length(wm)
    if strcmp(w.group(i), 'g')
        good_cells.id(end + 1) =  w.id(i);
        good_cells.fr(end+1) = w.fr(i);
        good_cells.wf(end+1, :) = wm(i,:);
    elseif strcmp(w.KSLabel(i), 'g') && ~strcmp(w.group(i), 'n') && ~strcmp(w.group(i), 'm')
        good_cells.id(end + 1) =  w.id(i); 
        good_cells.fr(end+1) = w.fr(i);
        good_cells.wf(end+1, :) = wm(i,:);
        good_cells.amplitude(end+1) = w.Amplitude(i);
    end
end
wm = good_cells.wf;
%%
ploting  = 0;


%% find parameters of waveforms
for i = 1: size(wm, 1)
    waveform = wm(i, :)';
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
    corossing_point =  peak_time + find(waveform(peak_time:end)<0, 1); %find the first value after the peak that is negative
    
    
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
    
    dt(i) = deflection_time;
    dv(i) = deflection_value;
    vt(i) = valley;
    vv(i) = valley_value;
    amp(i) = amplitude;
    m2v(i) = midvalue_to_valley;
    mav(i) = midvalue_after_valley;
    hvd(i) = half_valley_duration;
    m2p(i) = midtime_to_peak;
    map(i) = midtime_after_peak;
    hpd(i) = half_peak_duration;
    td(i) =  half_peak_duration + half_valley_duration; %total duration
    
end

histogram(hvd)
figure
histogram(hpd)
%%
figure
scatter3(hvd, hpd, td, '.')
%%
X = [hvd', hpd', td'];
idx = kmeans(X, 3);

color = {'red', 'green', 'blue'};
for i = 1:length(idx)
    scatter3(X(i, 1), X(i, 2), X(i, 3), 'MarkerFaceColor' , color{idx(i)})
    hold on
end

%%
for i = 1:3    
    subplot(2,3,i)
    clusters_wm = find(idx == i);
    for j = 1:length(clusters_wm)
        %normalize the waveforms
        cj = clusters_wm(j);
        normalized_wm = wm(cj, :)/max(abs(wm(cj, :)));
        plot(normalized_wm)
        hold on
    end
    subplot(2,3,i + 3)
    edges = [1000:2000:200000];
    histogram(good_cells.fr(clusters_wm))
    fr_mean(i) = mean(good_cells.fr(clusters_wm));
end


figure
bar(fr_mean)


