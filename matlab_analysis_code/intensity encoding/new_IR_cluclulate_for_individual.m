%calculate new correct fit
clear all_data
clc

%%
% Needs to be in D:\Data\IR data Shira_May_14_2022

[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path

calculate_IE_fun(datafile, file, path);
