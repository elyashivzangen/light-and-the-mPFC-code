%%devide_cells_by_aria
clear
clc
%%
%save only Intensity encoding + IR
row_names = {'total'; 'responsive'; 'IR'; '%_reponsive'; '%_IR' };
T = table(row_names);
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
window_names = {'ON', 'Sustanied', 'OFF'};
for w = 1:length(window_names)
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
        if ~ismember(uniqe_positions{j},T.Properties.VariableNames)
            T.(uniqe_positions{j}) = zeros(5,1);
        end
        all_data = rmfield(temp_all_data, cells(indices ~= j));
        T.(uniqe_positions{j})(3) = T.(uniqe_positions{j})(3) + sum(structfun(@(x) (x.Is_reponsive_and_IR(w)), all_data,'UniformOutput',true));
        T.(uniqe_positions{j})(2) = T.(uniqe_positions{j})(2) + sum(structfun(@(x) (x.Is_reponsive(w)), all_data,'UniformOutput',true));
        T.(uniqe_positions{j})(1) = T.(uniqe_positions{j})(1) + sum(indices == j);

    end
end
T{4, 2:end} = T{2, 2:end}/T{1, 2:end}*100;
T{5, 2:end} = T{3, 2:end}/T{1, 2:end}*100;

writetable(T, [ window_names{w} '_IR_responsive.csv'], 'Delimiter', ',')
end
