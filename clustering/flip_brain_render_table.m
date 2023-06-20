%% flip brain render table of clusters
clear
clc
[file, path] = uigetfile('clusters.csv','MultiSelect','off');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
T  = readtable(datafile);
midline = 5700;
%%
T.side(contains(T.experiment_name, 'R')) = 'Right';
T.side(contains(T.experiment_name, 'L')) = 'Left';
for i = 1:size(T, 2)
    if (contains(T.side(i), 'Left') && T.x(i) < midline)||(contains(T.side(i), 'Right') && T.x(i) > midline)
        T.x(i) = midline - (T.x(i) - midline);
    end
end
writetable(T, 'clusters_for_brian_render.csv')

%%