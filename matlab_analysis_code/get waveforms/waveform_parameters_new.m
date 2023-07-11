clear
clc

%% add togethter meny WF files
[filename path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
datafile = fullfile(path, filename); %save path
all_wf.fr = [];
all_wf.mean = [];
for i = 1:length(datafile)
    load(datafile{i});
    all_wf.mean = [all_wf.mean ; wf.waveFormsMean];
    all_wf.fr = [all_wf.fr; wf.fr];
end






%% find parameters of waveforms
ploting  = 0;
wm =  all_wf.mean;


for i = 1: size(wm, 1)
    waveform = wm(i, :)';
    if sum(isnan(waveform))
        continue
    end
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
scatter3(hvd, hpd, all_wf.fr, '.')
%%
X = [hvd', hpd', all_wf.fr];
idx = kmeans(X, 2);

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
    histogram(all_wf.fr(clusters_wm))
    fr_mean(i) = mean(all_wf.fr(clusters_wm));
end


figure
bar(fr_mean)


