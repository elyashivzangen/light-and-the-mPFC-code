clear
clc
on_window = 40:50;
sus_window = 100:130;
%%
% Needs to be in D:\Data\IR data Shira_May_14_2022

[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
for i = 1:length(datafile)
    load(datafile{1,i});
%     all_data = all_data.all_data;
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        current_cell = all_data.(cells{j});
        current_ND = 0;
        x = [];
        y = [];
        for k = 1:length(current_cell.intensities)
            if isempty( current_cell.intensities(k).intensty_data )
                continue
            end
            raster = current_cell.intensities(k).intensty_data;
            y = [y ; (mean(raster(on_window, :), 1))'];
            current_ND =  current_ND  + 1;
            x(end+1 :end+size(raster,2)) = current_cell.fit_data.on.intensities(current_ND);
        end
        x = x';
%         min_y = abs(min(y));
%         y = y + abs(min(y));
        all_data.(cells{j}).fit_data.on.y = y;
        all_data.(cells{j}).fit_data.on.x = x;
    end
        save(datafile{1,i}, 'all_data')

end