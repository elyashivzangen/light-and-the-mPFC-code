%% Plot percentage change in light-evoked firing rate across clusters


clc
clear
cd 'I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\effect size\f5'
PFC=readtable('magnitude_index_PFC.csv');
PHb=readtable('magnitude_index_PHb.csv');

PFC_m=100.*(PFC{:,2});        % percentage of firing rate change in the steady-state window (replace 2 with 1 to early window, and to 3 for OFF window)
PFC_clust=PFC{:,4};

PHb_m=100.*(PHb{:,2});        % percentage of firing rate change in the steady-state window (replace 2 with 1 to early window, and to 3 for OFF window)
PHb_clust_tmp=PHb{:,4};
PHb_clust(PHb_clust_tmp==4)=1;
PHb_clust(PHb_clust_tmp==1)=2;
PHb_clust(PHb_clust_tmp==2)=3;
PHb_clust(PHb_clust_tmp==3)=4;
PHb_clust=PHb_clust';


%% plot
f1=figure;
set(f1, 'color', [1 1 1]);
set(f1,'position',[200 200 500 500]);
hold on;
c={[1 0 0],[0.3010 0.7450 0.9330],[1 0 1],[0 1 0]};
plot([-0.5 7.5],[0 0],'--k');

clustord=[2,1,4,3];
k=0;
for i=1:4
    xdata=repmat(k,size(find(PHb_clust==clustord(i)),1),1);
    b=boxchart(xdata,PHb_m(PHb_clust==clustord(i)),'BoxFaceColor',c{i},'MarkerStyle','none');
    
    xdata=repmat(k+0.6,size(find(PFC_clust==clustord(i)),1),1);
    b=boxchart(xdata,PFC_m(PFC_clust==clustord(i)),'BoxFaceColor',[0.5 0.5 0.5],'MarkerStyle','none'); 
    k=k+2
end

xticks([0.3,2.3,4.3,6.3]);
xticklabels({'ON-OFF enha.','ON-OFF supp.','ON enha.','ON supp.'});
xlim([-0.5 7.5]);
ylim([-110 110]);

box off
ax = gca;
ax.FontSize=18;
ylabel({'Light-evoked firing rate';'change relative to baseline (%)'},'FontSize',22);

%% stats

% Permutation t-test with one tail - the null hypothess is that the PHb
% absolute magnitude is larger than that in the PFC (the effect of light on PHb neurons is
% larger than the effect of light on PFC neurons). The results of the test show that the null hypothesis is rejected for 3 out the 4 clusters. 
for i=1:4
    if i==2 || i==4
        [p(i), observeddifference(i), effectsize(i)]=permutationTest(PHb_m(PHb_clust==clustord(i)),PFC_m(PFC_clust==clustord(i)),10000,'sidedness','larger')     % 'sidedness','larger'
         %[pval(i), t_orig(i), crit_t{i}, est_alpha(i)]=mult_comp_perm_t2(PHb_m(PHb_clust==clustord(i)),PFC_m(PFC_clust==clustord(i)),5000,1)
    else
        [p(i), observeddifference(i), effectsize(i)]=permutationTest(PHb_m(PHb_clust==clustord(i)),PFC_m(PFC_clust==clustord(i)),10000,'sidedness','smaller')     % 'sidedness','larger'
        %[pval(i), t_orig(i), crit_t{i}, est_alpha(i)]=mult_comp_perm_t2(PHb_m(PHb_clust==clustord(i)),PFC_m(PFC_clust==clustord(i)),5000,-1)
    end
end


