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
%%
mean_psth_all_erias = grpstats(all_psthT, "position",["mean", "sem"],"DataVars", nd_names);
mean_psth_all_erias = sortrows(mean_psth_all_erias,"GroupCount", "descend");
mean_psth_main_structure = grpstats(all_psthT, "main_structure",["mean", "sem"],"DataVars", nd_names);
mean_psth_main_structure = sortrows(mean_psth_main_structure,"GroupCount", "descend");
all_cells_mean_psth = grpstats(all_psthT,[],["mean", "sem"],"DataVars", nd_names);

%% plot all cells psth
meanPSTH = cell2mat(table2cell(all_cells_mean_psth(1,2:2:end))');
struct_name = [ 'all cells  n = ' num2str( all_cells_mean_psth.GroupCount(1))];
f1 = ploting_figures(meanPSTH, struct_name);
save('all_cells_mean_psth', "all_cells_mean_psth")

%% plot main arieas psth
for i = 1:size(mean_psth_main_structure, 1)
    meanPSTH = cell2mat(table2cell(mean_psth_main_structure(i,3:2:end))');
    struct_name = [mean_psth_main_structure.main_structure{i} ' n = ' num2str( mean_psth_main_structure.GroupCount(i))];
    if mean_psth_main_structure.GroupCount(i) > 10
        f1 = ploting_figures(meanPSTH, struct_name);
        exportgraphics(f1, 'mean_psth_main_structures.pdf', 'Append',true)
    end
end
save('mean_sem_psth_main_structures', "mean_psth_main_structure")

%% plot main arieas psth
mkdir('layaers included')
cd('layaers included')
for i = 1:size(mean_psth_all_erias, 1)
    meanPSTH = cell2mat(table2cell(mean_psth_all_erias(i,3:2:end))');
    struct_name = [mean_psth_all_erias.position{i} ' n = ' num2str( mean_psth_all_erias.GroupCount(i))];
    struct_name(ismember(struct_name, '/')) = '_';
    if mean_psth_all_erias.GroupCount(i) > 5
        f1 = ploting_figures(meanPSTH, struct_name);
        exportgraphics(f1, 'mean_psth_all_erias.pdf', 'Append',true)
        close all
    end
end
save('mean_sem_psth_including_layaer', "mean_psth_all_erias")

cd .. 
%%

cd .. 
%%
function f1 = ploting_figures(meanPSTH, struct_name)
f1=  figure;
f1.Position = [100 100 1500 400];
t = -3:0.1:17;
subplot(1,3,1)
plot(t, meanPSTH)
nds = [10,8,6,4,3,2,1];
for i = 1:length(nds)
    nd_names{i} = ['nd' num2str(nds(i))];
end

legend(nd_names)
xlabel('time')
ylabel("firing rate")
title('all ints ' )
%%
subplot(1,3,2)
plot(t, meanPSTH(end,:))
xlabel('time')
ylabel('firing rate')
title('all nds')

%%
subplot(1,3,2)
plot(t, meanPSTH(end,:))
xlabel('time')
ylabel('firing rate')
title('nd = 1 ')
%% caculate ir
ir = mean(meanPSTH(:,65:125), 2);
subplot(1,3,3)
x = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];
plot(flip(x), ir, '-o')
save([struct_name(1:(end-4)) ' ir'], "ir")
xlabel('intensity')
ylabel('response')
title('mean sustained fr')


sgtitle(struct_name)
savefig(f1, struct_name(1:(end-8)))

end
