%% analize DTA
clear
clc
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\DTA\all_ints_data')
DTA = importdata('all_ints_data_DTA.mat');
C57 =  importdata('all_ints_data_C57(all_cells).mat');
CONTROL =  importdata('all_ints_data_control(mcherry).mat');



%% add tags 
DTA.tag = repmat({'DTA'}, size(DTA, 1), 1);
C57.tag = repmat({'C57'}, size(C57, 1), 1);
CONTROL.tag = repmat({'CONTROL'}, size(CONTROL, 1), 1);

%% combine tables
commonVars = intersect(DTA.Properties.VariableNames,C57.Properties.VariableNames);
commonVars = intersect(commonVars, CONTROL.Properties.VariableNames);

T =  [DTA(:, commonVars); C57(:, commonVars); CONTROL(:, commonVars)];


%%
T.Is_reponsive = cell2mat(T.Is_reponsive);
T.Is_reponsive_and_IR = cell2mat(T.Is_reponsive_and_IR);
T.basline1 =  cellfun(@(x) mean(x(1:30,:), "all"),T.ND1);
T.magnitude = cellfun(@(x) (mean(x(65:125,:),"all")-mean(x(1:30,:),"all"))/mean(x(1:30,:),"all"), T.ND1 );
T.magnitude(~T.basline1) = nan;

T.zscore = cellfun(@(x) (mean(x(65:125,:),"all","omitnan")-std(x(1:30,:),0,"all"))/std(x(1:30,:),0,"all"), T.ND1 );
T.zscore(~T.basline1) = nan;


T.response = cellfun(@(x) (mean(x(65:125,:),"all")-mean(x(1:30,:),"all")), T.ND1 );
%% add magnitude vector
NDs = [10, 8, 6, 4, 3, 2, 1];

for i = 1:length(NDs)
    v = T.(['ND' num2str(NDs(i))]);
    mag(:,i) = cellfun(@(x) (mean(x(65:125,:),"all")-mean(x(1:30,:),"all"))/mean(x(1:30,:),"all"), v );
    res(:, i) = cellfun(@(x) (mean(x(65:125,:),"all")-mean(x(1:30,:),"all")), v );
    z_s(:, i) = cellfun(@(x) (mean(x(65:125,:),"all","omitnan")-std(x(1:30,:),0,"all"))/std(x(1:30,:),0,"all"), v );
    mag(isinf(mag(:,i)), i) = nan;
    z_s(isinf(z_s(:,i)),i) = nan;

end
T.magnetude_vector =  mag;
T.IR =  res;
T.Is_enhanced = res(:,end) > 0;
T.z_vector = z_s;
% flip negative cells
T.abs_IR =  res;
T.abs_IR(find(~T.Is_enhanced),:) = T.abs_IR(find(~T.Is_enhanced),:)*-1;

T.abs_magnetude_vector =  mag;
T.abs_magnetude_vector(find(~T.Is_enhanced),:) = T.abs_magnetude_vector(find(~T.Is_enhanced),:)*-1;
T.abs_magnetude_vector(~T.basline1) = nan;

T.abs_z_vector =  z_s;
T.abs_z_vector(find(~T.Is_enhanced),:) = T.abs_z_vector(find(~T.Is_enhanced),:)*-1;
T.abs_z_vector(~T.basline1) = nan;



%%
save('conected_table', 'T')
%% magnitude ND1
[p,tbl,stats] = anova1(abs(T.magnitude),T.tag);
savefig('magnitude_all_cells_box_plot')
results = multcompare(stats);
tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"])
title('all cells magnitude')
savefig('magnitude_all_cells_multiple_comp')
save('magnitude_all_cells_multiple_comp', 'tbl')
%% zscore ND1
[p,tbl,stats] = anova1(abs(T.zscore),T.tag);
savefig('zscore_all_cells_box_plot')
results = multcompare(stats);
tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"])
title('all cells zscore')
savefig('zscore_all_cells_multiple_comp')
save('zscore_all_cells_multiple_comp', 'tbl')

%% response ND1
[p,tbl,stats] = anova1(abs(T.response),T.tag);
savefig('response_all_cells_box_plot')
results = multcompare(stats);
tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"])
title('all cells response')
savefig('response_all_cells_multiple_comp')
save('response_all_cells_multiple_comp', 'tbl')

%% 
mean_sem_response_for_each_group = grpstats(T,"tag",["mean", "sem"],"DataVars",["abs_IR","abs_magnetude_vector","abs_z_vector"]);
save('mean_sem_response_for_each_group', 'mean_sem_response_for_each_group')
%% plot
x = [15.4000000000000;14.9000000000000;14.4000000000000;13.9000000000000;12.9000000000000;11.4000000000000;9.40000000000000];

