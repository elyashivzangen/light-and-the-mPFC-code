cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\eopn3\eopn3_vs_scarlet')
NDs = [10, 8, 6, 4, 3, 2, 1];

% save('eopn3_vs_scarlet', 'T2')
T2 = importdata('eopn3_vs_scarlet');
n_perm = 100000;
tail = -1;
t_stat = ['t'];
t_stat = ['w'];
% t_stat = ['td'];

[pval(:,1), t_orig(:,1), crit_t]=mult_comp_perm_t2(T2.abs_IR(contains(T2.tag,"EOPN3"),:),T2.abs_IR(contains(T2.tag,"CONTROL"),:),n_perm,tail,0.05,0,t_stat);
prem = table(NDs', pval, t_orig, 'VariableNames',["NDs", "pval", "t_orig"]);

[h,p,ci,stats] = ttest2(T2.abs_IR(contains(T2.tag,"EOPN3"),:),T2.abs_IR(contains(T2.tag,"CONTROL"),:))
X  = T2.abs_IR
subjects = categorical((1:size(T2.tag,1))');
group = T2.tag;
T3 = table(subjects, group);
T4 = array2table(T2.abs_IR, VariableNames=["ND10", "ND8", "ND6" ,"ND4", "ND3","ND2", "ND1"]);
T3 = [T3, T4];
withinDesign = table(string(NDs'),'VariableNames',{'NDs'});

rm = fitrm(T3, 'ND10-ND1~group', 'WithinDesign', withinDesign);
% rm = fitrm(T3, 'ND10-ND1~group');

% Perform the repeated measures ANOVA
ranovatbl = ranova(rm);
tbl = multcompare(rm,'group');
tbl2 = multcompare(rm,'group','By','NDs');
save('pvalue_rm_anova', 'tbl2')
save('rm_anova_data', 'rm')
save('pval_mult_comp_perm_t2', 'prem')


