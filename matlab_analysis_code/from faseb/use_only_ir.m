clear
clc
%%
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
% p = 0.05; %pvalue
% numofint = 4; %number of intensities to check for response
% 
 mkdir 'deleted_cells'
 cd('deleted_cells')
% 
% normpval = p/numofint;%normalized p value
total_cells = 0;
deleted_cells = 0;
% response_times = {'on'; 'off'; 'sustained'};
%%
for i = 1:length(datafile)
    load(datafile{1,i});
    new_all_data = all_data;
    cells = fieldnames(new_all_data);
    for j = 1:length(cells)
        current_cell = new_all_data.(cells{j}).fit_data;
        total_cells = total_cells + 1;
        if not(current_cell.on.isIntEncoding || current_cell.off.isIntEncoding || current_cell.sustained.isIntEncoding)
            all_data = rmfield(all_data,cells{j});
            deleted_cells = deleted_cells + 1;
        end      
    end
%     new_path = [path 'deleted_cells'];
%     datafile_new = fullfile(new_path, file{i}); %save path
    save(file{i}, 'all_data')
end
sugnificant_cells = total_cells - deleted_cells;
cd(new_path)
save('total_cells', 'total_cells')
labels = {'ir cells', 'deleted cells'};
save('ir_cells', 'ir_cells')
explode = [1 1];
piefig = pie([sugnificant_cells deleted_cells],explode);
legend(labels);
savefig('piefig.fig')
                
            
                   
            
                
%%
% [pval, reponse_part] = min([current_cell(1:2).on.value; current_cell(1:2).off.value; current_cell(1:2).sustained.value]);

                
                
                
                
                
                
                