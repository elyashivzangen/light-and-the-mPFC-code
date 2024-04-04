clear
clc
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\eopn3\clusters\clusters_control')
%%
load("intensities_mean.mat")
load("intensities_sem.mat")

%%
psth_highest.mean = squeeze(intensities_mean(:,1,:));
psth_highest.sem = squeeze(intensities_sem(:,1,:));
%%
cd ..
save('psth_highest_control')

