function clusters_mapping(m, p, shrinkage_factor, borders_table, reference_probe_length_tip)


[file, path] = uigetfile('cluster_info.tsv');%When the user clicks the load data button, a window should open to enable the user to select a file. 
datafile = fullfile(path, file); %save path 
cd(path)

info = tdfread(datafile);
%find good clusters from group
good_clusters = find((ismember(info.KSLabel(:, 1), 'g') & ismember(info.group(:, 1), ' ')) | ismember(info.group(:, 1), 'g'));
if ~ismember(info.group(:, 1), ' ')
    good_clusters = find(ismember(info.KSLabel(:, 1), 'g'));
end
%find id and depth
id = info.id(good_clusters);
cordinates = info.depth(good_clusters);

shrinked_cordinats = reference_probe_length_tip - shrinkage_factor/10*cordinates;


%find cordinates
cluster_cordinates = m + p.*(shrinked_cordinats);
%SWICH THE X AND Z BECAUSE THAT IS HOW BRAIN RENDER READES IT
x = cluster_cordinates(:, 3)*10;
y = cluster_cordinates(:, 2)*10;
z = cluster_cordinates(:, 1)*10;

%find position
region_name = cell(length(id), 1);
region_acronym = region_name;
for i = 1:length(borders_table.lowerBorder)
    clusters_in =  shrinked_cordinats*10 < borders_table.lowerBorder(i) & shrinked_cordinats*10 > borders_table.upperBorder(i);
    region_name(clusters_in) = borders_table.name(i);
    region_acronym(clusters_in) = borders_table.acronym(i);
end

%save to tabel
T = table(id, x, y, z, region_name, region_acronym);
exp_name = inputdlg("EXP_NAME:");
writetable(T, fullfile(path, ['clusters_coordinates_' exp_name{1} '.csv']), 'Delimiter', ',')



