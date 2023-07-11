clear
clc
%%
%save only Intensity encoding + IR
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path

%%
window_names = {'ON', 'Sustanied', 'OFF'};
for w = 1:length(window_names)
    mkdir(window_names{w});
end
for i = 1:length(datafile)
    for w = 1:length(window_names)
        load(datafile{1,i});
        if iscell(all_data)
            all_data = all_data{1};
        end
        %     all_data = all_data.all_data;
        cells = fieldnames(all_data);
        for j = 1:length(cells)
            current_cell = all_data.(cells{j});
            if ~current_cell.Is_reponsive_and_IR(w)
                all_data = rmfield(all_data,cells(j));
            end
        end
        new_datafile = fullfile([path, window_names{w}], file(i));
        if ~isempty(new_datafile)
            save(new_datafile{1}, 'all_data')
        end
    end

end

