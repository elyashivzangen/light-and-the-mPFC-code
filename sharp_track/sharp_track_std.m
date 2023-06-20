%% compare diffrent sharp track iterations between people
% load all cluster cordinates
clc
clear
[file, path] = uigetfile('*.csv','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
%%
for i = 1:length(file)
    cell_coordinates{i} = readtable(file{i});
    cords.ML(i,:) =  cell_coordinates{i}.x';
    cords.DV(i,:) =  cell_coordinates{i}.y';
    cords.AP(i,:) =  cell_coordinates{i}.z';
end

T_coords = struct2table(cords);
G = groupsummary(T_coords,[],"std");
xyz = table2cell(G(:,2:end));
xyz = xyz';
mean_std_xyz = mean(cell2mat(xyz), 2);
mean_sem_xyz = mean_std_xyz/sqrt(3);
save('coordinats_of_all_cells',"T_coords")
save('std_of_all_cells', 'G')
save('mean_std', 'mean_std_xyz')
save('mean_sem','mean_sem_xyz' )