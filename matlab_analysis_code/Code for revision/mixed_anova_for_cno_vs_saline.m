%% load and prepare the data
clear
clc
close all
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\DREEDDS_VS_CONTROL\new_IR_calculations\test_mixed_effect_models')
load("all_cells_with_tages_and_cell_idx.mat")
% load("all_cells_before_after_fit_parameters_DREEDDS.mat")
% load("all_cells_dreadds.mat")
% load("all_cells_control.mat")
T.magnitude_ND1 = T.magnitude(:,end);
T.zscore_ND1 = T.zscore(:,end);
T.response_ND1 = T.response(:,end);

T.injection = cellfun(@(x) x(1:7) , T.tags, 'UniformOutput' , false);
T.treatment = repmat("saline", [length(T.injection), 1]);
T.treatment(find(contains(T.tags, 'after'))) = "cno";

%%
responsive_cells = T.cell_idx(find(ismember(T.treatment, 'saline') & T.Is_reponsive(:,2)));
res_T = T(find(ismember(T.cell_idx,responsive_cells)),:);



IE_cells = T.cell_idx(find(ismember(T.treatment, 'saline') & T.Is_reponsive_and_IR(:,2)));
IE_T = T(find(ismember(T.cell_idx,IE_cells)),:);


%% 

T = IE_T




saline = T(find(contains(T.tags,"before")),:);
cno = T(find(contains(T.tags,"after")),:);

between_factors = zeros(size(cno,1),1);
between_factors(contains(saline.tags, "dreadds"), :) = 0;
between_factors(contains(saline.tags, "control"), :) = 1;
between_factors = between_factors(:,1);
% within_factor_names = ["Saline", "CNO"]';
between_factor_names = ["DREADDS", "control"]';

%%
fields = ["magnitude_ND1", "zscore_ND1", "response_ND1", "rmse", "rsquare", "DNR", "n"];
for i = 1:length(fields)
    datamat = [saline.(fields{i}), cno.(fields{i})];
    [tbl.(fields{i}),rm.(fields{i})] = simple_mixed_anova(datamat, between_factors, "Saline_vs_cno", "DREADDS_vs_control");
    f1 = figure;
    T2 = rm.(fields{i});
    stats = anova(rm.(fields{i}));

    means = grpstats(T2.BetweenDesign, "DREADDS_vs_control", "mean");
    bar(categorical(["DREADDS saline", "DREADDS cno";"control saline",  "control cno"]), means{:,["mean_Y001","mean_Y002"]})
    title(fields{i})
    subtitle({['DREADDS vs control pval= ' num2str(tbl.(fields{i}){"DREADDS_vs_control", "pValue"})], ['DREADDS_vs_control:Saline_vs_cno pval= ' num2str(tbl.(fields{i}){"DREADDS_vs_control:Saline_vs_cno", "pValue"})]})
end

%
%% mixed effect model
fields = ["magnitude_ND1", "zscore_ND1", "response_ND1", "rmse", "rsquare", "DNR", "n"];
for i = 1:length(fields)
    newT = res_T(:, [fields{i} ,"treatment","injection","cell_idx"])
% Subject ID (to identify measurements from the same animal)
% Conditioned_light (the between-subjects factor with different numbers of animals in each group)
% test_light Time or Condition (the within-subjects factor, e.g., before and after)
% CPP_value Dependent Variable (the outcome measurement)
% Fit the mixed-effects model
% Model specification:
% - 'DependentVariable ~ Time*Group' specifies a model with main effects for Time and Group and their interaction.
% - '(1|SubjectID)' specifies a random intercept for each subject, accounting for the repeated measures.
lme = fitlme(res_T, 'magnitude_ND1 ~ treatment*injection + (1|cell_idx)');
% Display the results
disp(lme)
stats.(fields{i}) = anova(lme);
% [results,~,~,gnames] = multcompare(stats,"Dimension",[1 2]);

end
