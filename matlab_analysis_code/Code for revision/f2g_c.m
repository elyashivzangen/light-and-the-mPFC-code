cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\effect size\f2\g(latency)')
x = importdata("latenceys.mat")
%%
grpstats(x,"clusters","mean")
grpstats(x,"clusters","median")
x1 = x(find(~(x.clusters == 2)),:)
x1.clusters(x1.clusters == 3) = 2;
x1.clusters(x1.clusters == 4) = 3;
x1 = sortrows(x1,"clusters")
stats = mes1way(x1.peak,'eta2','group',x1.clusters)

%% post hoc
%% on vs off
stats = mes(x1.peak(x1.clusters == 1),x1.peak(~(x1.clusters == 1)),'hedgesg')
 d = computeCohen_d(x1.peak(x1.clusters == 1),x1.peak(~(x1.clusters == 1)))
[p, observeddifference, effectsize] =  permutationTest(x1.peak(x1.clusters == 1),x1.peak(~(x1.clusters == 1)),10000)

%%
stats = mes(x1.peak(x1.clusters == 2),x1.peak((x1.clusters == 3)),'hedgesg')
 d = computeCohen_d(x1.peak(x1.clusters == 2),x1.peak((x1.clusters == 3)))
[p, observeddifference, effectsize] =  permutationTest(x1.peak(x1.clusters == 1),x1.peak(~(x1.clusters == 1)),10000)