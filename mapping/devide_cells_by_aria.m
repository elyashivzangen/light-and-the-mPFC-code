%%devide_cells_by_aria
clear
clc
%%
%save only Intensity encoding + IR
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
for i = 1:length(datafile)
    load(datafile{1,i});
    temp_all_data = all_data;
    cells = fieldnames(all_data);
    position = cell(length(cells), 1);
    for j = 1:length(cells)
        position{j} = all_data.(cells{j}).position{1};
        slash = ismember(position{j}, '/');
        if sum(slash)
            position{j}(slash) = '_';
        end

    end
    [uniqe_positions,~ , indices]= unique(position);

    for j = 1:length(uniqe_positions)
        all_data = rmfield(temp_all_data, cells(indices ~= j));
        %IR_responsive = [IR_responsive structfun(@(x) (x.Is_reponsive_and_IR(2)), all_data,'UniformOutput',true)];
        temp_filename = [file{i}(1:end-4) '_' uniqe_positions{j} '.mat'];
        mkdir(uniqe_positions{j})
        cd(uniqe_positions{j})
        save(temp_filename, 'all_data', '-mat')
        cd(path)
    end
end
