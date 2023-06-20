clear
clc
%%
%save only Intensity encoding + IR
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%%
to_delete = 'corpus callosum'; %delete corpus coloosum cells
count = 0;
for i = 1:length(datafile)
    load(datafile{1,i});
    %     all_data = all_data.all_data;
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        current_cell = all_data.(cells{j});
        if contains(current_cell.position{1}, to_delete)
            all_data = rmfield(all_data,cells(j));
            count = count + 1;
        end
    end
    save(datafile{1,i}, "all_data")

end

