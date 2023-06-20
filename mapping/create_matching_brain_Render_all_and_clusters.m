%craete a clusters brain render file with the same cordinates of the all
%cells cluster (and solve the fliping problem and jitter problem)

%load clustering brain render table
clear
clc
[file, path] = uigetfile('clustersing_data.csv','MultiSelect','off');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
T  = readtable(datafile);

%load clustering brain render table
[file, path] = uigetfile('clustering_data_early_stedy_jittered.csv','MultiSelect','off');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path
T2  = readtable(datafile);

%%
for i = 1:size(T,1)
    tc = T(i, 1:9); %current cell
    %chaeck that this is the same cell as the all_cells table and copy it
    %with the new clsuter
    relevant_idx = find(T2.z > (tc.z - 25) & T2.z < (tc.z + 25) & T2.y > (tc.y - 25) & T2.y < (tc.y + 25) & tc.id == T2.id & contains(T2.exp_name, tc.experiment_name{1}(1:8)) & contains(T2.position, tc.position) & ismember(T2.cluster, [10, 12]));
    T3(i, :) = T2(relevant_idx,:);
    T2.cluster(relevant_idx) = tc.cluster;
    T3.cluster(i) = tc.cluster;
end
writetable(T3,"clusters_brain_render_table.csv" )
writetable(T2, "clusters_brain_render_table_with_all_cells.csv")




