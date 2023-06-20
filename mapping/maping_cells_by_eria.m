%% change cells with eria
[file, path] = uigetfile('*.csv');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
mkdir('arias')
datafile = fullfile(path, file); %save path
T = readtable(datafile);
cluster_num = length(unique(T.cluster));
[positions, ~ ,idx] = unique(T.position);
clusters_table = array2table(zeros(cluster_num, 0));
for i = 1:length(positions)
    new_T = T(idx == i, :);
    slash = ismember(positions{i}, '/');
    if sum(slash)
        positions{i}(slash) = '_';
    end

    new_datafile = fullfile([path, 'arias\'], [positions{i} '.csv']);
    writetable(new_T, new_datafile, 'Delimiter', ',')
    number_of_cells(i) = size(new_T, 1);
    for j = 1:cluster_num
        clusters_table.(positions{i})(j) = sum(new_T.cluster == j);
    end
    clusters_table.(positions{i})(j+1) = sum(clusters_table.(positions{i}));   
end
clusters_table.sum = sum(clusters_table{:,2:end},2);
writetable(clusters_table, 'clusters_table.csv', 'Delimiter', ',')