%split before and after
clear
clc
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
for i = 1:length(datafile)
    load(datafile{1,i});
    if iscell(all_data)
        new_data = all_data;
        all_data = new_data{1,1};
        save([datafile{1,i}(1:end-4) '_before.mat'], "all_data");
        if length(new_data) > 1
            all_data = new_data{1,2};
            save([datafile{1,i}(1:end-4) '_after.mat'], "all_data")
        end
    end
end

