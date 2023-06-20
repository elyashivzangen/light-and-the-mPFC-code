%add_before_and _after
%split before and after
clear
clc
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)


%%
for i = 1:length(file)
    if contains(file{i}, 'before')
        all_data{1,1} = load(file{i});
        all_data{1,1} = all_data{1,1}.all_data;
        all_data{1,2} = load([file{i}(1:end-11) '_after.mat']);
        all_data{1,2} = all_data{1,2}.all_data;
        save([file{i}(1:end-11) '_both.mat'], 'all_data')
    end
end