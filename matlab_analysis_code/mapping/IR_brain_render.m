clear
[file, path] = uigetfile('*.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path
load(datafile)
close all
cd(path)
clc
%%
clust_num = fieldnames(clusters.cluster_cells);
row = 0;
for i = 1:length(clust_num)
    cells = clusters.cluster_cells.(clust_num{i});
    for j = 1:length(cells)-1
        fit_on = cells{j}.fit_data.on.gof.rsquare;
        fit_off = cells{j}.fit_data.off.gof.rsquare;
        fit_sustained = cells{j}.fit_data.sustained.gof.rsquare;
        rsquare = max([fit_on,fit_off ,fit_sustained]);
        if rsquare > 0.5
            row = row + 1;
            cell_name = cells{j}.cell_name{1};
            id(1, row) = str2num(cell_name{1}(6:end));
            experiment_name{1, row} = cells{j}.exp_name;
            before_after_injection(1: row) = 1;
            cluster(1, row) = str2num(clust_num{i}(end));
            position{1 , row} = cells{j}.position{1};
            x(1, row) = cell2mat(cells{j}.cordinates.x);
            y(1, row) = cell2mat(cells{j}.cordinates.y);
            z(1, row) = cell2mat(cells{j}.cordinates.z);
        end
    end
end
id = id';
experiment_name =experiment_name';
before_after_injection = before_after_injection';
cluster = cluster';
position = position';
x = x';
y = y';
z = z';

brain_render_table = table(id, experiment_name, before_after_injection, cluster, position, x, y, z);

[file,path] = uiputfile('clustering_data.csv');
filename = fullfile(path, file);
writetable(brain_render_table, filename, 'Delimiter', ',')
