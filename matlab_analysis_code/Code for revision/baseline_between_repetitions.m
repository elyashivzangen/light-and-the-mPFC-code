%% laser repetitions vs no laser
%% compare response per rep
clc
clear
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\eopn3')

all_ints_data = importdata("all_ints_data_eopn3.mat");
all_ints_data_control = importdata("all_ints_data_control.mat");
%%

NDs = [10, 8, 6, 4,3,2,1];
for i = 1:length(NDs)
    data = all_ints_data.(['ND' num2str(NDs(i))]);
    baseline = cellfun(@(x) mean(x(1:30,:), 1), data,UniformOutput=false);
    baseline(1:10,:) = [];
    baseline = cell2mat(baseline);
    baseline_all(i, :,:) = baseline;
    figure
    plot(mean(baseline,1),'-o')
end

mean_baseline = squeeze(mean(baseline_all,1));


mean_baseline_1_7 = mean_baseline(:,1:14)
mean_baseline_1_7 = reshape(mean_baseline_1_7,[size(mean_baseline_1_7,1),2,7])
mean_baseline_1_7 = squeeze(mean(mean_baseline_1_7,2))
anova1(mean_baseline_1_7)
[p,tbl,stats] = anova1(mean_baseline_1_7);
results = multcompare(stats);

%%
%% response

NDs = [10, 8, 6, 4,3,2,1];
for i = 1:length(NDs)
    data = all_ints_data_control.(['ND' num2str(NDs(i))]);
    response = cellfun(@(x) mean(x(65:125,:), 1), data,UniformOutput=false);
    response(1:10,:) = [];
    response = cell2mat(response);
    response_all(i, :,:) = response;
    figure
    plot(mean(response,1),'-o')
end

mean_response = squeeze(mean(response_all,1));


mean_response_1_7 = mean_response(:,1:14)
mean_response_1_7 = reshape(mean_response_1_7,[size(mean_response_1_7,1),2,7])
mean_response_1_7 = squeeze(mean(mean_response_1_7,2))
anova1(mean_response_1_7)
[p,tbl,stats] = anova1(mean_response_1_7);
results = multcompare(stats);