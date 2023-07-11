clear
[file, path] = uigetfile('*.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path
load(datafile)
close all
clc
%%

data = clusters.matrix;
for i = 1:size(data,1)
    figure
    plot(cell2mat(data(i,5:end)))
    hold on
    plot(clusters.mean(cell2mat(data(i, 4)), :));
    plot([30 30],[-4 8],'--k');
    plot([130 130],[-4 8],'--k');
    title(data(i, 1))
    subtitle([data(i, 3), ' ' , data(i, 4) ])
end
    