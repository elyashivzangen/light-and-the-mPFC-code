%% devide right and left
%load brain render table
clc
clear
[filename, path] = uigetfile("MultiSelect","off", ".csv");
datafile = fullfile(path, filename); %save path
cd(path)
T = readtable(datafile);
%%
right_T = T(T.x < 5500, :);
left_T = T(T.x > 5500, :);
writetable(left_T, 'left_cells.csv')
writetable(right_T, 'rigth_cells.csv')
