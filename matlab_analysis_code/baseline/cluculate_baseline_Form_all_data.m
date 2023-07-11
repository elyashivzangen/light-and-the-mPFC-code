%plot_basline_per_clsuter_clsuters only for phb
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
%%
NDs = [10 8 6 4 3 2 1];
if ~iscell(file)
    file{1} = file;
end
baselines = [];
clusters = [];
for i = 1:length(file)
    load(file{i})
    cells = struct2cell(all_data);
    for j = 1:length(cells)
        if ~isfield(cells{j}, 'baseline_vector')
            ints = cells{j}.intensities;
            for w = 1:length(ints)
                new_basline(w) = ints(w).baseline.mean;
            end
            new_basline = flip(new_basline);
            cells{j}.baseline_vector.mean = new_basline;
        end
        if length(cells{j}.baseline_vector.mean) > 7
            cells{j}.baseline_vector.mean = cells{j}.baseline_vector.mean(11-NDs);
        end
        baselines = [baselines; cells{j}.baseline_vector.mean];
        clusters = [clusters; cells{j}.cluster];
    end
end
T = table(baselines, clusters);
clusters_baseline = groupsummary(T,"clusters", ["mean", "std"]);
clusters_baseline.sem = clusters_baseline.std_baselines./sqrt(clusters_baseline.GroupCount);
save("cluster_baseline", "clusters_baseline")
%%
x = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];

for i  = 1:4
    figure
    errorbar(flip(x),clusters_baseline.mean_baselines(i,:), clusters_baseline.sem(i,:))
end