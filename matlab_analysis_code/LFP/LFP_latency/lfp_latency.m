function [latency, peak, first_peak, f1] =  lfp_latency(LFP, ploting)
%% LFP LATENCY
% calcualte peak/ first time fr crosses 1std form baseline
delay = 3116;
fr = 1000; %hz
[peak_val, peak] = max(abs(LFP(delay:end)));
t = (1:length(LFP))/1000 - delay/fr;
b_std = std(LFP(1:3000)); %baseline std
latency = find(abs(LFP(delay:end)) > 2*b_std, 1); %cross 1 std form baseline
[~, first_peak]  = max(LFP(delay:(delay+peak)));
if ploting
    f1 = figure;
    subplot(1,2,1)
    plot(t, LFP);
    hold on
    xline(0)
    scatter((peak)/fr, LFP(peak+delay), 'r');
    scatter((latency)/fr, LFP(latency+delay),'g');
    scatter((first_peak)/fr, LFP(first_peak+delay),'b');
    title(['latency: ' num2str(latency) ' ms'])
    subtitle(['peak: ' num2str(peak) ' ms'])

    subplot(1,2,2)
    plot(t, LFP);
    hold on
    xline(0)
    scatter((peak)/fr, LFP(peak+delay), 'r');
    scatter((latency)/fr, LFP(latency+delay),'g');
    scatter((first_peak)/fr, LFP(first_peak+delay),'b');
    xlim([-0.2 0.5])
    title({['latency: ' num2str(latency) ' ms'] , ['first peak: ' num2str(first_peak) ' ms']})
    subtitle(['peak: ' num2str(peak) ' ms'])
end
end