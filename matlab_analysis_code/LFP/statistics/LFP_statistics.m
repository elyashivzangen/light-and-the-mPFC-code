%LFP STATSITICS
clc
clear
%% load all files
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%%
%in case of selcting only one file
if ~iscell(datafile)
    datafile = {datafile};
end
all_LFP = table;

for i = 1:length(datafile)
    load(datafile{1,i})
    all_LFP.(file{i}(1:end-4)) = newLFP.total_mean;
    array_LFP(i, :, :) = newLFP.total_mean;
end

LFP_3D = (reshape(cell2mat(table2array(all_LFP)), 7, size(all_LFP, 2), []));
mean_LFP = squeeze(mean(LFP_3D, 2));
std_LFP = squeeze(std(LFP_3D, [], 2));

plot(mean_LFP')
legend(num2str(newLFP.ND))
xlim([2500 3500])
