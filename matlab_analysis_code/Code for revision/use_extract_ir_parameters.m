%% use_extract_ir_parameters
clear
clc
% load dreadds all cells
[file, path] = uigetfile('DREREDDS_all_cells.mat');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
load(file)
dreadds_all = all_cells;

nan_cells = find(cellfun(@(x) isempty(x), all_cells{1}.Is_reponsive));

all_cells{1}(nan_cells,:) = [];
all_cells{2}(nan_cells,:) = [];

[fit_parameters.all_cells, all_cells_before_after_fit_parameters_DREEDDS] = extract_ir_parameters(dreadds_all, 'all_cells', 0 ,1);
use_responsive = 0; %use responsive and not IR
%%

all_cells2 = all_cells;
responsive_cell = cellfun(@(x) x(2), all_cells{1}.Is_reponsive_and_IR);
if use_responsive
responsive_cell = cellfun(@(x) x(2), all_cells{1}.Is_reponsive);
end
responsive_cell = find((responsive_cell));
IR_cells{1} = all_cells2{1}(responsive_cell,:);
IR_cells{2} = all_cells2{2}(responsive_cell,:);
[fit_parameters.IR, before_after_fit_parameters_DREEDDS] = extract_ir_parameters(IR_cells, 'IR_cells', 0,1);
%%
% load control all cells
[file, path] = uigetfile('control_all_cells.mat');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
load(file)
[fit_parameters.all_cells_control, all_cells_before_after_fit_parameters_control] = extract_ir_parameters(all_cells, 'all_cells_control', 0 ,1);
%%
% all_cells2 = all_cells;
responsive_cell = cellfun(@(x) x(2), all_cells{1}.Is_reponsive_and_IR);
if use_responsive

responsive_cell = cellfun(@(x) x(2), all_cells{1}.Is_reponsive);
end

responsive_cell = find((responsive_cell));
IR_cells{1} = all_cells2{1}(responsive_cell,:);
IR_cells{2} = all_cells2{2}(responsive_cell,:);
[fit_parameters.IR_control,  before_after_fit_parameters_CONTROL] = extract_ir_parameters(IR_cells, 'IR_control', 0, 1);
%% ceack all options for pVAL   
for i = 1:size(fit_parameters.all_cells, 2)
    % test IR
    f1 = figure;
    f1.Position = [492 503 1101 475];
    sgtitle(fit_parameters.IR.Properties.VariableNames{i});

    subplot(1,2,1)
    histogram(fit_parameters.all_cells{:,i})
    hold on
    xline(mean(fit_parameters.all_cells{:,i}), LineWidth=2, Color='red')
    histogram(fit_parameters.all_cells_control{:,i})
    xline(mean(fit_parameters.all_cells_control{:,i}), LineWidth=2, Color='k')  
    [~, all_cells_pval{i}] = ttest2(fit_parameters.all_cells{:,i}, fit_parameters.all_cells_control{:,i});
    title("all cells")

    subtitle(['pval = ' num2str(all_cells_pval{i})])

    subplot(1,2,2)
    histogram(fit_parameters.IR{:,i})
    hold on
    xline(mean(fit_parameters.IR{:,i}), LineWidth=2, Color='red')
    histogram(fit_parameters.IR_control{:,i})
    xline(mean(fit_parameters.IR_control{:,i}), LineWidth=2, Color='k')  
    [~, IR_pval{i}] = ttest2(fit_parameters.IR{:,i}, fit_parameters.IR_control{:,i});
        title("IR cells")

    subtitle(['pval = ' num2str(IR_pval{i})])

    exportgraphics(f1,'pvals.pdf', 'Append',true)
    close(f1)
end
fit_parameters_date_vs_control = fit_parameters;

save('fit_parameters_date_vs_control', 'fit_parameters_date_vs_control')
%% MORE ANALIZING IR CELLS
for i = 1:size(before_after_fit_parameters_CONTROL{1}, 2)
    f1 = figure;
    anova1([before_after_fit_parameters_CONTROL{1}{:,"n"},before_after_fit_parameters_CONTROL{2}{:,"n"}])
       anova1([before_after_fit_parameters_DREEDDS{1}{:,"n"},before_after_fit_parameters_DREEDDS{2}{:,"n"}])

    bar([before_after_fit_parameters_CONTROL{1}])
end
%% create IR curve from all cells/all IR cells
control_all = all_cells;
dreadds_all = all_cells2;
% control_all{1} = join(control_all{1}, )
%%
responsive_cell = cellfun(@(x) x(2), control_all{1}.Is_reponsive);
responsive_cell = find((responsive_cell));
control_IE{1} = control_all{1}(responsive_cell,:);
control_IE{2} =control_all{2}(responsive_cell,:);


responsive_cell = cellfun(@(x) x(2), dreadds_all{1}.Is_reponsive);
 responsive_cell = find((responsive_cell));
dreadds_IE{1} = dreadds_all{1}(responsive_cell,:);
dreadds_IE{2} =dreadds_all{2}(responsive_cell,:);

%%
 [dreadds.before, dreadds.after] = plot_magnitude_before_and_after_from_all_cells(dreadds_IE, 'dreadds_all_cells');
 [control.before, control.after] = plot_magnitude_before_and_after_from_all_cells(control_IE, 'control_all_cells');
