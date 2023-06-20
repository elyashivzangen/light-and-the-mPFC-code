%BOFRE AND AFTER
for i = 1:2
    [pl2_file,pl2_path]=uigetfile('*.pl2','Select all individual .pl2 files','MultiSelect','on');
    datafile = fullfile(pl2_path, pl2_file);
    exp_name = inputdlg(pl2_path,pl2_path,[1 40],"after_OPN");
    pl2_path1{i} = pl2_path;
    datafile1{i} = datafile;
    exp_name1{i} = exp_name;
    cd(pl2_path)
end
%%

%% lfp
for i = 1:2%length(datafile1)

    clc
    clearvars -except datafile1 exp_name1 pl2_path1 i
    %
    %parameters
    pre_time = 3; % time before onset to take in sec
    post_time = 6; %time after off to take in sec
    response_window = 10;
    samp_rate = 1000;%samp in HZPF
    add_position = 0;%add the position of each channel

    %load pl2
    %[pl2_file,pl2_path]=uigetfile('*.pl2','Select all individual .pl2 files','MultiSelect','on');
    %datafile = fullfile(pl2_path, pl2_file);
    %exp_name = inputdlg(pl2_path,pl2_path,[1 40],"PFC");
    %load mat
    % [mat_file,mat_path]=uigetfile('*.mat','Select all individual .mat files','MultiSelect','on');
    % matfiels = fullfile(mat_path, mat_file);
    exp_name = exp_name1{i};
    datafile = datafile1{i};
    pl2_path = pl2_path1{i};
    %%
    ND = [10, 8, 6, 4,3,2,1]; %cange if need
    LFP = array2table(zeros(length(ND), 1));
    LFP.Properties.VariableNames(1) = "ND";
    LFP.ND = ND';
    %load all FP channels
    for i = 1:size(datafile, 2)
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
        LFP.all_repetitions{i} = rep_fp;
    end

    %%
    LFP.cannel_mean = cellfun(@(x) squeeze(mean(x,2)),LFP.all_repetitions,'UniformOutput',false);
    LFP.channel_std = cellfun(@(x) squeeze(std(x,[],2)),LFP.all_repetitions,'UniformOutput',false);
    LFP.all_channel_mean = cellfun(@(x) squeeze(mean(x)) ,LFP.cannel_mean,'UniformOutput',false);
    %%
    time = -pre_time:1/samp_rate:(response_window+post_time);
    mkdir([pl2_path 'LFP_after'])
    new_file = ([pl2_path 'LFP_after\LFP']);
    rawfile = ([pl2_path 'LFP_after\raw_LFP']);
    rawLFP.data = fp;
    rawLFP.times.on = on;
    rawLFP.times.off = off;
    save(rawfile, "rawLFP")
    %close all
    %% plot
    ploting = 0;
    if ploting
        figure
        hold on;
        cellfun(@(x) plot(time, x), LFP.all_channel_mean)
        xline(0)
        xline(response_window)
        xlim([-1 1])

        figure
        hold on;
        plot(time, LFP.all_channel_mean{2})
        xline(0)
        xline(response_window)

        figure
        for ii = 1:7
            subplot(7,1, ii)
            plot(time, LFP.all_channel_mean{ii})
            xline(0)
            xline(response_window)


        end
    end
    %% add lfp positions
    if add_position
        channels_coordinates = readtable(['E:\PFC\LFP\' exp_name{1} '_channels_coordinates.csv']);
        locations = unique(channels_coordinates.acronym);
        short_names = cellfun(@(x) x(1:2), locations, UniformOutput=false);
        short_names = unique(short_names);
        locations = short_names;
        for i = 1:size(locations, 1)
            relevant_channels = find(contains(channels_coordinates.acronym, locations{i}));
            newLFP = LFP(:,"ND");
            for j = 1:size(newLFP, 1)
                newLFP.eria_mean{j} = squeeze(mean(LFP.all_repetitions{j}(relevant_channels, :, :)));
                newLFP.eria_std{j} =  squeeze(std(LFP.all_repetitions{j}(relevant_channels, :, :)));
                newLFP.total_mean{j} = squeeze(mean(newLFP.eria_mean{j}));
            end
            LFP.(locations{i}) = newLFP.total_mean;
            LFP.locations{1} = channels_coordinates;
            %save(['E:\PFC\LFP\' locations{i} '\' exp_name{1}], "newLFP")
        end
        LFP.all_repetitions = [];
        save(['E:\2022\CIMOGENTICS\LFP\' exp_name{1}], "LFP")
        save(new_file, "LFP")

    end
    LFP.all_repetitions = [];
    save(['E:\2022\CIMOGENTICS\LFP\' exp_name{1}], "LFP")

end