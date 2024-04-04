%% eopn3 vs control per mouse
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\per_mouse\f4h')
clear
clc
control = importdata('responsive cells per exp_control.mat');
eopn3 = importdata('responsive cells per exp_eopn3.mat');
%%
T  =table()
T.responsive = [control.reponsive_cells_expsT{1:end-1,2};eopn3.reponsive_cells_expsT{1:end-1,2}];
T.IE = [control.IR_sugnificant_cells_expsT{1:end-1,2};eopn3.IR_sugnificant_cells_expsT{1:end-1,2}];
T.group = [zeros(size(control,1)-1,1); ones(size(eopn3,1)-1,1) ]
T.total_cell_exp = [control.total_cell_exp(1:end-1);eopn3.total_cell_exp(1:end-1)];
T.session = [control.file(1:end-1);eopn3.file(1:end-1)];
for i = 1:length(T.session)
    d{i,1} = split(T.session(i),'_')
    mouse(i,1) = d{i,1}(1) + '_' + d{i,1}(2)
end
T.mouse = mouse;
%%
tm = grpstats(T,"mouse",@sum,"DataVars",["responsive","IE","group","total_cell_exp"]);
tm.responsive_percent = tm.sum_responsive./tm.sum_total_cell_exp;
tm.IE_percent = tm.sum_IE./tm.sum_total_cell_exp;
tm.is_control = tm.sum_group == 0 
mean_sem_control_vs_eopn3_per_mouse = grpstats(tm,"is_control",["mean","sem"], "DataVars",["IE_percent","responsive_percent"])
save("mean_sem_control_vs_eopn3_per_mouse", "mean_sem_control_vs_eopn3_per_mouse")

%%
[p.responsive, ~, effectsize.responsive] = permutationTest(tm.responsive_percent(tm.is_control),tm.responsive_percent(find(~tm.is_control)),100000);
[p.IE, ~, effectsize.IE] = permutationTest(tm.IE_percent(tm.is_control),tm.IE_percent(find(~tm.is_control)),100000)
save("permutation_p_value", "p")
save("effectsize", "effectsize")