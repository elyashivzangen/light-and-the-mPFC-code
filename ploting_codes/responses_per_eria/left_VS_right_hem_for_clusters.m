%% plot right vs left form brain render table OF CLUSTERS
clear
clc
[file, path] = uigetfile('clusters_brain_render_table.csv','MultiSelect','off');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
T  = readtable(datafile);
%%
T.side = categorical(T.side);
left_vs_rigth = groupsummary(T,["side", "cluster"]);
Left = table2array(left_vs_rigth(1:4,3));
Right = table2array(left_vs_rigth(5:end,3));
cluster_num = (1:4)';
T2 = table(cluster_num, Left, Right);
writetable(T2, 'left_VS_right_clsuters.csv','WriteRowNames', true)
%%
x = table2array(T2);
bar(x(:,2:end))
legend({'left', 'right'}, 'Location','northeast')

