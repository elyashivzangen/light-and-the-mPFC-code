%% load all data 
%use psth fun to add the 10ms binned psth to the old all data.
clear
clc

%%
for i = 1:5
    cd('G:\My Drive\תוצאות\PFC')
    % take the old all data and add to the name
    orig_exp_name{i} = uigetfile('*.mat');
    selpath{i} = uigetdir('E:\2022', orig_exp_name{i});
    exp_name{i} =  [orig_exp_name{i}(1:end-4) '_10ms'];
end
%%
for i = 1:4
    cd(selpath{i})
    if ~isfile('files_extracted_data.csv')
        cd ..
        cd('pl2kilosort')
        copyfile("files_extracted_data.csv", selpath{i})
        copyfile("events_ts.csv", selpath{i})
    end
    cd(selpath{i})
    all_data2 = PSTH_fun(selpath{i}, 'G:\My Drive\10_ms_all_data', exp_name{i});
    cd('G:\My Drive\תוצאות\PFC')
    load(orig_exp_name{i})
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        all_data.(cells{j}).bin10ms = all_data2.(cells{j}).intensities;
    end
    save(['new' orig_exp_name{i}], 'all_data')
end

