clc
clear

cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\effect size\f4\g')
T2 = importdata("eopn3_vs_scarlet.mat");

%% 
stats = mes(T2.abs_IR(find(contains(T2.tag,'CONTROL')),:),T2.abs_IR(find(contains(T2.tag,'EOPN3')),:),'hedgesg')