dreadds.before.Properties.RowNames = {};
dreadds.after.Properties.RowNames = {};
control.before.Properties.RowNames = {};
control.after.Properties.RowNames = {};

%%
 % plot all cells together

x = [15.4000000000000;14.9000000000000;14.4000000000000;13.9000000000000;12.9000000000000;11.4000000000000;9.40000000000000];
f1 = figure;
f1.Position = [680 139 1104 839];
subplot(2,2,1)
plot(flip(x), mean(cell2mat(dreadds.before.response)), '-o')
hold on
plot(flip(x), mean(cell2mat(dreadds.after.response)), '-o')
plot(flip(x), mean(cell2mat(control.before.response)), '-o')
plot(flip(x), mean(cell2mat(control.after.response)), '-o')
% legend(["dreadds before", "dreadds after", "control before", "control after"])
title('response')


subplot(2,2,2)
plot(flip(x), mean(cell2mat(dreadds.before.zscore),"omitnan"), '-o')
hold on
plot(flip(x), mean(cell2mat(dreadds.after.zscore),"omitnan"), '-o')
plot(flip(x), mean(cell2mat(control.before.zscore),"omitnan"), '-o')
plot(flip(x), mean(cell2mat(control.after.zscore),"omitnan"), '-o')
% legend(["dreadds before", "dreadds after", "control before", "control after"])
title('zscore')


subplot(2,2,3)
plot(flip(x), mean(cell2mat(dreadds.before.magnitude),"omitnan"), '-o')
hold on
plot(flip(x), mean(cell2mat(dreadds.after.magnitude),"omitnan"), '-o')
plot(flip(x), mean(cell2mat(control.before.magnitude),"omitnan"), '-o')
plot(flip(x), mean(cell2mat(control.after.magnitude),"omitnan"), '-o')
lgd  = legend(["dreadds before", "dreadds after", "control before", "control after"]);
lgd.Position = [0.6543 0.2680 0.1196 0.0828];
title('magnitude')
%%
T = [dreadds.before(:,["magnitude","baseline_vector","response","Is_reponsive_and_IR","Is_reponsive","zscore"]);
    dreadds.after(:,["magnitude","baseline_vector","response","Is_reponsive_and_IR","Is_reponsive","zscore"]);
    control.before(:,["magnitude","baseline_vector","response","Is_reponsive_and_IR","Is_reponsive","zscore"]);
    control.after(:,["magnitude","baseline_vector","response","Is_reponsive_and_IR","Is_reponsive","zscore"])];
T.tags = [repmat("dreadds before", size(dreadds.before, 1),1);
       repmat("dreadds after", size(dreadds.after, 1),1);
       repmat("control before", size(control.before, 1),1);
       repmat("control after", size(control.after, 1),1)];
T.magnitude = cell2mat(T.magnitude);
T.zscore = cell2mat(T.zscore);
T.response = cell2mat(T.response);
T.Is_reponsive_and_IR = cell2mat(T.Is_reponsive_and_IR);
T.Is_reponsive = cell2mat(T.Is_reponsive);


mean_sem_parameters_for_all_4_groups = grpstats(T,"tags",["mean", "sem"],"DataVars",["magnitude", "response", "zscore", "Is_reponsive_and_IR", "Is_reponsive"]);




mag = cell2mat(T.magnitude);
z_sc = cell2mat(T.zscore);
[p,tbl,stats] = anova1(mag(:,7), T.tags)
results = multcompare(stats);
%% magnitude response
function [before, after] = plot_magnitude_before_and_after_from_all_cells(all_cells, name)
before = all_cells{1};
bad_cells = cellfun(@(x)  length(x) == 8 ,before.intensities);
bad_cells = find(bad_cells);
before(bad_cells, :) = [];

after = all_cells{2};
after(bad_cells, :) = [];

before_ints = before.intensities;
after_ints = after.intensities;

[before.response, before.zscore, before.magnitude] = cellfun(@(x) calaulate_magnitude_from_singal_cell_intensties(x,2), before_ints, UniformOutput=false);
[after.response, after.zscore, after.magnitude] = cellfun(@(x) calaulate_magnitude_from_singal_cell_intensties(x,2 ), after_ints, UniformOutput=false);



% plot 
x = [15.4000000000000;14.9000000000000;14.4000000000000;13.9000000000000;12.9000000000000;11.4000000000000;9.40000000000000];
f1 = figure;
f1.Position = [680 139 1104 839];
subplot(2,2,1)
plot(flip(x), mean(cell2mat(before.response)), '-o')
hold on
plot(flip(x), mean(cell2mat(after.response)), '-o')
title('response')



subplot(2,2,2)
plot(flip(x), mean(cell2mat(before.zscore), "omitnan"), '-o')
hold on
plot(flip(x), mean(cell2mat(after.zscore), "omitnan"), '-o')
title('zscore')


subplot(2,2,3)
plot(flip(x), mean(cell2mat(before.magnitude), "omitnan"), '-o')
hold on
plot(flip(x), mean(cell2mat(after.magnitude), "omitnan"), '-o')
title('magnitude')

save([name '_before'],'before')
save([name '_after'],'after')

savefig(f1, [name 'before_and_after_IR_curves'])


end