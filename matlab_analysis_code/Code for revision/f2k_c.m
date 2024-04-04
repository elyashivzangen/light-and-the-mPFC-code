cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\effect size\f2\k')
g = importdata("side_per_session_data.mat")

%% pesistant
sample1 = g.mean_is_ir(ismember(g.side,'R'),2)
sample2 = g.mean_is_ir(ismember(g.side,'L'),2)

[p, observeddifference, effectsize] = permutationTest(sample1, sample2, 10000) 
d = computeCohen_d(sample1, sample2)
stats = mes(sample1,sample2,'hedgesg')
