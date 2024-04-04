clear
clc
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\effect size\f4\d')
%%
control = importdata('control.mat');
control_stats=mestab(control.table)
dreadds = importdata('dreadds.mat');
dreadds_stats=mestab(dreadds.table)
