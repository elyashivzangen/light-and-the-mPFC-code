clear
[file, path] = uigetfile('*.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path
load(datafile)
close all
%%
f4 = figure;
set(f4,'color', [1 1 1]);
set(f4,'position',[50 50 500 750]);

cells_matrix = ~contains(clusters.matrix(:,1), 'A_');%% all cells from semester B
relevant_cells = clusters.matrix(cells_matrix,:);
relevant_cells = relevant_cells(84:end, :); %plot only from last experiments
for i = 1:5
    cluster_idx = find(cell2mat(relevant_cells(:, 4)) == i);
    cluster_cells = cell2mat(relevant_cells(cluster_idx, 5:end));
    subplot(5,1, i)
    
    mean_cluster_psth = mean(cluster_cells,1);
    plot(mean_cluster_psth)
    
    title(['cluster = ' num2str(i) ' num of cell = ' num2str(length(cluster_idx))])
end