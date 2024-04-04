% %%
% cd("I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\pupil_dilation\both_all_tables")
% all_ints_data_before = load("all_ints_data_before.mat");
% all_ints_data_before = all_ints_data_before.all_ints_data;
% all_ints_data_before.key = cellfun(@(x, y) [x(1:10) y], all_ints_data_before.file_name, all_ints_data_before.cell_name, UniformOutput=false); 
% 
% 
% all_ints_data_after = load("all_ints_data_after_were_before_is.mat");
% all_ints_data_after = all_ints_data_after.all_ints_data;
% all_ints_data_after.file_name = cellfun(@(x) x(1:10), all_ints_data_after.file_name, UniformOutput=false); 
% all_ints_data_after.key = cellfun(@(x, y) [x(1:10) y], all_ints_data_after.file_name, all_ints_data_after.cell_name, UniformOutput=false); 
% 
% 
% 
% 
% 
% both_table = innerjoin(all_ints_data_after,all_ints_data_before,"Keys","key");
% %%
cd("I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\pupil_dilation")
both_table = importdata("both_table_all_cells.mat")

%% add mean PSTH
ND_vars = find(contains(both_table.Properties.VariableNames, "ND"));
for i = ND_vars
  psth = cellfun(@(x) mean(x,2), both_table{:,i}, UniformOutput=false);
  if isempty(psth{end})
      continue
  end

  psth = cellfun(@(x) (x - mean(x(1:30)))', psth, UniformOutput=false);
  both_table.(['psth' both_table.Properties.VariableNames{i}]) = cell2mat(psth);
  psth = [];
end

rel_NDs = ["6", "8", "10"];
%% use all cells
% plot mean response
f1 = figure;
f1.Position =   [220 130 1190 793];
x = [12.9, 11.4, 9.4];
for i = 1:length(rel_NDs)
    subplot(2,2, i)
    plot(mean(both_table.(['psthND' rel_NDs{i} '_all_ints_data_before'])))
    hold on
    plot(mean(both_table.(['psthND' rel_NDs{i} '_all_ints_data_after'])))
    title(['ND = ' num2str(rel_NDs(i))])
    response(1,i) = mean(abs(mean(both_table.(['psthND' rel_NDs{i} '_all_ints_data_before'])(:,65:125), 2)));
    response(2,i) = mean(abs(mean(both_table.(['psthND' rel_NDs{i} '_all_ints_data_after'])(:,65:125), 2)));

end
subplot(2,2, 4)
plot(x, response, '-o')
    

legend(["control", "Pupil dilated"],Location="best")
mkdir('all_cells')
save('late_abs_response', '')
save('late_abs_response')
sgtitle('all cells')

%% responsive cells
temp = cell2mat(both_table.Is_reponsive);
res_cells = find(temp(:,2));
res_table = both_table(res_cells,:);


% plot mean response
f1 = figure;
f1.Position =   [220 130 1190 793];
x = [12.9, 11.4, 9.4];
for i = 1:length(rel_NDs)
    subplot(2,2, i)
    plot(mean(res_table.(['psthND' rel_NDs{i} '_all_ints_data_before'])))
    hold on
    plot(mean(res_table.(['psthND' rel_NDs{i} '_all_ints_data_after'])))
    title(['ND = ' num2str(rel_NDs(i))])
    response(1,i) = mean(abs(mean(res_table.(['psthND' rel_NDs{i} '_all_ints_data_before'])(:,65:125), 2)));
    response(2,i) = mean(abs(mean(res_table.(['psthND' rel_NDs{i} '_all_ints_data_after'])(:,65:125), 2)));

end
subplot(2,2, 4)
plot(x, response, '-o')
    
legend(["control", "Pupil dilated"],Location="best")
sgtitle('responsive cells')

%% IE cells by cluster plot only high int

temp = cell2mat(both_table.Is_reponsive_and_IR);
IE_cells = find(temp(:,2));
IE_table = both_table(IE_cells,:);
IE_table.cluster = cell2mat(IE_table.cluster);
cluster_names = ["ON-OFF-suppressed", "ON-OFF", "ON-suppressed"];
% split by cluster
G = grpstats(IE_table,"cluster", ["mean","sem"], "DataVars", ["psthND6_all_ints_data_before", "psthND6_all_ints_data_after" ,"psthND1_all_ints_data_before"]);

%% plot mean response PER cluster
f1 = figure;
f1.Position =   [220 130 1190 793];
x = [12.9, 11.4, 9.4];
for i = 1:size(G,1)
    subplot(2,2, i)
    plot(G.mean_psthND6_all_ints_data_before(i,:))
    hold on
        plot(G.mean_psthND1_all_ints_data_before(i,:))

    plot(G.mean_psthND6_all_ints_data_after(i,:))
    title(cluster_names{i})
   
end

legend(["control ND6",  "control ND1","Pupil dilated ND6"],Location="best")

%% all cells;
t.is_enhanced = mean(both_table.psthND1_all_ints_data_before(:,65:125),2) > 0

t = both_table(:,["ND6_all_ints_data_before","ND6_all_ints_data_after","Is_reponsive","Is_reponsive_and_IR","cluster"]);
find_response = @(x) mean(x(65:125,:),"all") - mean(x(1:30,:),"all")
find_mag = @(x) (mean(x(65:125,:),"all") - mean(x(1:30,:),"all"))/mean(x(1:30,:),"all")
t.magnitude = cellfun(@(x) find_mag(x),t{:,1:2});
t.response = cellfun(@(x) find_response(x),t{:,1:2});
t.response(:,1) = mean(both_table.psthND6_all_ints_data_before(:,65:125),2)
t.response(:,2) = mean(both_table.psthND6_all_ints_data_after(:,65:125),2)

t.response(t.is_enhanced,:) =  t.response(t.is_enhanced,:)*-1

f1 = figure
subplot(2,2,1)
bar(mean(abs(t.response),1,"omitnan"))
xticklabels(["control", "Pupil dilated"])
p = mult_comp_perm_t1(t.response(:,1)-t.response(:,2), 100000,-1);
subtitle(['pval = ' num2str(p)])
title('all cells')

% 
temp = cell2mat(t.Is_reponsive);
res_cells = find(temp(:,2));
rest = t(res_cells,:);


subplot(2,2,2)
bar(mean(abs(rest.response),1,"omitnan"))
xticklabels(["control", "Pupil dilated"])
p = mult_comp_perm_t1(rest.response(:,1)-rest.response(:,2), 100000,-1);
subtitle(['pval = ' num2str(p)])
title('responsive cells')


% ie cell
% 
temp = cell2mat(t.Is_reponsive_and_IR);
res_cells = find(temp(:,2));
iet = t(res_cells,:);

subplot(2,2,3)
bar(mean(abs(iet.response),1,"omitnan"))
xticklabels(["control", "Pupil dilated"])
p = mult_comp_perm_t1(iet.response(:,1)-iet.response(:,2), 100000,-1);
subtitle(['pval = ' num2str(p)])
title('IE cells')
%%
iet.cluster= cell2mat(iet.cluster)
g1= grpstats(iet,"cluster","mean",DataVars="response")

%%

savefig(f1,'abs response control vs pupil dilated')