% add ramp 2 all data
clear
clc

%% run
%load all data
[file, path] = uigetfile('*.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path
load(datafile)
if iscell(all_data)
    all_data = all_data{1,1};
end
cells = fieldnames(all_data);

% load_ramp
[file, path] = uigetfile('ramp_table.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
datafile2 = fullfile(path, file); %save path
load(datafile2)


[file, path] = uigetfile('fullraster.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
datafile3 = fullfile(path, file); %save path
load(datafile3)

for i = 1:length(cells)
    cell_num = cells{i}(6:end);
    all_data.(cells{i}).ramp.mean = ramp_table.(cell_num);
    cell_idx = find(strcmp(ramp_table.Properties.VariableNames, cell_num));
    all_data.(cells{i}).ramp.total = total_PSTH(cell_idx, :);

end
save(datafile, 'all_data')
