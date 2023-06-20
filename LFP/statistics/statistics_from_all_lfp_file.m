clc
clear
%% load all files
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%%
%in case of selcting only one file
if ~iscell(datafile)
    datafile = {datafile};
end
%% save the files by subreigions
ND = [10 8 6 4 3 2 1];
for i = 1:length(ND)
    NDname{i} = ['ND_' num2str(ND(i))];
end
all_channels_LFPs = [];
all_exp_LFPs = [];
for i = 1:length(datafile)
    load(datafile{1, i})
    locations = LFP.locations{1,1}.acronym;
    all_short_names = cellfun(@(x) x(1:2), locations, UniformOutput=false);
    [unique_shorts, ~, indices]= unique(all_short_names);
    for j = 1:size(unique_shorts, 1)
        if ~isfield(all_channels_LFPs, unique_shorts{j})
            all_channels_LFPs.(unique_shorts{j}) = table;
            all_exp_LFPs.(unique_shorts{j}) = table;
        end
        exp_name =[file{i}(1:end-4)];
        channels_num = sum(j == indices);
        rownum = size(all_exp_LFPs.(unique_shorts{j}), 1)+1;
        rownum_channels = size(all_channels_LFPs.(unique_shorts{j}), 1)+1;
        for w = 1:7
            relevant_channels = find(j == indices);
            number_of_channels = LFP.cannel_mean{w}(relevant_channels, :);
            mean_channel = mean(number_of_channels, 1);
            all_exp_LFPs.(unique_shorts{j}).(NDname{w})(rownum, :) = mean_channel;
            all_exp_LFPs.(unique_shorts{j}).(NDname{w})(rownum, :) = mean_channel;
            all_exp_LFPs.(unique_shorts{j}).Properties.RowNames(rownum) = {exp_name};
            for z = 1:size(relevant_channels, 1)
                name = [exp_name '_' num2str(relevant_channels(z))];
                all_channels_LFPs.(unique_shorts{j}).(NDname{w})(rownum_channels - 1 + z, :) = number_of_channels(z, :);
                all_channels_LFPs.(unique_shorts{j}).Properties.RowNames(rownum_channels - 1 + z, :) = {name};
            end
        end
    end
end
%% save all
cd('all_locations')
save('all_exp_each_eria', "all_exp_LFPs" )
save('all_chennels_each_eria', "all_channels_LFPs")

%% clculate statistics
erias = fieldnames(all_channels_LFPs);
for i = 1:size(erias, 1)
    T = all_channels_LFPs.(erias{i});
    varnames = T.Properties.VariableNames;
    meanT.(erias{i}) = grpstats(T,[],"mean");
    meanT.(erias{i}).Properties.VariableNames(2:end) = varnames;
    meanT.(erias{i}).Properties.RowNames = "mean";
    stdT = grpstats(T,[],"std");
    stdT.Properties.RowNames = "std";
    stdT.Properties.VariableNames(2:end) = varnames;
    meanT.(erias{i}) = [meanT.(erias{i}); stdT];
    steT = grpstats(T,[], @(x) sem(x, 1));
    steT.Properties.RowNames = "ste";

    steT.Properties.VariableNames(2:end) = varnames;

    meanT.(erias{i}) = [meanT.(erias{i}); steT];


    if ploting
        f(i) = figure;
        set(gcf, "Position", [200, 200, 750, 750])
        sgtitle([erias(i), 'n = ' num2str(meanT.(erias{i}).GroupCount) ' channels'])

        for j = 1:7
            subplot(7,1,j)
            plot(-3:0.001:16, meanT.(erias{i}){1,1+j})
            hold on
            xline(0)
            xline(10)
            title(T.Properties.VariableNames{j})
        end
        ax = f(i);
        exportgraphics(ax,'LFP_per_earia.pdf','Append',true)
        savefig(erias{i})
    end
end
meanLFP = rmfield(meanT,["cc", "fa", "ci", "ro", "OL"]);
% stdLFP = rmfield(STDT,["cc", "fa", "ci", "ro", "OL"]);
% steLFP = rmfield(steLFP,["cc", "fa", "ci", "ro", "OL"]);

% meanLFP.mean = meanLFP;
% meanLFP.std = stdLFP;
% meanLFP.ste = steLFP;


save("mean_lfp_per_eria", "meanLFP")
%% use mean T
erias = fieldnames(meanLFP);
for i = 1:size(erias, 1)
    f(i) = figure;
    T = meanLFP.(erias{i});

    set(gcf, "Position", [200, 200, 750, 750])
    sgtitle([erias(i), 'n = ' num2str(meanT.(erias{i}).GroupCount) ' channels'])
    for j = 1:7
        spect = spectrogram(T{1,j +1});
        spectrogram(T{1,j +1},'yaxis')
        subplot(7,1,j)
        plot(-3:0.001:16, meanT.(erias{i}){1,1+j})
        hold on
        xline(0)
        xline(10)
        title(T.Properties.VariableNames{j})
    end
end