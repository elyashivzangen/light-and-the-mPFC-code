%% plot response
clear
clc

cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\DREEDDS_VS_CONTROL\anova_control_vs_dreedds\new_running_like_phb_cno_code')
T = importdata("all_cells_with_response_parameters_and_tags.mat");
%% take out Nan magnitude cell (baseline = 0)
T.tag = T.tags;
T.cno = contains(T.tags,'after');
%
cno_idx = 0;
saline_idx = 0;
for i = 1:length(T.cno) 
    if T.cno(i)
        cno_idx = cno_idx + 1;
        cell_idx(i,1) = cno_idx;
    else
        saline_idx = saline_idx + 1;
        cell_idx(i,1) = saline_idx;
    end
end
T.cell_idx = cell_idx;
[row,~] = find(isnan(T.magnitude))
nancells = T.cell_idx(row);
T(find(ismember(T.cell_idx, nancells)),:) = [];
%
T.control = contains(T.tags, 'control');
T.all_magnitude = T.magnitude;
T.magnitude = abs(T.magnitude(:,7));
T.all_zscore = T.zscore;
T.zscore = abs(T.zscore(:,7));
%% resposive cells
res_cells = T.cell_idx(find(T.Is_reponsive(:,2) & ~T.cno))
resT = T(find(ismember(T.cell_idx, res_cells)),:);
%% responsive and IE


% bar(1:4, [G1.mean_Is_reponsive(:,1:2), G1.mean_Is_reponsive_and_IR(:,1:2)])
% xticklabels(G1.tags)

%% plot all
mkdir('chi2')
cd('chi2')
cont = T(find(T.control),:);
dre = T(find(~T.control),:);

G1 = grpstats(T,"tags","mean","DataVars",["Is_reponsive","Is_reponsive_and_IR"]);
save('responsive_and_ie_per_group', "G1")

%
f1 = figure;
f1.Position = [680 139 1104 839];
mkdir('responsive')
cd('responsive')
mkdir('transient')
cd('transient')

subplot(2,2,1)
[control.table, control.chi2, control.pval, control.lables] = crosstab(cont.Is_reponsive(:,1), cont.tags);
control.df = degfree(control.table);
[dreadds.table, dreadds.chi2, dreadds.pval, dreadds.lables] = crosstab(dre.Is_reponsive(:,1), dre.tags);
dreadds.df = degfree(dreadds.table);
bar(1:4, G1.mean_Is_reponsive(:,1))
xticklabels(G1.tags)
title('responsive transient')
subtitle({['dreadds pval: ' num2str(dreadds.pval)], ['control pval: ' num2str(control.pval)]})
save('dreadds', 'dreadds')
save('control', 'control')
cd ..

mkdir('sustained')
cd('sustained')

subplot(2,2,2)
[control.table, control.chi2, control.pval, control.lables] = crosstab(cont.Is_reponsive(:,2), cont.tags);
control.df = degfree(control.table);
[dreadds.table, dreadds.chi2, dreadds.pval, dreadds.lables] = crosstab(dre.Is_reponsive(:,2), dre.tags);
dreadds.df = degfree(dreadds.table);
bar(1:4, G1.mean_Is_reponsive(:,2))
xticklabels(G1.tags)
title('responsive sustained')
subtitle({['dreadds pval: ' num2str(dreadds.pval)], ['control pval: ' num2str(control.pval)]})
save('dreadds', 'dreadds')
save('control', 'control')

cd ..
cd ..

mkdir('IE')
cd('IE')
mkdir('transient')
cd('transient')

subplot(2,2,3)
[control.table, control.chi2, control.pval, control.lables] = crosstab(cont.Is_reponsive_and_IR(:,1), cont.tags);
control.df = degfree(control.table);
[dreadds.table, dreadds.chi2, dreadds.pval, dreadds.lables] = crosstab(dre.Is_reponsive_and_IR(:,1), dre.tags);
dreadds.df = degfree(dreadds.table);
bar(1:4, G1.mean_Is_reponsive_and_IR(:,1))
xticklabels(G1.tags)
title('IE transient')
subtitle({['dreadds pval: ' num2str(dreadds.pval)], ['control pval: ' num2str(control.pval)]})
save('dreadds', 'dreadds')
save('control', 'control')
cd ..

mkdir('sustained')
cd('sustained')

