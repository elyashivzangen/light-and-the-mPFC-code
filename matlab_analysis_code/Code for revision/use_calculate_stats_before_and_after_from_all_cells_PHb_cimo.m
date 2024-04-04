%% use_calculate_stats_before_and_after_from_all_cells
[file, path] = uigetfile('all_cells_control.mat');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
load(file)
all_cells_control = all_cells;
[all_parameters_diff_cont, all_parameters_diff_percentage_cont, control_all_cells_parameters] = calculate_stats_before_and_after_from_all_cells(all_cells, 'all_cells_control');



all_cells2 = all_cells;
responsive_cell = cellfun(@(x) x(2), all_cells{1}.Is_reponsive);
responsive_cell = find((responsive_cell));
RESPONSIVE_cells{1} = all_cells2{1}(responsive_cell,:);
RESPONSIVE_cells{2} = all_cells2{2}(responsive_cell,:);
[RESPONSIVE_all_parameters_diff_cont, RESPONSIVE_all_parameters_diff_percentage_cont, control_responsive_response_parameters] = calculate_stats_before_and_after_from_all_cells(RESPONSIVE_cells, 'RESPONSIVE_CELLS_control');


control = {all_parameters_diff_cont, all_parameters_diff_percentage_cont,RESPONSIVE_all_parameters_diff_cont, RESPONSIVE_all_parameters_diff_percentage_cont };


[file, path] = uigetfile('all_cells_DREEDDS.mat');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
load(file)
all_cells_DREEDDS = all_cells;
nan_cells = find(cellfun(@(x) isempty(x), all_cells{1}.Is_reponsive));

all_cells{1}(nan_cells,:) = [];
all_cells{2}(nan_cells,:) = [];
all_cells_DREEDDS{1}(nan_cells,:) = [];
all_cells_DREEDDS{2}(nan_cells,:) = [];


[all_parameters_diff, all_parameters_diff_percentage, DREDDS_all_cells_response_parameters] = calculate_stats_before_and_after_from_all_cells(all_cells, 'all_cells_DREEDDS');
all_cells{1}(nan_cells,:) = [];
all_cells{2}(nan_cells,:) = [];
all_cells2 = all_cells;
responsive_cell = cellfun(@(x) x(2), all_cells{1}.Is_reponsive);
responsive_cell = find((responsive_cell));
RESPONSIVE_cells{1} = all_cells2{1}(responsive_cell,:);
RESPONSIVE_cells{2} = all_cells2{2}(responsive_cell,:);
[RESPONSIVE_all_parameters_diff, RESPONSIVE_all_parameters_diff_percentage, DREDDS_resposive_response_parameters] = calculate_stats_before_and_after_from_all_cells(RESPONSIVE_cells, 'RESPONSIVE_DREEDDS');
drredds = {all_parameters_diff, all_parameters_diff_percentage,RESPONSIVE_all_parameters_diff, RESPONSIVE_all_parameters_diff_percentage };

names = {"all_parameters_diff","all_parameters_diff_percentage", "RESPONSIVE_all_parameters_diff", "RESPONSIVE_all_parameters_diff_percentage" };
%% calculate control vs real
for i = 1:4
    for j = 1:4
        cont = control{i}(:,j);
        dred = drredds{i}(:,j);
        [sugnificant(i,j), PVAL(i,j)] = ttest2(dred{:,:}, cont{:,:}, "Tail","right");
        f1 = figure;
        f1.Position = [308 402 1560 576];
        subplot(1,2,1)
        bar(categorical(["control","dreedds"]),[mean(cont{:,:}, "omitnan"), mean(dred{:,:}, "omitnan")])
        title(['pval: ' num2str(PVAL(i,j))])

        subplot(1,2,2)
        histogram(cont{:,:})
        hold on
        histogram(dred{:,:})
        xline(mean(cont{:,:}, "omitnan"), 'k', 'LineWidth',2)
        xline(median(dred{:,:}, "omitnan"), 'r', 'LineWidth',2)
        legend(["control","dreedds"])

        sgtitle([names{i} ' ' cont.Properties.VariableNames{1}],  'Interpreter', 'none')
        exportgraphics(f1, 'all_figs.pdf', 'Append',true)
        close(f1)
    end
end
 %% calculate percentage of responsive cells per experiment
% [control_responsive_per_exp, control_IR_per_exp] = ir_res_before_and_after(all_cells, 2);
% [DREEDDS_responsive_per_exp, DREEDDS_IR_per_exp] = ir_res_before_and_after(all_cells, 2);
% ttest2(control_responsive_per_exp.mean_after_is_responsive, DREEDDS_responsive_per_exp.mean_after_is_responsive)
% 
% [p_res]=permutationTest(control_responsive_per_exp.mean_after_is_responsive, DREEDDS_responsive_per_exp.mean_after_is_responsive, 10000);
% [p_ir]=permutationTest(control_IR_per_exp.mean_after_is_IR , DREEDDS_IR_per_exp.mean_after_is_IR, 10000);

%% calculate dinamic range for datasets and compare them
all_cells_control{1}.DNR = cellfun(@(x) calculate_DNR_4_cell(x(2).original_curve), all_cells_control{1}.new_fit3);
all_cells_control{2}.DNR = cellfun(@(x) calculate_DNR_4_cell(x(2).original_curve), all_cells_control{2}.new_fit3);


DNRdiff = all_cells_control{1}.DNR - all_cells_control{2}.DNR;
resposive_cells = cell2mat(all_cells_control{1}.Is_reponsive);
DNRdiffIR = DNRdiff(find(resposive_cells(:,2)));
[~ , pval] = ttest(DNRdiffIR);
mean(DNRdiff)



