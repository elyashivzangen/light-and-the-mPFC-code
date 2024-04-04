cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\per_mouse\figure_1\1d_PFC_vs_mos')
clear
clc
%%
PFC = importdata("PFC_responsive cells per exp.mat")
MO = importdata("Motor_cortex_responsive cells per exp.mat")

%%
PFC = PFC(1:end-1,:);
PFC.mouse = cellfun(@(x) x(1:6),PFC.file,'UniformOutput',false);
PFC_per_mouse = grpstats(PFC,"mouse",@sum, "DataVars",["total_cell_exp","IR_sugnificant_cells_exps","reponsive_cells_exps"])
PFC_per_mouse.responsive_percent = PFC_per_mouse.sum_reponsive_cells_exps(:,1:2)./PFC_per_mouse.sum_total_cell_exp
PFC_per_mouse.IE_percent = PFC_per_mouse.sum_IR_sugnificant_cells_exps(:,1:2)./PFC_per_mouse.sum_total_cell_exp

MO = MO(1:end-1,:);
MO.mouse = cellfun(@(x) x(1:13),MO.file,'UniformOutput',false);
MO_per_mouse = grpstats(MO,"mouse",@sum, "DataVars",["total_cell_exp","IR_sugnificant_cells_exps","reponsive_cells_exps"])
MO_per_mouse.responsive_percent = MO_per_mouse.sum_reponsive_cells_exps(:,1:2)./MO_per_mouse.sum_total_cell_exp;
MO_per_mouse.IE_percent = MO_per_mouse.sum_IR_sugnificant_cells_exps(:,1:2)./MO_per_mouse.sum_total_cell_exp;

%%
G = grpstats(MO_per_mouse,[],["mean","sem"],"DataVars",["IE_percent","responsive_percent"]);
G.Properties.RowNames = "MOs"
G2 = grpstats(PFC_per_mouse,[],["mean","sem"],"DataVars",["IE_percent","responsive_percent"]);
G2.Properties.RowNames = "PFC"

per_mouse = [G;G2];
save('mean_sem_per_mouse',"per_mouse")
%%
[p.resposive(1), observeddifference, effectsize.responsive(1)] = permutationTest(MO_per_mouse.responsive_percent(:,1), PFC_per_mouse.responsive_percent(:,1),100000);
[p.resposive(2), observeddifference, effectsize.responsive(2)] = permutationTest(MO_per_mouse.responsive_percent(:,2), PFC_per_mouse.responsive_percent(:,2),100000);

[p.IE(1), observeddifference, effectsize.IE(1)] = permutationTest(MO_per_mouse.IE_percent(:,1), PFC_per_mouse.IE_percent(:,1),100000);
[p.IE(2), observeddifference, effectsize.IE(2)] = permutationTest(MO_per_mouse.IE_percent(:,2), PFC_per_mouse.IE_percent(:,2),100000);

save('permutation_pvalue', 'p')
save('effectsize', 'effectsize')













bar()