subplot(2,2,4)
[control.table, control.chi2, control.pval, control.lables] = crosstab(cont.Is_reponsive_and_IR(:,2), cont.tags);
control.df = degfree(control.table);
[dreadds.table, dreadds.chi2, dreadds.pval, dreadds.lables] = crosstab(dre.Is_reponsive_and_IR(:,2), dre.tags);
dreadds.df = degfree(dreadds.table);
bar(1:4, G1.mean_Is_reponsive_and_IR(:,2))
xticklabels(G1.tags)
title('IE sustained')
subtitle({['dreadds pval: ' num2str(dreadds.pval)], ['control pval: ' num2str(control.pval)]})
save('dreadds', 'dreadds')
save('control', 'control')
cd ..
cd ..
savefig(f1,'chi2_control_vs_dreadds_all_windows')
cd ..









%%
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

f1 = figure;
f1.Position = [680 139 1104 839];

control = T(find(T.control),:);
subplot(2,2,1)
bar([1,2], [mean(control.magnitude(~control.cno,1)), mean(control.magnitude(control.cno,1))])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(control.magnitude(~control.cno)-control.magnitude(control.cno), 100000, 1, 0.05, 0, 0);
subtitle(['pval premutation = ' num2str(p1)])
title('magnitude control')

subplot(2,2,2)
bar([1,2], [mean(control.zscore(~control.cno,1)), mean(control.zscore(control.cno,1))])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(control.zscore(~control.cno)-control.zscore(control.cno), 100000, 1, 0.05, 0, 0);
subtitle(['pval premutation = ' num2str(p1)])
title('zscore control')

dreadds = T(find(~T.control),:);
subplot(2,2,3)
bar([1,2], [mean(dreadds.magnitude(~dreadds.cno,1)), mean(dreadds.magnitude(dreadds.cno,1))])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(dreadds.magnitude(~dreadds.cno)-dreadds.magnitude(dreadds.cno), 100000, 1, 0.05, 0, 0);
subtitle(['pval premutation = ' num2str(p1)])
title('magnitude dreadds')

subplot(2,2,4)
bar([1,2], [mean(dreadds.zscore(~dreadds.cno,1)), mean(dreadds.zscore(dreadds.cno,1))])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(dreadds.zscore(~dreadds.cno)-dreadds.zscore(dreadds.cno), 100000, 1, 0.05, 0, 0);
subtitle(['pval premutation = ' num2str(p1)])
title('zscore dreadds')
 sgtitle('all cells')


savefig(f1, 'paired_data')
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


f1 = figure;
f1.Position = [680 139 1104 839];

control = resT(find(resT.control),:);
subplot(2,2,1)
bar([1,2], [mean(control.magnitude(~control.cno,1)), mean(control.magnitude(control.cno,1))])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(control.magnitude(~control.cno)-control.magnitude(control.cno), 100000, 1, 0.05, 0, 0);
subtitle(['pval premutation = ' num2str(p1)])
title('magnitude control')

subplot(2,2,2)
bar([1,2], [mean(control.zscore(~control.cno,1)), mean(control.zscore(control.cno,1))])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(control.zscore(~control.cno)-control.zscore(control.cno), 100000, 1, 0.05, 0, 0);
subtitle(['pval premutation = ' num2str(p1)])
title('zscore control')

dreadds = resT(find(~resT.control),:);
subplot(2,2,3)
bar([1,2], [mean(dreadds.magnitude(~dreadds.cno,1)), mean(dreadds.magnitude(dreadds.cno,1))])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(dreadds.magnitude(~dreadds.cno)-dreadds.magnitude(dreadds.cno), 100000, 1, 0.05, 0, 0);
subtitle(['pval premutation = ' num2str(p1)])
title('magnitude dreadds')

subplot(2,2,4)
bar([1,2], [mean(dreadds.zscore(~dreadds.cno,1)), mean(dreadds.zscore(dreadds.cno,1))])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(dreadds.zscore(~dreadds.cno)-dreadds.zscore(dreadds.cno), 100000, 1, 0.05, 0, 0);
subtitle(['pval premutation = ' num2str(p1)])
title('zscore dreadds')
sgtitle('responsive cells')


savefig(f1, 'paired_data')



cd .. 

%% paired

cont.Is_reponsive_only_before = cont.Is_reponsive;
cont.Is_reponsive_and_ir_only_before = cont.Is_reponsive_and_IR;

before_cont = cont(find(~cont.cno),:);
after_cont = cont(find(cont.cno),:);
after_cont.Is_reponsive_only_before = before_cont.Is_reponsive & after_cont.Is_reponsive
after_cont.Is_reponsive_and_ir_only_before = before_cont.Is_reponsive_and_IR & after_cont.Is_reponsive_and_IR

