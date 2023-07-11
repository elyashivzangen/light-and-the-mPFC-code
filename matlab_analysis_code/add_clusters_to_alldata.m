clear
clc

%%
%load clsuters file
[file2, path2] = uigetfile('clusters.mat','MultiSelect','off');
clusters_file = fullfile(path2, file2);
load(clusters_file)
close all
%%
%load all data files
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
bin_size = clusters.clustering_binsize/0.1;
if ~iscell(datafile)
    datafile = {datafile};
end
%%
for i = 1:length(datafile)
    load(datafile{1,i});
    if iscell(all_data)
        all_data = all_data{1};
    end
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        current_cell = all_data.(cells{j});
        psth_data = current_cell.intensities(clusters.intensity_used).psth.mean;
        cut_end = mod(length(psth_data), bin_size);
        binned_psth = mean(reshape(psth_data(1:end-cut_end), bin_size, []), 1);
        %check if normalized to boundes and if so normlize the
        %psth
        if clusters.normalize2bound
            psth_norm = binned_psth/max(abs(binned_psth));
        else
            psth_norm = binned_psth;
        end
        new_response_bins = (clusters.response_bins(1)/clusters.clustering_binsize):(clusters.response_bins(end)/clusters.clustering_binsize);
        PC_vector = (psth_norm(new_response_bins))*(clusters.coeff(:, 1:clusters.gm.NumVariables));
        all_data.(cells{j}).cluster = cluster(clusters.gm,PC_vector); %cluster the cell

        %add a new row to cluster for the new cell
%         new_ids{1} = app.file_name;
%         new_ids{2} = a;
%         new_ids{3} = cell_name;
%         new_ids{4} = cell_data.cluster;
%         new_row = [new_ids num2cell(best_intensity_pvalues.psth.mean')];
        %add the row to cluster matrix
        %save to clusters
%             clusters.matrix = [clusters.matrix; new_row];
%     
%             %insert the cell to the relevant cluster
%             cluster_name = ['cluster_' num2str(cell_data.cluster)];
%             clusters.cluster_cells.(cluster_name){end} = cell_data;
%             clusters.cluster_cells.(cluster_name){end}.cell_name = cell_name;
%             clusters.cluster_cells.(cluster_name){end}.exp_name = [app.file_name '_' num2str(a)];
%             clusters.cluster_cells.(cluster_name){end + 1} = []; %add a cell for next iteration
    end
    save(datafile{1,i}, 'all_data')
end
