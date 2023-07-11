%% reponsive and IR in each eria
%load csv file
clc
clear
[filename, path] = uigetfile("MultiSelect","off", ".csv");
datafile = fullfile(path, filename); %save path
T = readtable(datafile);
t = T(:, 2:end);
cluster_names = {'On Sustained', 'ON Suppressed 1', 'ON-OFF', 'ON Suppressed 2'};
%% plot
bar(categorical(t.Properties.VariableNames), t{4:5, :}')
legend(T{4:5,1});
% xlabel()
