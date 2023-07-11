%% calculate Magnitude index
%% load all data files
clear
clc
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%% calulate
count = 0;
window_names = {'ON', 'Sustanied', 'OFF'};
for i = 1:length(datafile)
%     for w = 1:length(window_names)
        load(datafile{1,i});
        %     all_data = all_data.all_data;
        cells = fieldnames(all_data);
        fit_windowns = {40:50, 65:125, 140:150};
        for j = 1:length(cells)
            count = count + 1;
            current_cell = all_data.(cells{j});
            baseline(count) = current_cell.intensities(1).intensty_baseline.mean;           
            cells_psth(count, :) = current_cell.intensities(1).psth.mean;
            clusters_list(count) = current_cell.cluster;
            for w = 1:length(window_names)
                magnitude(count, w) =(mean(cells_psth(count, fit_windowns{w}))/baseline(count));
                all_data.(cells{j}).magnitude(w) = magnitude(count, w);
            end
        end
        
        save(datafile{1,i}, 'all_data')
end
mkdir('magnitude index')
cd('magnitude index')
T = array2table(magnitude,...
    'VariableNames',window_names);
clusters = clusters_list';
T = [T array2table(clusters)];
writetable(T, 'magnitude_index.csv')
%% mean per clusters
n = 2;%part of window (2=susteind)

uc = unique(clusters_list);
f4= figure;
set(f4,'position',[50 50 1700 300]);

for i = uc
    subplot(1,4,i)
    histogram(table2array(T(T.clusters == i, n)))
    title(i)
    relevant_magnitude(i, :) = mean(table2array(T(T.clusters == i, 1:3)), 1);
    relevant_magnitude_std(i, :) = std(table2array(T(T.clusters == i, 1:3)), 1);
end
cluster = uc';
M = array2table(cluster);
Magnitude_mean = [M array2table(relevant_magnitude,...
    'VariableNames',window_names)];
Magnitude_std = [M array2table(relevant_magnitude_std,...
    'VariableNames',window_names)];
%% plot per cluster
n = 2;%part of window (2=susteind)
figure
bar(cluster, relevant_magnitude(:, n))
title('Magnitude across clusters')



%% BOX PLOT
boxplot(T.Sustanied, T.clusters)
savefig('magnitude index')



