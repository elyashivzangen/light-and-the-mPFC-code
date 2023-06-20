% create channels mapping
%load cluster cordinates
[file,path]=uigetfile('*.csv','clusters_coordinates');
cluster_coordinates = readtable(fullfile(path, file));
cd(path)

%load cluster info
[file2,path2]=uigetfile('cluster_info.tsv','cluster_info');
cluster_info = tdfread(fullfile(path2, file2));

cluster_coordinates.ch = cluster_info.ch(ismember(cluster_info.id, cluster_coordinates.id));
writetable(cluster_coordinates, [path file(22:end-4) '_channels_mapping.csv' ])
writetable(cluster_coordinates,['E:\2022\LFP\' file(22:end-4) '_channels_mapping.csv'])




