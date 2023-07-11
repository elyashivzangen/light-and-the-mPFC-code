%% all ramps from all data
clc

%% get relevant parameters
[file, path] = uigetfile('all_rampT.mat');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
load(file)
baseline = cell2mat(cellfun(@(x) x.mean, allT.baseline_vector,UniformOutput=false));
psth = cell2mat(cellfun(@(x) x(1).psth.mean', allT.intensities, UniformOutput=false));
norm_psth = psth./baseline(:,end);
ramp = cellfun(@(x) x(1).mean', allT.ramp, UniformOutput=false);
transp = cellfun(@(x) size(x, 1) > 1, ramp);
ramp(find(transp)) = cellfun(@(x) x', ramp(find(transp)), 'UniformOutput', false);
ramp = cell2mat(ramp);
norm_ramp = (ramp - mean(ramp(:, 1:10),2))./mean(ramp(:, 1:10),2);
short_position = cellfun(@(x) x(1:2), position, UniformOutput=false);
short_position = categorical(short_position);
cluster = cell2mat(allT.cluster);
ir = cell2mat(cellfun(@(x) x(2).y' ,allT.new_fit, UniformOutput=false));
is_res = cell2mat(allT.Is_reponsive);
is_res = is_res(:,2);
is_ir = cell2mat(allT.Is_reponsive_and_IR);
is_ir = is_ir(:,2);
is_enhanced = mean(psth(:,65:125), 2) > 0;
is_ramp_enhanced = mean(norm_ramp(:,45:75),2) > 0;
position = cellfun(@(x) x{1,1}, allT.region_acronym, UniformOutput=false);
relT = table(is_res, is_ir, cluster, position, short_position, is_enhanced,is_ramp_enhanced, ir, psth,ramp,norm_ramp, norm_psth, RowNames=allT.Properties.RowNames);
relT2 = relT;
relT2.position = [];
%%
ir_cells = relT(find(relT.is_ir), :);
res_cells = relT(find(relT.is_res), :);

x1 = plot_from_grp_stats(ir_cells, "position", 'ie_with_layers');
x2 = plot_from_grp_stats(ir_cells, "short_position", 'ie_cells');
x3 = plot_from_grp_stats(res_cells, "short_position", 'responsive_with_layers');
x4 = plot_from_grp_stats(res_cells, "position", 'responsive cells');
x5 = plot_from_grp_stats(relT, "position", 'all_cells_with_layers');
x6 = plot_from_grp_stats(relT, "short_position", 'all_cells');

%%

%%
function x = plot_from_grp_stats(data, groupby, name)
ints = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];
x = grpstats(data, groupby,"mean", "DataVars",["norm_psth", "ir", "norm_ramp", "is_ramp_enhanced", "is_res", "is_ir"]);
f1 = figure;
f1.Position = [100 100 1500 800];
subplot(2,2,1)
plot(x.mean_norm_psth')
legend(x{:,1})

subplot(2,2,2)
plot(x.mean_norm_ramp')
legend(x{:,1})

subplot(2,2,3)
plot(ints, x.mean_ir, '-o')
legend(x{:,1})
subplot(2,2,4)
subplot(2, 4, 7);
bar(categorical(x.(groupby)), x{:,"mean_is_ramp_enhanced"})
title("% of ramp enhanced")

subplot(2, 4, 8);
bar(categorical(x.(groupby)), x{:,"GroupCount"})
title("number of cells")

sgtitle(name,'Interpreter','none')
save(name, "x")
savefig(f1, name)
exportgraphics(f1, 'all_figs.pdf', Append=true)
end