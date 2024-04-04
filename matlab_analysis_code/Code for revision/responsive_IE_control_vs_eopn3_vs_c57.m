%% percent of intensity encoding and reponsive cells
%% early responsvie
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\eopn3\all_ints_data\is responsive and IE control_vs_eopn3_vs_c57')
load("all_ints_with_tags.mat")
%%
G1 = grpstats(T, "tag","mean",DataVars=["Is_reponsive","Is_reponsive_and_IR"]);
writetable(G1,'percent responsive and IE control_vs_eopn3_vs_c57.csv')
save('percent responsive and IE control_vs_eopn3_vs_c57', 'G1')

f1 = figure;
subplot(1,2,1)
x = categorical(G1.tag);
bar(x,G1.mean_Is_reponsive(:,1:2))                
title('responsive')

subplot(1,2,2)
bar(x,G1.mean_Is_reponsive_and_IR(:,1:2))                
legend(["transient","sustained"])
title('IE')

savefig(f1,'responsive and IE control vs c57 vs eopn3')


%% ploting and stats
mkdir('responsive')
cd('responsive')
% chi-squre
[transient.table, transient.chi2, transient.pval, lables] = crosstab(T.Is_reponsive(:,1), T.tag);
transient.df = degfree(transient.table);
[sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.Is_reponsive(:,2), T.tag);
sustained.df = degfree(sustained.table);
pairwise_chi2 = pairwise_comperision_chi2(T , 'Is_reponsive');

f1 = figure;
f1.Position = [379 330 1227 648];

subplot(1,2,1)
bar(categorical(lables(:,2)), transient.table(2, :)./sum(transient.table))
title('transient')
subtitle({['pval: ' num2str(transient.pval)], ...
    [pairwise_chi2.Properties.VariableNames{1} ' pval: ' num2str(pairwise_chi2{:,1}.transient.pval)], ...
    [pairwise_chi2.Properties.VariableNames{2} ' pval: ' num2str(pairwise_chi2{:,2}.transient.pval)], ...
    [pairwise_chi2.Properties.VariableNames{3} ' pval: ' num2str(pairwise_chi2{:,3}.transient.pval)]...
    },"Interpreter","none")


subplot(1,2,2)
bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle({['pval: ' num2str(sustained.pval)], ...
    [pairwise_chi2.Properties.VariableNames{1} ' pval: ' num2str(pairwise_chi2{:,1}.sustained.pval)], ...
    [pairwise_chi2.Properties.VariableNames{2} ' pval: ' num2str(pairwise_chi2{:,2}.sustained.pval)], ...
    [pairwise_chi2.Properties.VariableNames{3} ' pval: ' num2str(pairwise_chi2{:,3}.sustained.pval)]...
    },"Interpreter","none")

sgtitle('responsive')

save('transient_data', 'transient')
save('sustained_data', 'sustained')
save('pairwise_chi2', 'pairwise_chi2')

savefig(f1, 'chi_squre_data')
cd ..

%%
mkdir('IE')
cd('IE')
% chi-squre
[transient.table, transient.chi2, transient.pval, lables] = crosstab(T.Is_reponsive_and_IR(:,1), T.tag);
transient.df = degfree(transient.table);
[sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.Is_reponsive_and_IR(:,2), T.tag);
sustained.df = degfree(sustained.table);
pairwise_chi2 = pairwise_comperision_chi2(T, 'Is_reponsive_and_IR');

f1 = figure;
f1.Position = [379 330 1227 648];

subplot(1,2,1)
bar(categorical(lables(:,2)), transient.table(2, :)./sum(transient.table))
title('transient')
subtitle({['pval: ' num2str(transient.pval)], ...
    [pairwise_chi2.Properties.VariableNames{1} ' pval: ' num2str(pairwise_chi2{:,1}.transient.pval)], ...
    [pairwise_chi2.Properties.VariableNames{2} ' pval: ' num2str(pairwise_chi2{:,2}.transient.pval)], ...
    [pairwise_chi2.Properties.VariableNames{3} ' pval: ' num2str(pairwise_chi2{:,3}.transient.pval)]...
    },"Interpreter","none")


