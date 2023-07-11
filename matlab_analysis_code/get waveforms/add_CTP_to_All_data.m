%% add togethter meny WF files
clear
clc
[filename, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
%%
all_CTP = [];
for i = 1:2:(length(filename))
    load(filename{i})
    'exp_num'
    filename{i}
    filename{i + 1}
    load(filename{i + 1})
    for j = 1:length(CTparameters.id)
        cell_num = CTparameters.id(j);
        cell_name = ['cell_' num2str(cell_num)];
        if ~isfield(all_data, cell_name)
            continue
        end
        newCTP = CTparameters(j, :);
        baseline_fr = mean(all_data.(cell_name).baseline_vector.mean);
        newCTP.baseline_fr = baseline_fr;
        all_data.(cell_name).CTP = newCTP;
        newCTP.is_responsive = all_data.(cell_name).Is_reponsive;
        newCTP.is_responsive_and_ir = all_data.(cell_name).Is_reponsive_and_IR;
        newCTP.cluster = all_data.(cell_name).cluster;
        newCTP.baseline_fr_int1 = all_data.(cell_name).baseline_vector.mean(1);
        if isfield( all_data.(cell_name), 'position')
        newCTP.position =  all_data.(cell_name).position;
        newCTP.coordinates =  all_data.(cell_name).cordinates;
        end
        newCTP.files_path = [];
        newCTP.ints =  {all_data.(cell_name).intensities};
        newCTP.experiment_id = {filename{i}(1:8)};
        all_CTP = [all_CTP; newCTP];
    end
    save(filename{i}, 'all_data')
end
save('all_CTP', 'all_CTP')