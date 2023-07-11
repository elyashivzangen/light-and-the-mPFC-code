% create psth vector from all data
%% load all data files
clear
clc
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%% calulate
count = 0;
nds = [10,8,6,4,3,2,1];
for i = 1:length(nds)
    nd_names{i} = ['nd' num2str(nds(i))];
end

for i = 1:length(datafile)
    %     for w = 1:length(window_names)
    load(datafile{1,i});
    if iscell(all_data)
        all_data = all_data{1,1};
    end
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        count = count + 1;
        current_cell = all_data.(cells{j});
        ints = current_cell.intensities;
        exp_name = file{i}(1:end-4);
        cell_name = cells{j};
        baseline(count, :) = current_cell.baseline_vector.mean;
        position{count, 1} = current_cell.region_acronym{1,1};
        main_structure{count, 1} = position{count, 1}(1:2);
        coordinats{count, 1} = current_cell.cordinates;
        rowname{count,1} = [exp_name '_' cell_name];
        is_responsive(count,:) = current_cell.Is_reponsive(1:2);
        is_ir(count,:) = current_cell.Is_reponsive_and_IR(1:2);
        cluster(count,1) = current_cell.cluster;
        int_num = 0;
        if length(ints) > 7
            cur_nds = nds;
        else
            cur_nds = 1:7;
        end
        for k = cur_nds
            int_num = int_num + 1;
            all_psth{count, int_num} = ints(k).psth.mean';
            int_baseline = ints(k).intensty_baseline.mean;
            if ~int_baseline
                int_baseline = 0.2; %dont exclude vary low baslines
            end
            magnitude_psth{count, int_num} =all_psth{count, int_num}/int_baseline;
        end
    end
end


%%
only_psth =  cell2table(all_psth, "RowNames",rowname, "VariableNames",nd_names);
all_psthT  = cell2table(magnitude_psth, "RowNames",rowname, "VariableNames",nd_names);
all_psthT.position = position;
all_psthT.main_structure = main_structure;
all_psthT.coordinats = coordinats;
all_psthT.is_responsive = is_responsive;
all_psthT.is_ir = is_ir;
all_psthT.cluster = cluster;
mkdir('all cells psth')
cd('all cells psth')
save('all_cells_PSTH', 'all_psthT')