subplot(1,2,2)
bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle({['pval: ' num2str(sustained.pval)], ...
    [pairwise_chi2.Properties.VariableNames{1} ' pval: ' num2str(pairwise_chi2{:,1}.sustained.pval)], ...
    [pairwise_chi2.Properties.VariableNames{2} ' pval: ' num2str(pairwise_chi2{:,2}.sustained.pval)], ...
    [pairwise_chi2.Properties.VariableNames{3} ' pval: ' num2str(pairwise_chi2{:,3}.sustained.pval)]...
    },"Interpreter","none")

sgtitle('IE')

save('transient_data', 'transient')
save('sustained_data', 'sustained')
save('pairwise_chi2', 'pairwise_chi2')

savefig(f1, 'chi_squre_data')
cd ..
%% anova cells per experiment
mkdir('cells per experiment (anova)')
cd('cells per experiment (anova)')
%%
G2 = grpstats(T, ["tag", "file_name"],"mean",DataVars=["Is_reponsive","Is_reponsive_and_IR"]);
mean_cells_per_experiment_per_group = grpstats(G2, "tag",["mean", "sem"],DataVars=["mean_Is_reponsive","mean_Is_reponsive_and_IR"]);
writetable(mean_cells_per_experiment_per_group,'mean_cells_per_experiment_control_vs_eopn3_vs_c57.csv')
save('mean_cells_per_experiment_control_vs_eopn3_vs_c57', 'mean_cells_per_experiment_per_group')
f1 = figure;
f1.Position = [379 330 800 400];
subplot(1,2,1)
x = categorical(mean_cells_per_experiment_per_group.tag);
bar(x,mean_cells_per_experiment_per_group.mean_mean_Is_reponsive(:,1:2))                
title('responsive')

subplot(1,2,2)
bar(x,mean_cells_per_experiment_per_group.mean_mean_Is_reponsive_and_IR(:,1:2))                
legend(["transient","sustained"])
title('IE')
savefig(f1,'mean_cells_per_experiment_control_vs_eopn3_vs_c57')
 
%% transient responsive
[p,tbl,stats] = anova1(G2.mean_Is_reponsive(:,1),G2.tag);
savefig('transient responsive per group anova')
results = multcompare(stats);
tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
title('transient responsive per group')
savefig('transient responsive per group anova_multiple_comp')
save('transient responsive per group anova_multiple_comp', 'tbl')

%% transient IE
[p,tbl,stats] = anova1(G2.mean_Is_reponsive_and_IR(:,1),G2.tag);
savefig('transient IE per group anova')
results = multcompare(stats);
tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
title('transient IE per group')
savefig('transient IE per group anova_multiple_comp')
save('transient IE per group anova_multiple_comp', 'tbl')

%% sustained responsive
[p,tbl,stats] = anova1(G2.mean_Is_reponsive(:,2),G2.tag);
savefig('sustained responsive per group anova')
results = multcompare(stats);
tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
title('sustained responsive per group')
savefig('sustained responsive per group anova_multiple_comp')
save('sustained responsive per group anova_multiple_comp', 'tbl')


%% sustained IE
[p,tbl,stats] = anova1(G2.mean_Is_reponsive_and_IR(:,2),G2.tag);
savefig('sustained IE per group anova')
results = multcompare(stats);
tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
title('sustained IE per group')
savefig('sustained IE per group anova_multiple_comp')
save('sustained IE per group anova_multiple_comp', 'tbl')

cd ..
%% perwise comperision
function pairwise_chi2 = pairwise_comperision_chi2(T, res_vs_ie)
for i = 1:3
    groups = unique(T.tag);
    groups(i) = [];
    T1 = T(find(ismember(T.tag, groups)),:);
    [transient.table, transient.chi2, transient.pval, lables] = crosstab(T1.(res_vs_ie)(:,1), T1.tag);
    transient.df = degfree(transient.table);
    [sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T1.(res_vs_ie)(:,2), T1.tag);
    sustained.df = degfree(sustained.table);
    pairwise_chi2.([groups{1} '_vs_' groups{2}]).transient = transient;
    pairwise_chi2.([groups{1} '_vs_' groups{2}]).sustained = sustained;
end
pairwise_chi2 = struct2table(pairwise_chi2);
end