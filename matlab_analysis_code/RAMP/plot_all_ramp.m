%% plot all ramps
clear
clc
norm = 1;
%% add togethter meny WF files
cd('E:\2022\ramp_psth')
[filename path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
datafile = fullfile(path, filename); %save path
%%
AR = []; %ALL RAMP FILES
for i = 1:length(datafile)
    %     CTparameters.
    
    load(datafile{i});
    %    if sum(strcmp('files_path',fieldnames(CTparameters)))
    %         CTparameters.files_path = [];
    %    end
    if i > 1 && ~(length(AR.psth(1,:)) == length(ramp_psth.psth(1,:)))
        [x, pos] = min([length(AR.psth(1,:)) length(ramp_psth.psth(1,:))]);
        if pos == 1
            ramp_psth.psth(:, x+1:end)  = [];
        else
            AR.psth(:, x+1:end) = [];
        end
    end
    ramp_psth.exp_id = cellstr(ramp_psth.exp_id);
    
    AR = [AR; ramp_psth];
end
%% normalize
if norm
    for i = 1:size(AR, 1)
        AR.psth(i, :)= AR.psth(i, :)/max(AR.psth(i, :));
    end
end

%%
clusters = unique(AR.clusters);
for i = 1:length(clusters)
    figure
    mean_ramp = mean(AR.psth(clusters(i) == AR.clusters, :),1);
    mean_ramp = mean_ramp(2:end-1);
    binned_ramp =  bin_psth(mean_ramp, 60);
%          plot(binned_ramp )
    
    plot(smooth(binned_ramp, 0.25, 'lowess'))
    title(clusters(i))
    subtitle(['n = ' num2str(sum(clusters(i) == AR.clusters))])
    
end


