cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\effect size\f6\d')
clear
clc
x = importdata("saline vs cno.mat")
%%

stats = mes(x.response(find(contains(x.tags,'dreadds before')),:),x.response(find(contains(x.tags,'dreadds after')),:),'hedgesg', 'isDep',1)
flip(stats.hedgesg)


%%
x = importdata("control saline vs cno.mat")

stats = mes(x.response(find(contains(x.tags,'control before')),:),x.response(find(contains(x.tags,'control after')),:),'hedgesg', 'isDep',1)
flip(stats.hedgesg)