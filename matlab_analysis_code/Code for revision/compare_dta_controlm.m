%% compare number of responsive cells per exp in 2 data sets
clear
clc


%load responsive cells per exp (output of calculate IR responsive from data
%set 1 (PFC)
[PFC_file, path] = uigetfile('C57 cells per exp.mat');
cd(path)
X1  = load(PFC_file);
X1 = X1.responsvie_and_ie_table2;
%load responsive cells per exp (output of calculate IR responsive from data
%set 1 (motor cortex)
[DTA_file, path] = uigetfile('DTA cells per exp.mat');
cd(path)
X2 = load(DTA_file);
X2 = X2.responsvie_and_ie_table2;
names = X2.Properties.VariableNames;

X2.reponsive_cells_exps = table2array(X2.reponsive_cells_expsT);
X2.reponsive_cells_expsT = [];
X2.IR_sugnificant_cells_exps = table2array(X2.IR_sugnificant_cells_expsT);
X2.IR_sugnificant_cells_expsT = [];


X1.reponsive_cells_exps = table2array(X1.reponsive_cells_expsT);
X1.reponsive_cells_expsT = [];
X1.IR_sugnificant_cells_exps = table2array(X1.IR_sugnificant_cells_expsT);
X1.IR_sugnificant_cells_expsT = [];


windows = ["early_responsive", "steady_responsive", "off_responsive", "early_ir", "steady_ir", "off_ir"];


%% transform tables to percentages Table
% cd("compare_DTA_c57")
PFC = X1{1:end-1,3:end}./X1.total_cell_exp(1:end-1);
DTA = X2{1:end-1, 3:end}./X2.total_cell_exp(1:end-1);
for i = 1:size(DTA,2)
    [p(i), observeddifference(i), effectsize(i)]= mult_comp_perm_t2(PFC(:,i), DTA(:,i), 10000,1);
end

T = array2table([p;observeddifference;effectsize;X1{end,3:end}; X2{end,3:end} ] ,VariableNames=windows, RowNames=["pval", "effectsize","observeddifference","PFC_TOTAL", "MOTOR_CORTEX_TOTAL"  ]);
save("DTA_vs_C57", "T")
writetable(T,"DTA_vs_C57.csv", "WriteRowNames",true )

total_PFC = X1{end,2:end}';
total_DTA = X2{end,2:end}';
total = table(total_PFC, total_DTA, RowNames=["total", "early_responsive","steady_responsive","OFF_responsive", "early_responsive_ir","steady_responsive_ir","OFF_responsive_ir"]);
save("compare_dta_c57_total", "total")
writetable(total,"compare_dta_c57_total.csv", "WriteRowNames",true )

