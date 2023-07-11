clear
clc
%cluster cordinates load 
[file, path] = uigetfile('clusters_coordinates.csv');
datafile = fullfile(path, file);
[~,~,raw] = xlsread(datafile);

cd(path);




%load cell display outpute (analyzed data) 
[file, path] = uigetfile('*.mat');
datafile = fullfile(path, file);
load(datafile);
if ~iscell(all_data)
    clear all_data
    x = load(datafile);
    all_data{1} = x.all_data;
end

% add mapping to each cell

for i = 1:length(all_data)
    field_names = fieldnames(all_data{i});
    for j = 1:length(field_names)
        cell_num = str2double(field_names{j}(6:end));
        mapping_cell_num = find([raw{2:end, 1}] == cell_num)+1; %find the position of the current cell in the mapping file
        all_data{i}.(field_names{j}).position = raw(mapping_cell_num, strcmp(raw(1,:), 'region_name'));
        all_data{i}.(field_names{j}).cordinates.x = raw(mapping_cell_num, strcmp(raw(1,:), 'x'));
        all_data{i}.(field_names{j}).cordinates.y = raw(mapping_cell_num, strcmp(raw(1,:), 'y'));
        all_data{i}.(field_names{j}).cordinates.z = raw(mapping_cell_num, strcmp(raw(1,:), 'z'));
        all_data{i}.(field_names{j}).region_acronym = raw(mapping_cell_num, strcmp(raw(1,:), 'region_acronym'));
    end
end

save(datafile, 'all_data', '-mat')
 

full_data = all_data;
cell_names = fieldnames(full_data{1});
position = cell(length(cell_names), 1);
for i = 1:length(cell_names)
    position{i} = full_data{1}.(cell_names{i}).position{1};
end
[uniqe_positions,~ , indices]= unique(position);
for i = 1:length(uniqe_positions)
    for j = 1:length(full_data)
        all_data = rmfield(full_data{j}, cell_names(indices ~= i));
        uniqe_positions{i} = strrep(uniqe_positions{i},'/','_');            
        temp_filename = [file(1:end-4) '_' uniqe_positions{i} '.mat'];
        save(fullfile(path, temp_filename) , 'all_data', '-mat')
        all_datafile = fullfile('E:\2022\cimogenitic_all_cell_display', temp_filename);
        save(all_datafile, 'all_data')
    end
end



