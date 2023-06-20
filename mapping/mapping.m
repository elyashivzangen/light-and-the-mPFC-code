clusters_mapping(m, p, shrinkage_factor, borders_table)


[file, path] = uigetfile('cluster_info.tsv');%When the user clicks the load data button, a window should open to enable the user to select a file. 
datafile = fullfile(path, file); %save path 


tdfread(datafile)
%find good clusters from group
good_clusters = find((ismember(KSLabel(:, 1), 'g') & ismember(group(:, 1), ' ')) | ismember(group(:, 1), 'g'));

%find id and depth
id = id(good_clusters);
cordinates = depth(good_clusters);

shrinked_cordinats = reference_probe_length_tip - shrinkage_factor/10*cordinates;


%find cordinates
cluster_cordinates = m + p.*(shrinked_cordinats);
x = cluster_cordinates(:, 1);
y = cluster_cordinates(:, 2);
z = cluster_cordinates(:, 3);

%find position
for i = 1:length(borders_table.lowerBorder)
    clusters_in =  shrinked_cordinats*10 < borders_table.lowerBorder(i) & shrinked_cordinats*10 > borders_table.upperBorder(i);
    region_name(clusters_in) = borders_table.name(i);
    region_acronym(clusters_in) = borders_table.acronym(i);
end

%save to tabel
T = table(id, x, y, z, region_name', region_acronym');
writetable(T, fullfile(path, 'cluster_cordinates.csv'), 'Delimiter', ',')



