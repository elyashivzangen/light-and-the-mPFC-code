%% analyze time
clear
clc
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\time of experiment')
t = importdata("all_ints_data_with_time.mat");
%%
%%
t.Is_reponsive = cell2mat(t.Is_reponsive);
t.Is_reponsive_and_IR = cell2mat(t.Is_reponsive_and_IR);


% G1 = grpstats(t,"file_name","mean","DataVars",["minutes", "Is_reponsive","Is_reponsive_and_IR"]);

t.minutes = minutes(t.time) - 60*9;

G1 = grpstats(t,"file_name","mean","DataVars",["minutes", "Is_reponsive","Is_reponsive_and_IR"]);
exp_minutes_mean = mean(G1.mean_minutes);
exp_minutes_sem = sem(G1.mean_minutes,1);
exp_duration = G1.mean_minutes(:,7) - G1.mean_minutes(:,1);
mean_duration = mean(exp_duration);
sem_duration = sem(exp_duration,1);
start_time_in_minutes = exp_minutes_mean(1);
end_time_in_minutes = exp_minutes_mean(end);
start_time_in_minutes_sem = exp_minutes_sem(1);
end_time_in_minutes_sem = exp_minutes_sem(end);


save('time_variables', "start_time_in_minutes","start_time_in_minutes_sem","end_time_in_minutes", "end_time_in_minutes_sem","mean_duration", "sem_duration", "exp_duration")


%%
f1 = figure;
f1.Position = [680 139 1104 839];

subplot(2,2,1)
scatter(G1.mean_minutes(:,end), G1.mean_Is_reponsive(:,1))
[r, pValue] = corr(G1.mean_minutes(:,end), G1.mean_Is_reponsive(:,1));
subtitle({['Pearson correlation: ' num2str(r)],['pval: ' num2str(pValue)]})
hold on 

lsline;
% Label the axes for clarity
xlabel('time of Experiment');
ylabel('Percentage of Responsive Cells');
title('transient responsive')

subplot(2,2,2)
scatter(G1.mean_minutes(:,end), G1.mean_Is_reponsive(:,2))
[r, pValue] = corr(G1.mean_minutes(:,end), G1.mean_Is_reponsive(:,2))
subtitle({['Pearson correlation: ' num2str(r)],['pval: ' num2str(pValue)]})
hold on 

lsline;
% Label the axes for clarity
xlabel('time of Experiment');
ylabel('Percentage of Responsive Cells');
title('sustained responsive')


subplot(2,2,3)
scatter(G1.mean_minutes(:,end), G1.mean_Is_reponsive_and_IR(:,1))
[r, pValue] = corr(G1.mean_minutes(:,end), G1.mean_Is_reponsive_and_IR(:,1))
subtitle({['Pearson correlation: ' num2str(r)],['pval: ' num2str(pValue)]})
hold on 

lsline;
% Label the axes for clarity
xlabel('time of Experiment');
ylabel('Percentage of Responsive Cells');
title('transient IE')



subplot(2,2,4)
scatter(G1.mean_minutes(:,end), G1.mean_Is_reponsive_and_IR(:,2))
[r, pValue] = corr(G1.mean_minutes(:,end), G1.mean_Is_reponsive_and_IR(:,2))
hold on 
subtitle({['Pearson correlation: ' num2str(r)],['pval: ' num2str(pValue)]})
lsline;
% Label the axes for clarity
xlabel('time of Experiment');
ylabel('Percentage of Responsive Cells');
title('sustained IE')

savefig(f1,'responsive and IE vs time')
exportgraphics(f1,'responsive and IE vs time.jpg')

%% add magnitude vector
NDs = [10, 8, 6, 4, 3, 2, 1];

for i = 1:length(NDs)
    v =     t.(['ND' num2str(NDs(i))]);
    mag(:,i) = cellfun(@(x) (mean(x(65:125,:),"all")-mean(x(1:30,:),"all"))/mean(x(1:30,:),"all"), v );
    res(:, i) = cellfun(@(x) (mean(x(65:125,:),"all")-mean(x(1:30,:),"all")), v );
    z_s(:, i) = cellfun(@(x) (mean(x(65:125,:),"all","omitnan")-std(x(1:30,:),0,"all"))/std(x(1:30,:),0,"all"), v );
    mag(isinf(mag(:,i)), i) = nan;
    z_s(isinf(z_s(:,i)),i) = nan;

end
t.magnetude_vector =  mag;
t.IR =  res;
t.Is_enhanced = res(:,end) > 0;
t.z_vector = z_s;
% flip negative cells
t.abs_IR =  res;
t.abs_IR(find(~t.Is_enhanced),:) = t.abs_IR(find(~t.Is_enhanced),:)*-1;

t.abs_magnetude_vector =  mag;
t.abs_magnetude_vector(find(~t.Is_enhanced),:) = t.abs_magnetude_vector(find(~t.Is_enhanced),:)*-1;

t.abs_z_vector =  z_s;
t.abs_z_vector(find(~t.Is_enhanced),:) = t.abs_z_vector(find(~t.Is_enhanced),:)*-1;

f1 = figure;
f1.Position = [680 139 1104 839];


%
% plot(mean(t.abs_z_vector, "omitnan")')
abs_magnetude_vector = t.abs_magnetude_vector(:,7);
times = t.minutes(:,end);
times(isnan(abs_magnetude_vector)) = [];
abs_magnetude_vector(isnan(abs_magnetude_vector)) = [];
subplot(2,2,1)
% figure
scatter(times, abs_magnetude_vector)
[r, pValue] = corr(times, abs_magnetude_vector)
hold on 
subtitle({['Pearson correlation: ' num2str(r)],['pval: ' num2str(pValue)]})
lsline;
% Label the axes for clarity
xlabel('time of Experiment');
ylabel('abs magnitude ND1');
title('abs magnitude vs time')
%

subplot(2,2,2)
scatter(t.minutes(:,end), t.abs_IR(:,end))
[r, pValue] = corr(t.minutes(:,end), t.abs_IR(:,end))
hold on 
subtitle({['Pearson correlation: ' num2str(r)],['pval: ' num2str(pValue)]})
lsline;
% Label the axes for clarity
xlabel('time of Experiment');
ylabel('abs repsonse ND1');
title('abs IR vs time')

% plot(mean(t.abs_z_vector, "omitnan")')
abs_z_vector = t.abs_z_vector(:,7);
times = t.minutes(:,end);
times(isnan(abs_z_vector)) = [];
abs_z_vector(isnan(abs_z_vector)) = [];
subplot(2,2,3)
% figure
scatter(times, abs_z_vector)
[r, pValue] = corr(times, abs_z_vector);
hold on 
subtitle({['Pearson correlation: ' num2str(r)],['pval: ' num2str(pValue)]})
lsline;
% Label the axes for clarity
xlabel('time of Experiment');
ylabel('abs zscore ND1');
title('abs zscore vs time')



savefig(f1,'responsive and magnitude vs time')
exportgraphics(f1,'responsive and magnitude vs time.jpg')