cont = [before_cont; after_cont];


dre.Is_reponsive_only_before = dre.Is_reponsive;
dre.Is_reponsive_and_ir_only_before = dre.Is_reponsive_and_IR;

before_dre = dre(find(~dre.cno),:);
after_dre = dre(find(dre.cno),:);
after_dre.Is_reponsive_only_before = before_dre.Is_reponsive & after_dre.Is_reponsive
after_dre.Is_reponsive_and_ir_only_before = before_dre.Is_reponsive_and_IR & after_dre.Is_reponsive_and_IR

dre = [before_dre; after_dre];

dre.Is_reponsive = dre.Is_reponsive_only_before
dre.Is_reponsive_and_IR = dre.Is_reponsive_and_ir_only_before

cont.Is_reponsive = cont.Is_reponsive_only_before
cont.Is_reponsive_and_IR = cont.Is_reponsive_and_ir_only_before

T2 = T
T = [cont; dre]
%% plot all
mkdir('chi2_only_before_responsive')
cd('chi2_only_before_responsive')
control = [];
dreadds = [];

G1 = grpstats(T,"tags","mean","DataVars",["Is_reponsive","Is_reponsive_and_IR"]);
save('responsive_and_ie_per_group', "G1")

%
f1 = figure;
f1.Position = [680 139 1104 839];
mkdir('responsive')
cd('responsive')
mkdir('transient')
cd('transient')

subplot(2,2,1)
[control.table, control.chi2, control.pval, control.lables] = crosstab(cont.Is_reponsive(:,1), cont.tags);
control.df = degfree(control.table);
[dreadds.table, dreadds.chi2, dreadds.pval, dreadds.lables] = crosstab(dre.Is_reponsive(:,1), dre.tags);
dreadds.df = degfree(dreadds.table);
bar(1:4, G1.mean_Is_reponsive(:,1))
xticklabels(G1.tags)
title('responsive transient')
subtitle({['dreadds pval: ' num2str(dreadds.pval)], ['control pval: ' num2str(control.pval)]})
save('dreadds', 'dreadds')
save('control', 'control')
cd ..

mkdir('sustained')
cd('sustained')

subplot(2,2,2)
[control.table, control.chi2, control.pval, control.lables] = crosstab(cont.Is_reponsive(:,2), cont.tags);
control.df = degfree(control.table);
[dreadds.table, dreadds.chi2, dreadds.pval, dreadds.lables] = crosstab(dre.Is_reponsive(:,2), dre.tags);
dreadds.df = degfree(dreadds.table);
bar(1:4, G1.mean_Is_reponsive(:,2))
xticklabels(G1.tags)
title('responsive sustained')
subtitle({['dreadds pval: ' num2str(dreadds.pval)], ['control pval: ' num2str(control.pval)]})
save('dreadds', 'dreadds')
save('control', 'control')

cd ..
cd ..

mkdir('IE')
cd('IE')
mkdir('transient')
cd('transient')

subplot(2,2,3)
[control.table, control.chi2, control.pval, control.lables] = crosstab(cont.Is_reponsive_and_IR(:,1), cont.tags);
control.df = degfree(control.table);
[dreadds.table, dreadds.chi2, dreadds.pval, dreadds.lables] = crosstab(dre.Is_reponsive_and_IR(:,1), dre.tags);
dreadds.df = degfree(dreadds.table);
bar(1:4, G1.mean_Is_reponsive_and_IR(:,1))
xticklabels(G1.tags)
title('IE transient')
subtitle({['dreadds pval: ' num2str(dreadds.pval)], ['control pval: ' num2str(control.pval)]})
save('dreadds', 'dreadds')
save('control', 'control')
cd ..

mkdir('sustained')
cd('sustained')

subplot(2,2,4)
[control.table, control.chi2, control.pval, control.lables] = crosstab(cont.Is_reponsive_and_IR(:,2), cont.tags);
control.df = degfree(control.table);
[dreadds.table, dreadds.chi2, dreadds.pval, dreadds.lables] = crosstab(dre.Is_reponsive_and_IR(:,2), dre.tags);
dreadds.df = degfree(dreadds.table);
bar(1:4, G1.mean_Is_reponsive_and_IR(:,2))
xticklabels(G1.tags)
title('IE sustained')
subtitle({['dreadds pval: ' num2str(dreadds.pval)], ['control pval: ' num2str(control.pval)]})
save('dreadds', 'dreadds')
save('control', 'control')
cd ..
cd ..
savefig(f1,'chi2_control_vs_dreadds_all_windows')
cd ..




