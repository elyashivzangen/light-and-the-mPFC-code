%% per session vs per mouse vs per cell
clear
clc
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\response statistics per erea')
%%
C57 =  importdata('C57_ALL_CELLS.mat');
%%

%%
per_session = grpstats(C57,"file_name", "mean", DataVars=["Is_reponsive_and_IR","Is_reponsive"]);

f1 = figure;
f1.Position = [680 139 1104 839];

subplot(2,2,1)
histogram(per_session.GroupCount, 30)
title('cells per exp')

subplot(2,2,2)
histogram(per_session.mean_Is_reponsive_and_IR(:,2), 30)
xline(mean(per_session.mean_Is_reponsive_and_IR(:,2)), 'c')
xline(mean(C57.Is_reponsive_and_IR(:,2)),'r')
legend(["data", "mean per experement", "mean per cell"])

title('responsive and IE % per exp')


subplot(2,2,3)
histogram(per_session.mean_Is_reponsive(:,2), 30)
xline(mean(per_session.mean_Is_reponsive(:,2)), 'c')
xline(mean(C57.Is_reponsive(:,2)),'r')

legend(["data", "mean per experement", "mean per cell"])


title('responsive % per exp')

savefig(f1, 'responsive and ir per session vs per cell')
save('data per session', "per_session")
exportgraphics(f1, 'responsive and ir per session vs per cell.jpg')
%% add per erea
mkdir('per session per erea')
cd('per session per erea')

C57.main_erea = cellfun(@(x) x{1,1}(1:2), C57.region_acronym, "UniformOutput",false);
per_session_per_erea = grpstats(C57,["file_name", "main_erea"], "mean", DataVars=["Is_reponsive_and_IR","Is_reponsive"]);

a = ["AC", "PL", "IL", "DP", "TT"];
for i = 1:5
    data = per_session_per_erea(find(ismember(per_session_per_erea.main_erea, a{i})),:);
    f1 = figure;
f1.Position = [680 139 1104 839];

subplot(2,2,1)
histogram(data.GroupCount, 30)
title('cells per exp')

subplot(2,2,2)
histogram(data.mean_Is_reponsive_and_IR(:,2), 30)
xline(mean(data.mean_Is_reponsive_and_IR(:,2)), 'c')
xline(mean(C57.Is_reponsive_and_IR(:,2)),'r')
legend(["data", "mean per experement", "mean per cell"])

title('responsive and IE % per exp')


subplot(2,2,3)
histogram(data.mean_Is_reponsive(:,2), 30)
xline(mean(data.mean_Is_reponsive(:,2)), 'c')
xline(mean(C57.Is_reponsive(:,2)),'r')

legend(["data", "mean per experement", "mean per cell"])


title('responsive % per exp')
sgtitle(a{i})

savefig(f1, ['responsive and ir per session vs per cell' a{i}])
save(['data per session' a{i} ], "data")
exportgraphics(f1, ['responsive and ir per session vs per cell' a{i} '.jpg'])

end