f1 = figure;
f1.Position = [680 139 1104 839];


subplot(2,2,1)
plot(flip(x), mean_sem_response_for_each_group.mean_abs_IR', '-o')
legend(mean_sem_response_for_each_group.tag, Location="best")
title('response')

subplot(2,2,2)
plot(flip(x), mean_sem_response_for_each_group.mean_abs_magnetude_vector', '-o')
% legend(mean_sem_response_for_each_group.tag)
title('magnitude')

subplot(2,2,3)
plot(flip(x), mean_sem_response_for_each_group.mean_abs_z_vector', '-o')
% legend(mean_sem_response_for_each_group.tag)
title('z score')

%
colors = ["c", "r"	, "y", "m"];

fulltitle = [];
names = mean_sem_response_for_each_group.tag;
for i = 1:3
    y = mean_sem_response_for_each_group.mean_abs_IR(i,:)
   fo = fitoptions('Method','NonlinearLeastSquares',...
                'Algorithm','Trust-Region',...
                'Display','final',...
                'TolFun',1.0E-20,...
                'TolX',1.0E-20,...
                'Lower',[-1,min(x),-5],...
                'Upper',[2*max(y),max(x),5],...
                'StartPoint',[max(y),mean(x),0]);

            ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
            [curve1,gof1]=fit(flip(x),y',ft);
                subplot(2,2,4)
                hold on;
                plot(flip(x),y,'o', Color=colors{i});
                plot(curve1,colors{i});
                legend("off")
                fulltitle{i} = [names{i} ':  rmse = ',num2str(gof1.rmse),'   n = ',num2str(curve1.n), '  r2 = ', num2str(gof1.rsquare)];
end
title(fulltitle);


savefig(f1, 'IR curves together')


%% Cells per cluster
T.cluster = cell2mat(T.cluster);
%%
IR_cells  = T(find(T.Is_reponsive_and_IR(:,2)),:);
cluster_names = categorical(["ON-OFF suppressed", "ON-OFF enhanced", "ON suppressed",  "ON enhanced"]);

[clusters_count.count_table, clusters_count.chi2, clusters_count.pval, lables] = crosstab(IR_cells.cluster,IR_cells.tag);
clusters_count.df =(size(clusters_count.count_table,1)-1)* (size(clusters_count.count_table,1)-1);

clusters_count.destrebution_table = clusters_count.count_table./sum(clusters_count.count_table, 1);
clusters_count.percentage_table = clusters_count.count_table./mean_sem_response_for_each_group.GroupCount';
%%
f1 = figure;
f1.Position = [680 139 1104 839];
subplot(2,2,1)
bar(cluster_names, clusters_count.destrebution_table)
% legend(lables{1:3,2})
title('destrebution per cluster (each cluster/ir cells)')

subplot(2,2,2)
bar(cluster_names, clusters_count.percentage_table)
% legend(lables{1:3,2})
title('pecentage per cluster (each cluster/total cells )')

subplot(2,2,3)
bar(cluster_names, clusters_count.count_table)
legend(lables{1:3,2})
title('number of cell each cluster')


%%
savefig(f1, 'cluster per group')
exportgraphics(f1, 'cluster per group.jpg')
save('clusters_count_per_group', 'clusters_count')



save( 'all_ints_with_tags','T')

%% Calculate response stats
% T2 = T(find(contains(T.tag, ["CONTROL", "DTA"])),:);
T2 = T(find(contains(T.tag, ["C57", "DTA"] )),:);

mkdir('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\DTA\all_ints_data\premutation test')
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\DTA\all_ints_data\premutation test')

save('DTA_vs_mcheary', 'T2')
n_perm = 100000;
tail = -1;
t_stat = ['t'];
t_stat = ['w'];
% t_stat = ['td'];
pval = [];
t_orig = [];
plot(mean(T2.abs_IR(contains(T2.tag,"DTA"),:)))
hold on
plot(mean(T2.abs_IR(contains(T2.tag,"CONTROL"),:)))
plot(mean(T2.abs_IR(contains(T2.tag,"C57"),:)))


[pval(:,1), t_orig(:,1), crit_t]=mult_comp_perm_t2(T2.abs_IR(contains(T2.tag,"DTA"),:),T2.abs_IR(contains(T2.tag,"C57"),:),n_perm,tail,0.05,0,t_stat);
prem = table(NDs', pval, t_orig, 'VariableNames',["NDs", "pval", "t_orig"]);

[h,p,ci,stats] = ttest2(T2.abs_IR(contains(T2.tag,"DTA"),:),T2.abs_IR(contains(T2.tag,"C57"),:))
X  = T2.abs_IR;
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

cd .. 
