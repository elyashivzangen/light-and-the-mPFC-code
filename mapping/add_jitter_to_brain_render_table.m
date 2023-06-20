%% create jitter added to the brain_render data

clear
clc
[file, path] = uigetfile('*.csv','MultiSelect','off');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
T = readtable(datafile);
%% add the jitter
rng(1)
for i = 1:length(T.x)
    T.x(i) =  T.x(i) + rand(1)*50 - 25;
    T.y(i) =  T.y(i) + rand(1)*50 - 25;
    T.z(i) =  T.z(i) + rand(1)*50 - 25;
end
writetable(T, append(file(1:(end-4)), "_jittered.csv"));