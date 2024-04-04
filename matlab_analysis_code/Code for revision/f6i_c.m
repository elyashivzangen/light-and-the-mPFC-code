clc
clear
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\effect size\f6\i')
x = importdata("all_ints_with_tags.mat");
%%
g1 = grpstats(x,["file_name", "tag"],"mean",DataVars=["Is_reponsive","Is_reponsive_and_IR"]);
g1.t = grp2idx(g1.tag);

% g2 = grpstats(g1,"tag","mean", DataVars=["mean_Is_reponsive","mean_Is_reponsive_and_IR"])
stats1 = mes1way(g1.mean_Is_reponsive(:,2),'eta2','group',g1.t)
stats2 = mes1way(g1.mean_Is_reponsive_and_IR(:,2),'eta2','group',g1.t)

%%

stats3 = mes(g1.mean_Is_reponsive(g1.t == 1,2),g1.mean_Is_reponsive(g1.t == 2,2),'hedgesg')
stats4 = mes(g1.mean_Is_reponsive(g1.t == 1,2),g1.mean_Is_reponsive(g1.t == 3,2),'hedgesg')
stats4 = mes(g1.mean_Is_reponsive(g1.t == 3,2),g1.mean_Is_reponsive(g1.t == 1,2),'hedgesg')


stats5 = mes(g1.mean_Is_reponsive_and_IR(g1.t == 1,2),g1.mean_Is_reponsive_and_IR(g1.t == 2,2),'hedgesg')
stats6 = mes(g1.mean_Is_reponsive_and_IR(g1.t == 3,2),g1.mean_Is_reponsive_and_IR(g1.t == 1,2),'hedgesg')



stats7 = mes(g1.mean_Is_reponsive(g1.t == 3,2),g1.mean_Is_reponsive(g1.t == 2,2),'hedgesg')

stats8 = mes(g1.mean_Is_reponsive_and_IR(g1.t == 3,2),g1.mean_Is_reponsive_and_IR(g1.t == 2,2),'hedgesg')
%%
x.t= grp2idx(x.tag)
stats9 = mes(x.abs_IR(find(x.t == 2),:),x.abs_IR(find(x.t == 1),:),'hedgesg')
mult_comp_perm_t2(x.abs_IR(x.t == 1,:),x.abs_IR(x.t == 2,:), 10000, -1, 0.05, 0,'w' )
plot(mean())
