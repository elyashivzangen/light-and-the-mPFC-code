cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\effect size\figure 1\1i')
g = importdata("side_per_session_data.mat")
%% transient
sample1 = g.mean_is_responsive(ismember(g.side,'R'),1)
sample2 = g.mean_is_responsive(ismember(g.side,'L'),1)

[p, observeddifference, effectsize] = permutationTest(sample1, sample2, 10000) 
d = computeCohen_d(sample1, sample2)

%% transient
sample1 = g.mean_is_responsive(ismember(g.side,'R'),2)
sample2 = g.mean_is_responsive(ismember(g.side,'L'),2)

[p, observeddifference, effectsize] = permutationTest(sample1, sample2, 10000) 
d = computeCohen_d(sample1, sample2)