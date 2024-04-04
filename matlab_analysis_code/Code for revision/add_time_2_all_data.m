%% add timing to 
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path

cd('H:\mPFC\shiras_data\PFC')
cd('E:\2023 - ledramp')
%%
for i = 1:length(file)
    all_data = importdata(datafile{i});
    if iscell(all_data)
        all_data = all_data{1};
    end
    [file2, path2] = uigetfile('files_extracted_data.csv',file{i});%When the user clicks the load psetion button, a window should open to enable the user to select a file.
    datafile2 = fullfile(path2, file2);
    files_data = readtable(datafile2);
    cell_names = fieldnames(all_data);
    for j = 1:length(cell_names)
        all_data.(cell_names{j}).time =  files_data.plexon_time;
    end
    save(datafile{i}, 'all_data')
end