%% plot all 4 plotes together
%% prerpare data
 T = [control_all_cells_parameters{1}; control_all_cells_parameters{2}; DREDDS_all_cells_response_parameters{1};DREDDS_all_cells_response_parameters{2}];
T.responsive = cell2mat([all_cells_control{1}.Is_reponsive; all_cells_control{2}.Is_reponsive; all_cells_DREEDDS{1}.Is_reponsive;all_cells_DREEDDS{2}.Is_reponsive ]);

T.IR = cell2mat([all_cells_control{1}.Is_reponsive_and_IR; all_cells_control{2}.Is_reponsive_and_IR; all_cells_DREEDDS{1}.Is_reponsive_and_IR;all_cells_DREEDDS{2}.Is_reponsive_and_IR ]);
T.tag = [repmat("control before", size(control_all_cells_parameters{1},1), 1);repmat("control after", size(control_all_cells_parameters{2},1), 1);repmat("DREEDDS before", size(all_cells_DREEDDS{1},1), 1);repmat("DREEDDS after", size(all_cells_DREEDDS{2},1), 1)];
nan_cells  = find(isinf(T.magnitude));
T.magnitude(nan_cells, :) = nan;
nan_cells  = find(isinf(T.zscore));
T.zscore(nan_cells, :) = nan;


before_cells = find(contains(T.tag,"control before"));

before_res_cells = find(T.responsive(before_cells,2)) + before_cells(1)-1;
control_res = [before_res_cells; before_res_cells+length(before_cells)];

before_cells = find(contains(T.tag,"DREEDDS before"));
all_res_cells =[control_res; find(T.responsive(before_cells,2)) + before_cells(1)-1];

all_res_cells = [all_res_cells; find(T.responsive(before_cells,2))+(before_cells(end))];

resT = T(all_res_cells,:);
save('all_cells_with_response_parameters_and_tags', "T")
save('responsive_with_response_parameters_and_tags', "resT")

%% plot response
mkdir('all_cells')
cd('all_cells')

anova1(T.magnitude, T.tag)
[p,tbl,stats] = anova1(T.magnitude, T.tag)
savefig('magnitude_all_cells_box_plot')
results = multcompare(stats);
resuls_tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
title('all cells magnitude')
savefig('magnitude_all_cells_multiple_comp')
save('magnitude_all_cells_multiple_comp', 'resuls_tbl')


anova1(T.zscore, T.tag)
[p,tbl,stats] = anova1(T.zscore, T.tag)
savefig('zscore_all_cells_box_plot')
results = multcompare(stats);
resuls_tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
title('all cells zscore')
savefig('zscore_all_cells_multiple_comp')
save('zscore_all_cells_multiple_comp', 'resuls_tbl')
cd .. 
%%
mkdir('responsive_cells')
cd('responsive_cells')

anova1(resT.magnitude, resT.tag)
[p,tbl,stats] = anova1(resT.magnitude, resT.tag)
savefig('magnitude_responsive_cells_box_plot')
results = multcompare(stats);
resuls_tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
title('responsive cells magnitude')
savefig('magnitude_responsive_cells_multiple_comp')
save('magnitude_responsive_cells_multiple_comp', 'resuls_tbl')


anova1(resT.zscore, resT.tag)
[p,tbl,stats] = anova1(resT.zscore, resT.tag)
savefig('zscore_responsive_cells_box_plot')
results = multcompare(stats);
resuls_tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
title('responsive cells zscore')
savefig('zscore_responsive_cells_multiple_comp')
save('zscore_responsive_cells_multiple_comp', 'resuls_tbl')
cd .. 
%%



[p,tbl,stats] = anova1(resT.magnitude, resT.tag)
results = multcompare(stats);
boxplot(resT.magnitude, resT.tag)


[p,tbl,stats] = anova1(resT.zscore, resT.tag)
results = multcompare(stats);
boxplot(T.zscore, T.tag)

%%
contorl_cells =  find(contains(T.tag,"control"));
contorlT = T(contorl_cells,:);
[exp_group.table, ~, exp_group.pval,lables] = crosstab(contorlT.IR(:,2),contorlT.tag);


f1 = figure;
f1.Position = [379 330 1227 648];

bar(categorical(lables(:,2)),exp_group.table(2, :)./sum(exp_group.table))


legend(["IE", "N"])
title('% IE cell')
subtitle(['pval: ' num2str(exp_group.pval)])




%%
function [responsive_per_exp, IR_per_exp] = ir_res_before_and_after(all_cells,w)
DREEDDS = table();
DREEDDS.exp_names = cellfun(@(x) x(1:14), all_cells{1}.Properties.RowNames, UniformOutput=false);

temp = cell2mat(all_cells{1}.Is_reponsive);
DREEDDS.before_is_responsive = temp(:,w);

temp = cell2mat(all_cells{2}.Is_reponsive);
DREEDDS.after_is_responsive = temp(:,w);


temp = cell2mat(all_cells{1}.Is_reponsive_and_IR);
DREEDDS.before_is_IR = temp(:,w);

temp = cell2mat(all_cells{2}.Is_reponsive_and_IR);
DREEDDS.after_is_IR = temp(:,w);


responsive_steady = DREEDDS(find(DREEDDS.before_is_responsive),:);
IR_steady = DREEDDS(find(DREEDDS.before_is_IR),:);

responsive_per_exp = grpstats(responsive_steady, "exp_names", "mean", "DataVars","after_is_responsive");
IR_per_exp = grpstats(IR_steady, "exp_names", "mean", "DataVars","after_is_IR");

end
