%% load and prepare the data
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\DREEDDS_VS_CONTROL_PHb\new_IR_calculations')
load("all_cells_before_after_fit_parameters_control.mat")
load("all_cells_before_after_fit_parameters_DREEDDS.mat")
dreadds_all = importdata("all_cells_PHb_DREADD.mat");
control_all = importdata("all_cells_control.mat");
%%
nan_cells = find(cellfun(@(x) isempty(x), dreadds_all{1}.Is_reponsive));

dreadds_all{1}.Is_reponsive(nan_cells) = {[0, 0,0]};
dreadds_all{1}.Is_reponsive_and_IR(nan_cells) = {[0, 0,0]};

% dreadds_all{2}(nan_cells,:) = [];
% all_cells_before_after_fit_parameters_DREEDDS{1}(nan_cells,:) = [];
% all_cells_before_after_fit_parameters_DREEDDS{2}(nan_cells,:) = [];
%% add fit parameters table

dreadds_all{1} = [dreadds_all{1} all_cells_before_after_fit_parameters_DREEDDS{1}];
dreadds_all{2} = [dreadds_all{2} all_cells_before_after_fit_parameters_DREEDDS{2}];

control_all{1} = [control_all{1} all_cells_before_after_fit_parameters_control{1}];
control_all{2} = [control_all{2} all_cells_before_after_fit_parameters_control{2}];
%% add cell idx
dreadds_all{1}.cell_idx = (1:length(dreadds_all{1}.DNR))';
dreadds_all{2}.cell_idx = (1:length(dreadds_all{2}.DNR))';

control_all{1}.cell_idx = ((1:length(control_all{2}.DNR)) + length(dreadds_all{2}.DNR))';
control_all{2}.cell_idx = ((1:length(control_all{2}.DNR)) + length(dreadds_all{2}.DNR))';


%% responsive cell
responsive_cell = cellfun(@(x) x(2), control_all{1}.Is_reponsive);
responsive_cell = find((responsive_cell));
control_responsive{1} = control_all{1}(responsive_cell,:);
control_responsive{2} =control_all{2}(responsive_cell,:);




responsive_cell = cellfun(@(x) x(2), dreadds_all{1}.Is_reponsive);
responsive_cell = find(responsive_cell);
dreadds_responsive{1} = dreadds_all{1}(responsive_cell,:);
dreadds_responsive{2} =dreadds_all{2}(responsive_cell,:);


%% IE cells
responsive_cell = cellfun(@(x) x(2), control_all{1}.Is_reponsive_and_IR);
responsive_cell = find((responsive_cell));
control_IE{1} = control_all{1}(responsive_cell,:);
control_IE{2} =control_all{2}(responsive_cell,:);

responsive_cell = cellfun(@(x) x(2), dreadds_all{1}.Is_reponsive_and_IR);
responsive_cell = find((responsive_cell));
dreadds_IE{1} = dreadds_all{1}(responsive_cell,:);
dreadds_IE{2} =dreadds_all{2}(responsive_cell,:);
%% use function
%% all cells
mkdir('all_cells')
cd('all_cells')
plot_all_kindes(dreadds_all, control_all)
cd .. 
%%
%% responsive cells
mkdir('responsive cells')
cd('responsive cells')
plot_all_kindes(dreadds_responsive, control_responsive)
cd .. 
%%
%% IE cells
mkdir('IE cells')
cd('IE cells')
plot_all_kindes(dreadds_IE, control_IE)
cd .. 
%%




function plot_all_kindes(dreadds_rel, control_rel)
%% prepare the data
 [dreadds.before, dreadds.after] = plot_magnitude_before_and_after_from_all_cells(dreadds_rel, 'dreadds_all_cells', 0);
 [control.before, control.after] = plot_magnitude_before_and_after_from_all_cells(control_rel, 'control_all_cells', 0);
dreadds.before.Properties.RowNames = {};
dreadds.after.Properties.RowNames = {};
control.before.Properties.RowNames = {};
control.after.Properties.RowNames = {};
%% create a joint table
T = [dreadds.before(:,["magnitude","baseline_vector","response","Is_reponsive_and_IR","Is_reponsive","zscore","n","DNR","rsquare", "rmse" ,"cell_idx"]);
    dreadds.after(:,["magnitude","baseline_vector","response","Is_reponsive_and_IR","Is_reponsive","zscore","n","DNR","rsquare", "rmse", "cell_idx"]);
    control.before(:,["magnitude","baseline_vector","response","Is_reponsive_and_IR","Is_reponsive","zscore","n","DNR","rsquare", "rmse", "cell_idx"]);
    control.after(:,["magnitude","baseline_vector","response","Is_reponsive_and_IR","Is_reponsive","zscore","n","DNR","rsquare", "rmse", "cell_idx"])];
T.tags = [repmat("dreadds before", size(dreadds.before, 1),1);
       repmat("dreadds after", size(dreadds.after, 1),1);
       repmat("control before", size(control.before, 1),1);
       repmat("control after", size(control.after, 1),1)];
T.magnitude = cell2mat(T.magnitude);
T.zscore = cell2mat(T.zscore);
T.response = cell2mat(T.response);
T.Is_reponsive_and_IR = cell2mat(T.Is_reponsive_and_IR);
T.Is_reponsive = cell2mat(T.Is_reponsive);


mean_sem_parameters_for_all_4_groups = grpstats(T,"tags",["mean", "sem"],"DataVars",["magnitude", "response", "zscore", "Is_reponsive_and_IR", "Is_reponsive","n","DNR","rsquare"]);

