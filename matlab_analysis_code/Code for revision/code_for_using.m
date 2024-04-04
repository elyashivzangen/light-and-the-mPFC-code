clear
clc
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\DREEDDS_VS_CONTROL_PHb\all_ints_data')
T = importdata("all_ints_data_control.mat");
T2 = importdata("all_ints_data_dreadds.mat");
%%
T1 = T;
T21 = T2;
T = exclude_changing_cells(T);
T2 = exclude_changing_cells(T2);
%%



before = T(find(contains(T.file_name, 'before')),:);
control_res = cell2mat(before.Is_reponsive);
control_res = find(control_res(:,2));
after = T(find(contains(T.file_name, 'after')),:);

Tres = [before(control_res,:);after(control_res,:) ];

before = T2(find(contains(T2.file_name, 'before')),:);
control_res = cell2mat(before.Is_reponsive);
control_res = find(control_res(:,2));
after = T2(find(contains(T2.file_name, 'after')),:);

T2res = [before(control_res,:);after(control_res,:) ];
%%
%%
[before_mag,after_mag] = plot_all_options(T,'control');

[before_mag_dreadds,after_mag_dreadds] = plot_all_options(T2,'dreadds');
%%


plot_all_options(Tres,'responsive control')
plot_all_options(T2res,'responsive dreadds')


%%



%% cheack for baseline changes
function T1 = exclude_changing_cells(T)
% saline = T2(find(contains(T2.file_name,'before')),:);
% cno = T2(find(~contains(T2.file_name,'before')),:);
saline = T(find(contains(T.file_name,'before')),:);
cno = T(find(~contains(T.file_name,'before')),:);
saline = sortrows(saline, "cell_name");
cno = sortrows(cno, "cell_name");
% pval = [];
for i = 1:size(saline,1)
    NDs = [1 2 3 4 6 8 10];
    diff_total = [];
    for j = 1:7
        cno_int = cno{i,['ND' num2str(NDs(j))]}{1};
        %         cno_int = cno{i,'ND10'}{1};
        %         cno_int = cno{i,'ND10'}{1};

        saline_int = saline{i,['ND' num2str(NDs(j))]}{1};
        saline_baseline = mean(saline_int(1:30,:),1);
        cno_baseline = mean(cno_int(1:30,:),1);
        diff = saline_baseline - cno_baseline;
        diff_total = [diff_total; diff'];
        pval(i,j)=mult_comp_perm_t1(diff',10000,1,0.05,0,0);
    end
end
%      [~,   pval(i,1)]=ttest(diff_total);
%
%     figure
%     histogram(diff_total)
%     xline(mean(diff_total),'r')
%     title(['pval: ' num2str(pval(i))])
% rel_cells = find(~(sum(pval < 0.05,2) == 7 ));
%  rel_cells = find(~(sum(pval(:,1:3) < 0.05,2) == 3));
 rel_cells = find(~(pval(:,1) < 0.05));

T1 = [saline(rel_cells,:); cno(rel_cells,:)];


end



%%
function [before_mag,after_mag] = plot_all_options(T,name)
C = cellfun(@(x) strsplit(x, ["_", "."]),T.file_name,'UniformOutput',false);
T.exp_name = cellfun(@(x) [x{1},x{2}] ,C,'UniformOutput',false);
T.time = cellfun(@(x) [x{end-1}] ,C,'UniformOutput',false);



T.Is_reponsive(find(cellfun(@(x) isempty(x), T.Is_reponsive)),:) = {[0,0,0]};
T.Is_reponsive_and_IR(find(cellfun(@(x) isempty(x), T.Is_reponsive_and_IR)),:) = {[0,0,0]};

T.Is_reponsive = cell2mat(T.Is_reponsive);
T.Is_reponsive_and_IR = cell2mat(T.Is_reponsive_and_IR);


%%
w = 65:125;
NDs = [1 2 3 4 6 8 10];
for j = 1:7
    allx = T.(['ND' num2str(NDs(j))]);
    for i = 1:length(T.ND1)
        x = allx{i};
        T.magnitude(i,j) = (mean(x(w,:),"all")-mean(x(1:30,:),"all"))/mean(x(1:30,:),"all");
        T.zscore(i,j) = (mean(x(w,:),"all")-mean(x(1:30,:),"all"))/std(x(1:30,:),0,"all");
        T.IR(i,j) = (mean(x(w,:),"all")-mean(x(1:30,:),"all"));

        if T.magnitude(i,j) == inf
            T.magnitude(i,j) = nan;

        end
        if T.zscore(i,j) == inf
            T.zscore(i,j) = nan;

        end
    end
end
T.is_enhanced = T.magnitude(:,1) > 0;
T.magnitude(find(~T.is_enhanced),:) = T.magnitude(find(~T.is_enhanced),:)*-1;
T.zscore(find(~T.is_enhanced),:) = T.zscore(find(~T.is_enhanced),:)*-1;
T.IR(find(~T.is_enhanced),:) = T.IR(find(~T.is_enhanced),:)*-1;

before_mag = T.magnitude(ismember(T.time,'before'),:);
after_mag = T.magnitude(ismember(T.time,'after'),:);

[rows,~] = find(isnan(before_mag));
[rows2, ~] = find(isnan(after_mag));
nans = [rows; rows2];
before_mag(nans,:) = [];
after_mag(nans,:) = [];

before_z = T.zscore(ismember(T.time,'before'),:);
after_z = T.zscore(ismember(T.time,'after'),:);

[rows,~] = find(isnan(before_z));
[rows2, ~] = find(isnan(after_z));
nans = [rows; rows2];
before_z(nans,:) = [];
after_z(nans,:) = [];

before_IR = T.IR(ismember(T.time,'before'),:);
after_IR = T.IR(ismember(T.time,'after'),:);

[rows,~] = find(isnan(before_IR));
[rows2, ~] = find(isnan(after_IR));
nans = [rows; rows2];
before_IR(nans,:) = [];
after_IR(nans,:) = [];


%%
x = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];
f1 = figure;
f1.Position = [680 139 1104 839];
sgtitle(['magnitude: ' name])
subplot(2,2,1)

plot(x, mean(before_mag,1),'-o')
hold on
plot(x, mean(after_mag,1),'-o')
legend(["sanline", "cno"],"Location","best")
hold off
title('magnitude IR curve')
%%
subplot(2,2,4)

plot(x, mean(T.magnitude(ismember(T.time,'before'),:),1, "omitnan"),'-o')
hold on
plot(x, mean(T.magnitude(ismember(T.time,'after'),:),1, "omitnan"),'-o')
legend(["sanline", "cno"],"Location","best")
hold off
title('magnitude IR curve without erasing 0 baseline cells')

%%

subplot(2,2,2)
bar([1,2], [mean(before_mag(:,1)), mean(after_mag(:,1))])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(before_mag(:,1)-after_mag(:,1), 100000, 1, 0.05, 0, 0)
[a,p3,c] = ttest(before_mag(:,1)-after_mag(:,1))
p = signrank(before_mag(:,1)-after_mag(:,1))
subtitle(['pval premutation= ' num2str(p1)])
title('nd1')



%%
subplot(2,2,3)
bar([1,2], [mean(before_mag(:,1:3),"all"), mean(after_mag(:,1:3),"all")])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(mean(before_mag(:,1:3),2)-mean(after_mag(:,1:3),2), 100000, 1, 0.05, 0, 0)
% [a,p3,c] = ttest((before_mag(1:3))-(after_mag(1:3)))
% p = signrank((before_mag(1:3))-(after_mag(1:3)))
subtitle(['pval premutation = ' num2str(p1)])
title('nd123')

savefig(f1, ['magnitude' name])

%%
%%
x = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];
f2 = figure;
f2.Position = [680 139 1104 839];
sgtitle(['zscore: ' name])
subplot(2,2,1)

