%% Calculate response stats
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\DREEDDS_VS_dreadds before\new_IR_calculations\IE cells')
% T2 = T(find(contains(T.tags, ["dreadds before", "dreadds after"])),:);
clear
clc
T = importdata('IE_CELLS_table.mat');
T2 = T(find(contains(T.tags, ["dreadds before", "dreadds after"] )),:);
T3 = T(find(contains(T.tags, ["control before", "control after"] )),:);


T2 = T;
mkdir('premutation test')
cd('premutation test')
%%
save('saline vs cno', 'T2')
n_perm = 100000;
tail = -1;
t_stat = ['t'];
t_stat = ['w'];
% t_stat = ['td'];
pval = [];
t_orig = [];
plot(mean(T2.response(contains(T2.tags,"dreadds after"),:)))
hold on
plot(mean(T2.response(contains(T2.tags,"dreadds before"),:)))
% plot(mean(T2.response(contains(T2.tags,"dreadds before"),:)))


[pval(:,1), t_orig(:,1), crit_t]=mult_comp_perm_t1(T2.response(contains(T2.tags,"dreadds after"),:)-T2.response(contains(T2.tags,"dreadds before"),:),n_perm,tail,0.05,0,t_stat);
NDs = [10, 8, 6, 4, 3, 2, 1];
dreadds_prem = table(NDs', pval, t_orig, 'VariableNames',["NDs", "pval", "t_orig"]);

[pval(:,1), t_orig(:,1), crit_t]=mult_comp_perm_t1(T2.response(contains(T2.tags,"control after"),:)-T2.response(contains(T2.tags,"control before"),:),n_perm,tail,0.05,0,t_stat);
control_prem = table(NDs', pval, t_orig, 'VariableNames',["NDs", "pval", "t_orig"]);

[pval(:,1), t_orig(:,1), crit_t]=mult_comp_perm_t2(T2.response(contains(T2.tags,"control after"),:)-T2.response(contains(T2.tags,"control before"),:),T2.response(contains(T2.tags,"dreadds after"),:)-T2.response(contains(T2.tags,"dreadds before"),:),n_perm,0,0.05,0,t_stat);
plot(T2.response(contains(T2.tags,"control after"),:)-T2.response(contains(T2.tags,"control before"))
control_vs_dreadds_prem = table(NDs', pval, t_orig, 'VariableNames',["NDs", "pval", "t_orig"]);
% plot(T2.response(contains(T2.tags,"control after"),:)-T2.response(contains(T2.tags,"control before"))')



save('pval_mult_comp_perm_t1_dreadds', 'dreadds_prem')
save('pval_mult_comp_perm_t1_contorl', 'control_prem')
save('pval_mult_comp_perm_t1_contorl_vs_dreadds', 'control_vs_dreadds_prem')


cd .. 
