clear
clc
%% cluster cordinates load
cd('E:\')
[file, path] = uigetfile('clusters_coordinates.csv');
datafile = fullfile(path, file);
X = readtable(datafile);
%load all_cell_parameters
cd('E:\2022\all_cell_parameters')
[file, path] = uigetfile('cell_type_parameters.mat');
datafile = fullfile(path, file);
load(datafile)

writetable(X,fullfile('E:\2022\all_coordinates',[file(1:end-25) '_clusters_coordinates.csv']))

%%
newCTparameters = CTparameters;
[regions, ~, indices] = unique(X.region_name);
for i = 1:length(regions)
        relevant_cells = X.id(indices==i);
        CTparameters = newCTparameters(ismember(newCTparameters.id,relevant_cells),:);
        temp_filename = [datafile(1:end-4) '_' regions{i} '.mat'];
        save(temp_filename, 'CTparameters', '-mat')
       
end
