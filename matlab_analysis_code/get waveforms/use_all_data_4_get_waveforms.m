%% get
clc, clear
[file, path] = uigetfile('*.mat', 'MultiSelect','on');
datafile = fullfile(path, file);
%%
for i = 8:length(datafile)

    load(datafile{i})
    cell_names = fieldnames(all_data);
    new_path = all_data.(cell_names{1}).source_dir;
    % find the relevant folder
    cd(new_path)

    if ~isfile("temp_wh.dat")
        cd ..
        if isfile("temp_wh.dat")
            new_path = pwd;
        else
            cd("kilosort")
            if isfile("temp_wh.dat")
                new_path = pwd;
            else
                disp(['wronge file location for ' file{i}])
            end
        end
    end
    cd(path)    



    CTparameters = get_celltype_parameters_function(new_path, 'temp_wh.dat', file(i));
    for j = 1:length(cell_names)
        all_data.(cell_names{j}).CTP = CTparameters(find(CTparameters.id == str2num(cell_names{j}(6:end))), :);
    end
    file{i}
    save(datafile{i}, "all_data")
end