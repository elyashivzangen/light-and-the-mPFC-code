clear
clc
%%
%save only Intensity encoding + IR
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%%
window_names = {'ON', 'Sustanied', 'OFF'};
% for w = 1:length(window_names)
%     mkdir(window_names{w});
% end
mkdir('ON_SUSTAINED')
for i = 1:length(datafile)
%     for w = 1:length(window_names)
        load(datafile{1,i});
        %     all_data = all_data.all_data;
        cells = fieldnames(all_data);
        for j = 1:length(cells)
            current_cell = all_data.(cells{j});
            if ~sum(current_cell.Is_reponsive_and_IR(1:2))
                all_data = rmfield(all_data,cells(j));
            end
        end
        new_datafile = fullfile([path, 'ON_SUSTAINED'], file(i));
        if ~isempty(new_datafile)
            save(new_datafile{1}, 'all_data')
        end
%     end

end
%%

