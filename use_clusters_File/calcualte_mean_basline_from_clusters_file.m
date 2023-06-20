%% calcualte_mean_basline_from_clusters_file
clear
clc
[file, path] = uigetfile('*.mat','MultiSelect','off');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
load(datafile)
close all
w = 2; %window to use (on, sustaneid, off)
%%
close all
nd = [10 8 6 4 3 2 1];
f1 = figure;
f1.Position = [200, 200, 1500 ,300];
all_cells = struct2cell(clusters.cluster_cells);
for i = 1:length(all_cells)
    c_cluster = all_cells{i}';
    c_cluster(end) = [];
    f(i) = figure;
    f(i).Position = [200, 200, 250 ,800];
    for j = 1:length(nd)
        rep_baseline{i, j} = cellfun(@(x) x.intensities(nd(j)).repetition_baseline.mean,c_cluster,'UniformOutput',false);
        min_length = min(cellfun(@length, rep_baseline{i, j}));
        rep_baseline{i, j} = cell2mat(cellfun(@(x) x(1:min_length), rep_baseline{i, j}, 'UniformOutput', false));
        subplot(7,1, j)
        plot(mean(rep_baseline{i, j},1), '-o')
        title(['nd ' num2str(nd(j))])       
    end
    sgtitle(['cluster ' num2str(i)])
    exportgraphics(f(i), 'E:\rep_baseline.pdf', 'Append',true)
    baseline{i} = cell2mat(cellfun(@(x) x.baseline_vector.mean,c_cluster,'UniformOutput',false));
    mean_baseline(i, :) = mean(baseline{i});
    sem_baseline(i, :) = sem(baseline{i}, 1);
    figure(f1);
    subplot(1,4, i)
    errorbar(flip(all_cells{1, 1}{1, 1}.x), mean_baseline(i, :), sem_baseline(i, :), '-o')
    title(['clsuter ' num2str(i)])
end
%% save all


path = uigetdir("baseline");
cd(path)
savefig(f1, 'all_clusters_baseline_change')
save('mean_baseline', 'mean_baseline')
save('sem_baseline', 'sem_baseline')
save('all_baselines', 'baseline')


%%

