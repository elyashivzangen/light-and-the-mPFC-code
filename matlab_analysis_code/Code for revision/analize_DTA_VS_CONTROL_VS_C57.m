%% analize DTA
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
results = multcompare(stats);
%% zscore ND1
[p,tbl,stats] = anova1(abs(T.zscore),T.tag);
results = multcompare(stats);

%% response ND1
[p,tbl,stats] = anova1(abs(T.response),T.tag);
results = multcompare(stats);

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