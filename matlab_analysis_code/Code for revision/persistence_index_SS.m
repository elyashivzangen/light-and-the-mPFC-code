

clear all
close all
cd 'I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\effect size\f5\G_DECAY'

PHb_tmp=load('persistence_table_PHb.mat');
PFC_tmp=load('persistence_table_PFC.mat');

intensity=7; % highest intensity
smooth_factor=1;


%% Process PHb
PHb_psth=PHb_tmp.presistenceT.full_psth_matrix;
PHb_cluster=PHb_tmp.presistenceT.clusters;

for i=1:size(PHb_psth,1)
    curr_psth=squeeze(PHb_psth(i,intensity,:));
    curr_psth_s=smooth(curr_psth,smooth_factor);
    curr_sd_base_s=mean(curr_psth_s(20:40));
%         f1=figure;
%         set(f1,'color',[1 1 1]);
%         set(f1,'WindowStyle','Docked');
%         %set(f1,'position',[600 100 450 450]);
%         hold on
%         plot([1 241],[0 0],'--k');
%         plot(1:241,curr_psth,'-b','LineWidth',1);
%         plot(1:241,curr_psth_s,'-b','LineWidth',2)
    if mean(curr_psth_s(120:140))>0
        if PHb_cluster(i)==4    % ON suppressed 1
            ind=curr_psth_s(150:end)>-curr_sd_base_s;
        else
            ind=curr_psth_s(150:end)<curr_sd_base_s;
        end
        ind=find(ind,1,'first');
        ind(ind==0)=[];
        PHb_ind(i)=150+ind-1;
    elseif mean(curr_psth_s(120:140))<0
        if PHb_cluster(i)==4    % ON suppressed 1
            ind=curr_psth_s(150:end)<curr_sd_base_s;
        else
            ind=curr_psth_s(150:end)>-curr_sd_base_s;
        end
        ind=find(ind,1,'first');
        ind(ind==0)=[];
        PHb_ind(i)=241;
        try PHb_ind(i)=150+ind-1; end
    end
%         plot(PHb_ind(i),curr_psth_s(PHb_ind(i)),'or','MarkerSize',12,'LineWidth',2);
end

for i=1:4
    PHb_per{i}=PHb_ind(PHb_cluster==i); % in data points
    PHb_mean_per(i)=mean(PHb_per{i});
    PHb_sd_per(i)=std(PHb_per{i});
    PHb_sem_per(i)=PHb_sd_per(i)./sqrt(length(PHb_per{i}));
    
    PHb_per_sec{i}=PHb_per{i}.*0.1;     % in seconds
    PHb_mean_per_sec(i)=mean(PHb_per_sec{i});
    PHb_sd_per_sec(i)=std(PHb_per_sec{i});
    PHb_sem_per_sec(i)=PHb_sd_per_sec(i)./sqrt(length(PHb_per_sec{i}));
end


%% Process PFC
PFC_psth=PFC_tmp.presistenceT.full_psth_matrix;
PFC_cluster=PFC_tmp.presistenceT.clusters;

for i=1:size(PFC_psth,1)
    curr_psth=squeeze(PFC_psth(i,intensity,:));
    curr_psth_s=smooth(curr_psth,smooth_factor);
    curr_sd_base_s=mean(curr_psth_s(20:40));
    %     f1=figure;
    %     set(f1,'color',[1 1 1]);
    %     set(f1,'position',[200 100 450 450]);
    %     hold on
    %     plot([1 241],[0 0],'--k');
    %     plot(1:241,curr_psth,'-b','LineWidth',1);
    %     plot(1:241,curr_psth_s,'-b','LineWidth',2)
    if mean(curr_psth_s(120:140))>0
        if PFC_cluster(i)==1    % ON suppressed 1
            ind=curr_psth_s(150:end)>-curr_sd_base_s;
        else
            ind=curr_psth_s(150:end)<curr_sd_base_s;
        end
        ind=find(ind,1,'first');
        ind(ind==0)=[];
        PFC_ind(i)=241;
        try PFC_ind(i)=150+ind-1; end
    elseif mean(curr_psth_s(120:140))<0
        if PFC_cluster(i)==1    % ON suppressed 1
            ind=curr_psth_s(150:end)<curr_sd_base_s;
        else
            ind=curr_psth_s(150:end)>-curr_sd_base_s;
        end
        ind=find(ind,1,'first');
        ind(ind==0)=[];
        PFC_ind(i)=241;
        try PFC_ind(i)=150+ind-1; end
    end
    %     plot(PFC_ind(i),curr_psth_s(PFC_ind(i)),'or','MarkerSize',12,'LineWidth',2);
end

for i=1:4
    PFC_per{i}=PFC_ind(PFC_cluster==i); % in data points
    PFC_mean_per(i)=mean(PFC_per{i});
    PFC_sd_per(i)=std(PFC_per{i});
    PFC_sem_per(i)=PFC_sd_per(i)./sqrt(length(PFC_per{i}));
    
    PFC_per_sec{i}=PFC_per{i}.*0.1;     % in seconds
    PFC_mean_per_sec(i)=mean(PFC_per_sec{i});
    PFC_sd_per_sec(i)=std(PFC_per_sec{i});
    PFC_sem_per_sec(i)=PFC_sd_per_sec(i)./sqrt(length(PFC_per_sec{i}));
end

%% Plot

c=[1 0 0;0.3010 0.7450 0.9330;1 0 1;0 1 0];
f3=figure;
set(f3,'color',[1 1 1]);
set(f3,'position',[200 200 450 600]);
%set(f3,'WindowStyle','Docked');
hold on;

timeoff=142*0.1;
PHb_clustord=[1,4,3,2];
PFC_clustord=[2,1,4,3];
k=0;
for i=1:4
    errorbar(k,PHb_mean_per_sec(PHb_clustord(i))-timeoff,PHb_sem_per_sec(PHb_clustord(i)),'color',[c(i,1),c(i,2),c(i,3)],'LineWidth',2,'LineStyle','-','Marker','o','MarkerSize',10);
    errorbar(k,PFC_mean_per_sec(PFC_clustord(i))-timeoff,PFC_sem_per_sec(PFC_clustord(i)),'color',[0.5,0.5,0.5],'LineWidth',2,'LineStyle','-','Marker','o','MarkerSize',10);
    k=k+2;
end

xticks([0.25,2.25,4.25,6.25]);
xticklabels({'ON-OFF enha.','ON-OFF supp.','ON enha.','ON supp.'});
xlim([-0.5 7]);
ylim([0 2.5]);
box off
ax = gca;
ax.FontSize=18;
xlabel('Intensity (log photons cm^-^2 s^-^1)','FontSize',18);
ylabel('Decay time (sec)','FontSize',18);
legend off
box off


%% stats

% Permutation t-test with two tails


for i=1:4
    [p(i), observeddifference(i), effectsize(i)]=permutationTest(PHb_per{PHb_clustord(i)},PFC_per{PFC_clustord(i)},100000)     % 'sidedness','larger'
    %[pval(i), t_orig(i), crit_t{i}, est_alpha(i)]=mult_comp_perm_t2(PHb_base{i},PFC_base{i},10000,0)
end


