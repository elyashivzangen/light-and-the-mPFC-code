% This MATLAB code appears to perform several data processing tasks related to a persistence index for a set of neural recordings. Here's a breakdown of what each section of the code does:
% 
% File Selection
% The user is prompted to select one or more .mat files containing neural recordings data. The uigetfile function allows the user to select files using a graphical user interface.
% 
% Loading Data and Computing Persistence Index
% The code loads each of the selected files and extracts data from each recording's "intensities" field. It then calculates a persistence index for each recording, which involves computing the average spike rate in a specific time window following a stimulus and determining the point in time where the spike rate crosses a threshold value of zero.
% 
% Constructing a Table
% The code constructs a table presistenceT containing various calculated parameters, such as the persistence index, mean spike rates, and standard deviations for each cluster and neural cell.
% 
% Saving Results to a Directory
% The code saves the table presistenceT to a new directory called "persistence_index."
% 
% Grouping and Analyzing Data by Cluster
% The code groups the calculated parameters by cluster and computes the mean and standard deviation of the persistence index and spike rates for each cluster. It then generates a figure for each cluster showing the mean spike rates over time, with error bars indicating the standard error of the mean persistence index at the time where the spike rate crosses the threshold value of zero.
% 
% Saving Results to a File
% The code saves the analysis results to a new file called "persistence_table_mean_by_cluster" and saves the generated figures to a new directory.

%% SUSTAEIND INDEX
clear
clc
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
%%
NDs = [10 8 6 4 3 2 1];
count = 0;
for i = 1:length(file)
    load(file{1,i});
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        c = all_data.(cells{j});
        ints = c.intensities;
        count = count + 1;
        clusters(count,1) = c.cluster;
        is_responsive_and_ir(count,:) = c.Is_reponsive_and_IR;
        is_responsive(count,:) = c.Is_reponsive;
        cell_name{count,1} = cells{j};
        expname{count,1} = file{1,i};
        for k = 1:length(NDs)
            idx = 8 - k;
            if length(ints) > 7
                idx = NDs(k);
            end
            after_psth = mean(ints(idx).intensty_data( 1:40,2:end), 2) - ints(idx).intensty_baseline.mean;
            full_psth{count,k} = [ints(idx).psth.mean after_psth'];
            full_psth_matrix(count, k ,:) =full_psth{count,k};
            sus_win = mean(ints(idx).intensty_data( 65:125,:), "all") - ints(idx).intensty_baseline.mean ;
            is_excite = sus_win > 0;
            if is_excite
                c_sus_ind = find(smooth(full_psth{count,k}(142:end)) < 0, 1);
            else
                c_sus_ind = find(smooth(full_psth{count,k}(142:end)) > 0, 1);
            end
            if isempty(c_sus_ind) % if cell did not cross 0 setpesist_idx to max 
                 presist_idx(count,k) = length(full_psth{count,k}(142:end));
            else
                presist_idx(count,k) = c_sus_ind;
            end

        end
        all_data.(cells{j}).full_psth = full_psth{count,:};
        all_data.(cells{j}).presist_idx = presist_idx(count,k);
    end
end
presistenceT = table(expname,cell_name, clusters, is_responsive_and_ir,is_responsive, full_psth,presist_idx, full_psth_matrix);
%%
mkdir('persistence_index')
cd('persistence_index')
save("persistence_table", "presistenceT")

%% caculate parameters
T1 = groupsummary(presistenceT, "clusters",{"mean", "std"},{["presist_idx", "full_psth_matrix"]});
T1.sem_presist_idx = T1.std_presist_idx./sqrt(T1.GroupCount);
save("persistence_table_mean_by_cluster", "T1")
off_time = 141;
f1 = figure;
f1.Position = [100,100, 1200, 800];
for i = 1:T1.clusters(end)
    subplot(2,2,i)
    plot(-4:0.1:20, squeeze(T1.mean_full_psth_matrix(i,:,:)))
    hold on
    xline(0)
    xline(10)
    nd1_persist_idx = round(T1.mean_presist_idx(i, 7))*0.1 + 10;
    errorbar(nd1_persist_idx , squeeze(T1.mean_full_psth_matrix(i,7,round(T1.mean_presist_idx(i, 7))+off_time)), T1.sem_presist_idx(i,7)*0.1,'horizontal', 'r', 'LineWidth',3)
    title(['presist idx nd 1: ' num2str(T1.mean_presist_idx(i, 7)) ' ms'])
end
savefig(f1, 'persistence_index_nd_1')
exportgraphics(f1, 'persistence_index_nd_1.tif')


cd ..