plot(x, mean(before_z,1),'-o')
hold on
plot(x, mean(after_z,1),'-o')
legend(["sanline", "cno"],"Location","best")
hold off
title('zscore IR curve')
%%
subplot(2,2,4)

plot(x, mean(T.zscore(ismember(T.time,'before'),:),1, "omitnan"),'-o')
hold on
plot(x, mean(T.zscore(ismember(T.time,'after'),:),1, "omitnan"),'-o')
legend(["sanline", "cno"],"Location","best")
hold off
title('zscore IR curve without erasing 0 baseline cells')

%%

subplot(2,2,2)
bar([1,2], [mean(before_z(:,1)), mean(after_z(:,1))])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(before_z(:,1)-after_z(:,1), 100000, 1, 0.05, 0, 0)
[a,p3,c] = ttest(before_z(:,1)-after_z(:,1))
p = signrank(before_z(:,1)-after_z(:,1))
subtitle(['pval premutation= ' num2str(p1)])
title('nd1')



%%
subplot(2,2,3)
bar([1,2], [mean(before_z(:,1:3),"all"), mean(after_z(:,1:3),"all")])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(mean(before_z(:,1:3),2)-mean(after_z(:,1:3),2), 100000, 1, 0.05, 0, 0)
% [a,p3,c] = ttest((before_z(1:3))-(after_z(1:3)))
% p = signrank((before_z(1:3))-(after_z(1:3)))
subtitle(['pval premutation = ' num2str(p1)])
title('nd123')

savefig(f2, name)

%%
x = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];
f3 = figure;
f3.Position = [680 139 1104 839];
sgtitle(['IR: ' name])
subplot(2,2,1)

plot(x, mean(before_IR,1),'-o')
hold on
plot(x, mean(after_IR,1),'-o')
legend(["sanline", "cno"],"Location","best")
hold off
title('IR IR curve')
%%
subplot(2,2,4)

plot(x, mean(T.IR(ismember(T.time,'before'),:),1, "omitnan"),'-o')
hold on
plot(x, mean(T.IR(ismember(T.time,'after'),:),1, "omitnan"),'-o')
legend(["sanline", "cno"],"Location","best")
hold off
title('IR IR curve without erasing 0 baseline cells')

%%

subplot(2,2,2)
bar([1,2], [mean(before_IR(:,1)), mean(after_IR(:,1))])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(before_IR(:,1)-after_IR(:,1), 100000, 1, 0.05, 0, 0)
[a,p3,c] = ttest(before_IR(:,1)-after_IR(:,1))
p = signrank(before_IR(:,1)-after_IR(:,1))
subtitle(['pval premutation= ' num2str(p1)])
title('nd1')



%%
subplot(2,2,3)
bar([1,2], [mean(before_IR(:,1:3),"all"), mean(after_IR(:,1:3),"all")])
xticklabels(["sanline", "cno"])
[p1,v,c] = mult_comp_perm_t1(mean(before_IR(:,1:3),2)-mean(after_IR(:,1:3),2), 100000, 1, 0.05, 0, 0)
% [a,p3,c] = ttest((before_IR(1:3))-(after_IR(1:3)))
% p = signrank((before_z(1:3))-(after_IR(1:3)))
subtitle(['pval premutation = ' num2str(p1)])
title('nd123')

savefig(f1, name)



end
