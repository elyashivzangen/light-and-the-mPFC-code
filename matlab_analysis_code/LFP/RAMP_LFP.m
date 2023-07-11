clear all
[pl2_file,pl2_path]=uigetfile('*.pl2','Select all individual .pl2 files','MultiSelect','on');
datafile = fullfile(pl2_path, pl2_file);
%%
pre_time = 3; % time before onset to take in sec
post_time = 6; %time after off to take in sec
response_window = 120;
samp_rate = 1000;%samp in HZPF
%%
%RAMP LFP FROM PL2
LFPs = cell(1,size(datafile, 2));
all_exp = table;
all_chennels = table;
for i = 1:size(datafile, 2)
    T = table;
    fp = [];
    rep_fp = [];
    for j  = 1:32
        ad = PL2AdBySource(datafile{i},'FP', j);
        fp(j,:) = ad.Values;
    end
    on = PL2EventTs(datafile{i}, 11);
    on = floor(on.Ts*samp_rate);
    off = PL2EventTs(datafile{i}, 12);
    off = floor(off.Ts*samp_rate);
%     min_window = min(off-on)+1; %smallest window of on - off
    
    for j = 1:length(on)
        window = (on(j)-pre_time*samp_rate):(on(j)+(response_window+post_time)*samp_rate);
        rep_fp(:, j, :) = fp(:, window);
    end
    % crate ND_matrix
    events = table(on, off);
    exp_name = pl2_file{i}(1:end-4);
    writetable(events, [pl2_path exp_name '_events.csv'])
    %save([datafile{i}(1:end-4) '_all_lfp_rep.mat'], "rep_fp")
    coordinates = readtable([datafile{i}(1:end-4) '_channels_coordinates.csv']);
    T.mean_fp = squeeze(mean(rep_fp, 2));
    T.std = squeeze(std(rep_fp, [],2));
    short_cords =  cellfun(@(x) x(1:2), coordinates.acronym, 'UniformOutput', false);
    T.location = short_cords;
    save([datafile{i}(1:end-4) '_mean_lfp.mat'], "T")
    areasT = groupsummary(T,"location",["mean", "std"],"mean_fp");
    areasT.exp_name = repmat(exp_name, [size(areasT, 1), 1]);
    all_exp = [all_exp; areasT];
    all_chennels = [all_chennels; T];
end

%%
all_exp.Properties.VariableNames{3} = 'fp';
all_chennels.Properties.VariableNames{1} = 'fp';
all_areas_per_exp = groupsummary(all_exp,"location",["mean", "std"],"fp");
all_areas_per_channel = groupsummary(all_chennels,"location",["mean", "std"],"fp");

save([pl2_path 'all_areas_per_exp'], "all_areas_per_exp")
save([pl2_path 'all_areas_per_channel'], 'all_areas_per_channel')
save([pl2_path 'all_exp'], "all_exp")
save([pl2_path 'all_chennels'], 'all_chennels')

parameters = table(pre_time, response_window, post_time, samp_rate);
writetable(parameters, "fp_parameters.csv")

%%
for i = 1:size(all_areas_per_exp, 1)
    figure
    plot(all_areas_per_channel{i, "mean_fp"})
    hold on
    plot(bin_psth(all_areas_per_channel{i, "mean_fp"}, 1000), 'LineWidth', 2)
    title(all_areas_per_channel{i, "location"})
    subtitle(['n = ' num2str(all_areas_per_channel{i, "GroupCount"})])
    xline(pre_time*samp_rate)
    xline((response_window+pre_time)*samp_rate)
        savefig(['per_channel_' all_areas_per_channel{i, "location"}{1}])

end

for i = 1:size(all_areas_per_exp, 1)
    figure
    plot(all_areas_per_exp{i, "mean_fp"})
    hold on
    plot(bin_psth(all_areas_per_exp{i, "mean_fp"}, 1000), 'LineWidth', 2)
    title(all_areas_per_exp{i, "location"})
    subtitle(['n = ' num2str(all_areas_per_exp{i, "GroupCount"})])
    xline(pre_time*samp_rate)
    xline((response_window+pre_time)*samp_rate)
    savefig(['per_exp_' all_areas_per_exp{i, "location"}{1}])
end
