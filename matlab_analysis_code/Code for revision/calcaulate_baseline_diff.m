%% compare baseline form all_ints_data
clc
clear
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\eopn3')

all_ints_data = importdata("all_ints_data_eopn3.mat");
all_ints_data_control = importdata("all_ints_data_control.mat");



%%
baseline = baseline_form_all_ints_data(all_ints_data);
low_baseline = find(sum(baseline < 0.5, 2) > 6);
baseline(low_baseline,:) = [];


%% 
baseline_control = baseline_form_all_ints_data(all_ints_data_control);
low_baseline_control = find(sum(baseline_control < 0.5, 2) > 6);
baseline_control(low_baseline_control, :) = [];



%% plot
leg = ["control", "eopn3"];
f1 = figure;
f1.Position = [365 214 1149 764];

% mean_baseline
subplot(2,2,1)
histogram(mean(baseline_control, 2))
xline(mean(baseline_control,"all"), 'b')
xline(median(mean(baseline_control, 2)), 'g')
hold on
histogram(mean(baseline, 2))
xline(mean(baseline,"all"), 'r')
xline(median(mean(baseline, 2)),'c')

legend(["C57", "C57 mean", "C57 median", "eopn3", "eopn3 mean", "eopn3 median"])
[h,p,ci,stats] = ttest2(mean(baseline_control, 2),mean(baseline, 2) );
title('mean baseline')
subtitle(['ttest2 pval : ' num2str(p)])
% high int baseline
subplot(2,2,2)

histogram(baseline_control(:,1))
xline(mean(baseline_control(:,1)), 'b')
xline(median(baseline_control(:,1)), 'g')

hold on
histogram(baseline(:,1))
xline(mean(baseline(:,1)), 'r')
xline(median(baseline(:,1)), 'c')

legend(["C57", "C57 mean", "C57 median", "eopn3", "eopn3 mean", "eopn3 median"])
[h,p,ci,stats] = ttest2(baseline_control(:,1),baseline(:,1));
title('ND1 baseline')
subtitle(['ttest2 pval : ' num2str(p)])


%
subplot(2,2,3)

errorbar(mean(baseline),std(baseline,1), '-o')
hold on
errorbar(mean(baseline_control),std(baseline_control,1), '-o')
title('all ints baseline (mean+std)')

legend(leg)
%%
savefig(f1, 'plot of baseline C57 vs eopn3')


%% baseline form all_ints_data
function baseline = baseline_form_all_ints_data(all_ints_data)
NDs = [10, 8, 6, 4,3,2,1];
for i = 1:length(NDs)
    data = all_ints_data.(['ND' num2str(NDs(i))]);
    baseline(:,i) = cellfun(@(x) mean(x(1:30,:), "all"), data);
end
end


