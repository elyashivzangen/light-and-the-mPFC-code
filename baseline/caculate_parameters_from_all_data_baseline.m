%% caculate parameters from all data (baseline)
clear
clc
ploting =1 ;
window = 2; %(on, sus, off)
sus_window = 65:125;
%%
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%%
all_cells = [];
for i = 1:length(datafile)
    load(datafile{1,i});
    %     all_data = all_data.all_data;
    if iscell(all_data)
        all_data = all_data{1};
    end
    cell_names = fieldnames(all_data);
    expname = repmat(string(file{i}(1:9)), [length(cell_names), 1]);
    baseline = cell2mat(struct2cell(structfun(@(x) x.baseline_vector.mean, all_data,"UniformOutput",false)));
    if size(baseline,2) > 7
        baseline = baseline(:, [1,3,5,7:10]);
    end
    cluster = structfun(@(x) x.cluster, all_data);

    is_responsive = cell2mat(struct2cell(structfun(@(x) x.Is_reponsive, all_data, 'UniformOutput', false)));
    is_responsive_and_ir = cell2mat(struct2cell(structfun(@(x) x.Is_reponsive_and_IR, all_data,'UniformOutput', false)));
    if isfield(all_data.(cell_names{1}), 'region_acronym')
        position = structfun(@(x) x.region_acronym, all_data);
        t = table(expname, cell_names,baseline, cluster, position, is_responsive, is_responsive_and_ir);

    else
        t = table(expname, cell_names,baseline, cluster, is_responsive, is_responsive_and_ir);
    end
    all_cells = [all_cells; t];
end

%%
all_cells.steady = all_cells.is_responsive(:,2);
all_cells.steadyIE = all_cells.is_responsive_and_ir(:,2);
all_cells.early = all_cells.is_responsive(:,1);
all_cells.earlyIE = all_cells.is_responsive_and_ir(:,1);
all_cells.OFF = all_cells.is_responsive(:,3);
all_cells.OFF_IE = all_cells.is_responsive_and_ir(:,3);



% all_cells_baseline_mean = mean(cell2mat(all_cells{:, 'baseline'}));
x = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];
mean_baseline = mean(all_cells.baseline, 2);
all_cells.mean_baseline = mean_baseline;

intensities = flip(x);
G = groupsummary(all_cells,["steady", "steadyIE", "early", "earlyIE"] ,"mean","baseline");
intersections_table = G(:,1:5);
sem = @(x) std(x)/sqrt(size(x,1));
clusters_baseline = groupsummary(all_cells,"cluster" ,{"mean", "std", sem}, "baseline");
clusters_baseline.Properties.VariableNames{end} = 'sem_mean_baseline';
clusters_mean_baseline =  groupsummary(all_cells,"cluster" ,{"mean", "std", sem}, "mean_baseline");
clusters_mean_baseline.Properties.VariableNames{end} = 'sem_mean_baseline';

%%
varnames= G.Properties.VariableNames(1, 1:4)';
all_varnames = cell(length(G{:,1}),1);
figure
for i = 1:length(G{:,1})
    plot(intensities,G{i,"mean_baseline"}, '-o')
    hold on
end
legend(num2str(G{:,1:4}))
title(varnames)

%%
figure
for i = 1:length(clusters_baseline{:,1})
    plot(intensities,clusters_baseline{i,"mean_baseline"}, '-o')
    hold on
end
legend(num2str(clusters_baseline{:, "cluster"}))

mean_baseline_acrros_clusters.mean = mean(all_cells.baseline);
mean_baseline_acrros_clusters.std = std(all_cells.baseline);
mean_baseline_acrros_clusters.sem = sem(all_cells.baseline);
f_mean_basline = figure;
errorbar(intensities, mean_baseline_acrros_clusters.mean, mean_baseline_acrros_clusters.sem )




%%
h = figure;
bar(clusters_mean_baseline.cluster, clusters_mean_baseline.mean_mean_baseline) 
mkdir("baseline")
cd("baseline")
save("all_baselines", "all_cells")
save("7_ints_mean_baselines", "clusters_baseline")
save("mean_baseline", "clusters_mean_baseline")
savefig(h, 'mean_baseline')
save('mean_baseline_without_clusters', 'mean_baseline_acrros_clusters')
savefig(f_mean_basline, 'mean_baseline_without_clusters')
cd ..
save('intersections_table', 'intersections_table')
writetable( intersections_table ,'intersections_table.csv')