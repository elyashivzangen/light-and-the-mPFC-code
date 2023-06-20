clear
clc
%%
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
p = 0.05; %pvalue
numofint = 4; %number of intensities to check for response

mkdir (['significant_cells_' num2str(numofint)])

normpval = p/numofint;%normalized p value
total_cells = 0;
deleted_cells = 0;
response_times = {'on'; 'off'; 'sustained'};
%%
x = [];
y= [];
z= [];
id= [];
cluster = [];
% experiment_name = [];

for i = 1:length(datafile)
    load(datafile{1,i});
    new_all_data = all_data;
    cells = fieldnames(new_all_data);
    for j = 1:length(cells)
        current_cell = new_all_data.(cells{j}).intensities;
        total_cells = total_cells + 1;
        x =  [x; all_data.(cells{j}).cordinates.x{1}];
        y = [y; all_data.(cells{j}).cordinates.y{1}];
        z = [z; all_data.(cells{j}).cordinates.z{1}];
        id = [id; str2double(cells{j}(6:end))];
        
        
        
        
        for w = 1:numofint
            w2 = w;
            if isempty(current_cell(w).on) %case a cell is empty beccause not all intensities where checked in the exp
                w2 = w2 + 1;
            end
            [pval, reponse_part] = min([current_cell(w2).on.value; current_cell(w2).off.value; current_cell(w2).sustained.value]);
            if current_cell(w2).on.value > normpval && current_cell(w2).off.value >  normpval && current_cell(w2).sustained.value >  normpval %no sugnificant response
                if w == numofint %cheak if it is the last intensity to use
                    all_data = rmfield(all_data,cells{j});
                    deleted_cells = deleted_cells + 1;
                    cluster = [cluster; 2];
                    
                end
            else
                all_data.(cells{j}).ND2use.num = w;
                all_data.(cells{j}).ND2use.pvalue = pval;
                all_data.(cells{j}).ND2use.reponse_part = response_times{reponse_part};
                cluster = [cluster; 1];
                break
            end
        end
    end
%     experiment_name = [experiment_name repmat(file{i}, j, 1)];
    new_path = [path 'significant_cells_' num2str(numofint)];
    datafile_new = fullfile(new_path, file{i}); %save path
    save(datafile_new, 'all_data')
    
end
sugnificant_cells = total_cells - deleted_cells;
cd(new_path)
save('total_cells', 'total_cells')
labels = {'sugnificant cells', 'deleted cells'};
save('sugnificant_cells', 'sugnificant_cells')
explode = [1 1];
piefig = pie([sugnificant_cells deleted_cells],explode);
legend(labels);
savefig('piefig.fig')
brain_render_table = table(id, cluster, x,y,z);
writetable(brain_render_table, 'clustering_data.csv', 'Delimiter', ',')






%%
% % [pval, reponse_part] = min([current_cell(1:2).on.value; current_cell(1:2).off.value; current_cell(1:2).sustained.value]);
% cd('C:\Users\elyashivz\Dropbox\מחקר\תוצאות\FASEB\all_Cell_dispplay_withIR\NAC\significant_cells_4')
% X = readtable('clustering_data.csv');
% cd('C:\Users\elyashivz\Dropbox\מחקר\תוצאות\FASEB\all_Cell_dispplay_withIR\str\significant_cells_4')
% Y = readtable('clustering_data.csv');
% brain_render_table = [X;Y];
% 
% 
% 
