
% Plot baseline (pooled across intensities) for PFC vs PHb

clear all
cd 'I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\effect size\f5\i_base_line'

PHb_tmp=load('all_baselines_PHb.mat');
PFC_tmp=load('all_baselines_PFC.mat');

PHb_baseline_tmp=table2array(PHb_tmp.all_cells(:,12));
PHb_cluster=table2array(PHb_tmp.all_cells(:,4));

PFC_baseline_tmp=table2array(PFC_tmp.all_cells(:,13));
PFC_cluster=table2array(PFC_tmp.all_cells(:,4));

clust_ord=[1,4,2,3];    % puts cluster in the following order: ONOFF, ON suppressed 1, ON enhanced, ON suppressed 2
for i=1:4
    PHb_base{i}=PHb_baseline_tmp(PHb_cluster==clust_ord(i));
    PHb_mean_base(i)=mean(PHb_base{i});
    PHb_sd_base(i)=std(PHb_base{i});
    PHb_sem_base(i)=PHb_sd_base(i)./sqrt(length(PHb_base{i}));
end

clust_ord=[2,1,4,3];    % puts cluster in the following order: ONOFF, ON suppressed 1, ON enhanced, ON suppressed 2
for i=1:4
    PFC_base{i}=PFC_baseline_tmp(PFC_cluster==clust_ord(i));
    PFC_mean_base(i)=mean(PFC_base{i});
    PFC_sd_base(i)=std(PFC_base{i});
    PFC_sem_base(i)=PFC_sd_base(i)./sqrt(length(PFC_base{i}));
end


%% Plot

c=[1 0 0;0.3010 0.7450 0.9330;1 0 1;0 1 0];
f3=figure;
set(f3,'color',[1 1 1]);
set(f3,'position',[200 200 450 600]);
hold on;

k=0;
for i=1:4
    errorbar(k,PHb_mean_base(i),PHb_sem_base(i),'color',[c(i,1),c(i,2),c(i,3)],'LineWidth',2,'LineStyle','-','Marker','o','MarkerSize',10);
    errorbar(k,PFC_mean_base(i),PFC_sem_base(i),'color',[0.5,0.5,0.5],'LineWidth',2,'LineStyle','-','Marker','o','MarkerSize',10);
    k=k+2;
end

xticks([0.25,2.25,4.25,6.25]);
xticklabels({'ON-OFF enha.','ON-OFF supp.','ON enha.','ON supp.'});
xlim([-0.5 7]);
box off
ax = gca;
ax.FontSize=22;
xlabel('Intensity (log photons cm^-^2 s^-^1)','FontSize',22);
ylabel('Baseline firing rate (spikes/sec)','FontSize',22);
legend({'ON-OFF enhanced','','ON-OFF suppressed','','ON enhanced','','ON suppressed',''},'FontSize',18);
box off
legend boxoff


%% stats

% Permutation t-test with two tails

for i=1:4
        [p(i), observeddifference(i), effectsize(i)]=permutationTest(PHb_base{i},PFC_base{i},10000)     % 'sidedness','larger'
         %[pval(i), t_orig(i), crit_t{i}, est_alpha(i)]=mult_comp_perm_t2(PHb_base{i},PFC_base{i},10000,0)
end

