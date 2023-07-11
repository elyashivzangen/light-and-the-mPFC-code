%%
clear
[file, path] = uigetfile('*.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path
load(datafile)
cd(path)
close all
clc
%%
for x = 1:size(clusters.mean, 1)
    all_data = [];
    clusters_name = ['cluster_' num2str(x)];
    data = clusters.cluster_cells.(clusters_name); % change to change the cluster reclusterd
    for i = 1:(length(data)-1)
        cell_name = ['cell_' num2str(i)];
        data{i}.cluster = x;
        all_data.(cell_name) = data{i};
    end
    save(clusters_name, 'all_data')  
end