save('mean_sem_parameters_for_all_4_groups', 'mean_sem_parameters_for_all_4_groups')
save('raw data table', 'T')

%% plot all cells together
colors = ["c", "r"	, "y", "m"];


x = [15.4000000000000;14.9000000000000;14.4000000000000;13.9000000000000;12.9000000000000;11.4000000000000;9.40000000000000];
f1 = figure;
f1.Position = [680 139 1104 839];
subplot(2,2,1)
plot(flip(x), mean(cell2mat(dreadds.before.response)), '-o')
hold on
plot(flip(x), mean(cell2mat(dreadds.after.response)), '-o')
plot(flip(x), mean(cell2mat(control.before.response)), '-o')
plot(flip(x), mean(cell2mat(control.after.response)), '-o')
% legend(["dreadds before", "dreadds after", "control before", "control after"])
title('response')


subplot(2,2,2)
plot(flip(x), mean(cell2mat(dreadds.before.zscore),"omitnan"), '-o')
hold on
plot(flip(x), mean(cell2mat(dreadds.after.zscore),"omitnan"), '-o')
plot(flip(x), mean(cell2mat(control.before.zscore),"omitnan"), '-o')
plot(flip(x), mean(cell2mat(control.after.zscore),"omitnan"), '-o')
% legend(["dreadds before", "dreadds after", "control before", "control after"])
title('zscore')


fulltitle = [];
names = ["dreadds before", "dreadds after", "control before", "control after"];
for i = 1:4
    y = mean_sem_parameters_for_all_4_groups.mean_response(i,:)
   fo = fitoptions('Method','NonlinearLeastSquares',...
                'Algorithm','Trust-Region',...
                'Display','final',...
                'TolFun',1.0E-20,...
                'TolX',1.0E-20,...
                'Lower',[-1,min(x),-5],...
                'Upper',[2*max(y),max(x),5],...
                'StartPoint',[max(y),mean(x),0]);

            ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
            [curve1,gof1]=fit(flip(x),y',ft);
                subplot(2,2,4)
                hold on;
                plot(flip(x),y,'o', Color=colors{i});
                plot(curve1,colors{i});
                legend("off")
                fulltitle{i} = [names{i} ':  rmse = ',num2str(gof1.rmse),'   n = ',num2str(curve1.n), '  r2 = ', num2str(gof1.rsquare)];
end
title(fulltitle);

subplot(2,2,3)
plot(flip(x), mean(cell2mat(dreadds.before.magnitude),"omitnan"), '-o')
hold on
plot(flip(x), mean(cell2mat(dreadds.after.magnitude),"omitnan"), '-o')
plot(flip(x), mean(cell2mat(control.before.magnitude),"omitnan"), '-o')
plot(flip(x), mean(cell2mat(control.after.magnitude),"omitnan"), '-o')
lgd  = legend(["dreadds before", "dreadds after", "control before", "control after"]);
lgd.Position = [0.4414 0.4682 0.1196 0.0828];
title('magnitude')
savefig(f1, 'IR curves 4 together')

%% calcualte stats
[p,tbl,stats] = anova1(T.n, T.tags)
results = multcompare(stats);

%% calcualte stats
[p,tbl,stats] = anova1(T.DNR, T.tags)
results = multcompare(stats);

[p,tbl,stats] = anova1(T.rsquare, T.tags)
results = multcompare(stats);

[p,tbl,stats] = anova1(T.magnitude(:,7), T.tags)
results = multcompare(stats);






end


%% magnitude response
function [before, after] = plot_magnitude_before_and_after_from_all_cells(all_cells, name,ploting)
before = all_cells{1};
bad_cells = cellfun(@(x)  length(x) == 8 ,before.intensities);
bad_cells = find(bad_cells);
before(bad_cells, :) = [];

after = all_cells{2};
after(bad_cells, :) = [];

before_ints = before.intensities;
after_ints = after.intensities;

[before.response, before.zscore, before.magnitude] = cellfun(@(x) calaulate_magnitude_from_singal_cell_intensties(x,2), before_ints, UniformOutput=false);
[after.response, after.zscore, after.magnitude] = cellfun(@(x) calaulate_magnitude_from_singal_cell_intensties(x,2 ), after_ints, UniformOutput=false);
%%
% T2res_before = T2res(contains(T2res.file_name, 'before'),:);
% before_ints = T2res_before.intensities;
% [response, zscore, magnitude] = cellfun(@(x) calaulate_magnitude_from_singal_cell_intensties(x,2 ),before_ints , UniformOutput=false);
%  plot(mean(cell2mat(before.magnitude)),'-o')
%%


% plot 
if ploting
x = [15.4000000000000;14.9000000000000;14.4000000000000;13.9000000000000;12.9000000000000;11.4000000000000;9.40000000000000];
f1 = figure;
f1.Position = [680 139 1104 839];
subplot(2,2,1)
plot(flip(x), mean(cell2mat(before.response)), '-o')
hold on
plot(flip(x), mean(cell2mat(after.response)), '-o')
title('response')



subplot(2,2,2)
plot(flip(x), mean(cell2mat(before.zscore), "omitnan"), '-o')
hold on
plot(flip(x), mean(cell2mat(after.zscore), "omitnan"), '-o')
title('zscore')


subplot(2,2,3)
plot(flip(x), mean(cell2mat(before.magnitude), "omitnan"), '-o')
hold on
plot(flip(x), mean(cell2mat(after.magnitude), "omitnan"), '-o')
title('magnitude')

save([name '_before'],'before')
save([name '_after'],'after')

savefig(f1, [name 'before_and_after_IR_curves'])
end

end