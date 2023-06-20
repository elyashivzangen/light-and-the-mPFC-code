[app.file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file. 
datafile = fullfile(path, app.file); %save path
file_numes = length(app.datafile);
all_files = cell(1, file_numes);
for i = 1:file_numes
    all_files{1, i} = load(app.datafile{1,i});
    all_files{1, i} = app.all_files{1, i};
end
row = 0;
for w = 1:length(app.all_files)
    for a = 1:numel(app.all_files{1, w}.all_data)
        cell_names = fieldnames(app.all_files{1, w}.all_data);
        %extract the PSTH for each cell from the best
        %responding intensty as determend in the cell display
        %app (by the lowest pvalue).
        for i = 1:numel(cell_names)
            row = row + 1;
            data = app.all_files{1, w}.all_data.(cell_names{i});
            %compute zscore
            baseline_std = data(1).baseline_vector.std;
            
        end