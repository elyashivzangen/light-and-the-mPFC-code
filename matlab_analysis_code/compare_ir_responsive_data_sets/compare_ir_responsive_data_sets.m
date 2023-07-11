%% compare number of responsive cells per exp in 2 data sets
clear
clc


%load responsive cells per exp (output of calculate IR responsive from data
%set 1 (PFC)
[PFC_file, path] = uigetfile('PFC_responsive cells per exp.mat');
cd(path)
X1  = load(PFC_file);
X1 = X1.responsvie_and_ie_table;
%load responsive cells per exp (output of calculate IR responsive from data
%set 1 (motor cortex)
[Motor_file, path] = uigetfile('Motor_cortex_responsive cells per exp.mat');
cd(path)
X2 = load(Motor_file);
X2 = X2.responsvie_and_ie_table2;

windows = ["early_responsive", "steady_responsive", "off_responsive", "early_ir", "steady_ir", "off_ir"];


%% transform tables to percentages Table
PFC = X1{1:end-1,3:end}./X1.total_cell_exp(1:end-1);
if istable(X2.reponsive_cells_expsT)
    X2.reponsive_cells_expsT = table2array(X2.reponsive_cells_expsT);
    X2.IR_sugnificant_cells_expsT = table2array(X2.IR_sugnificant_cells_expsT);
end

MOTOR = X2{1:end-1, 3:end}./X2.total_cell_exp(1:end-1);
for i = 1:size(MOTOR,2)
    [p(i), observeddifference(i), effectsize(i)]=permutationTest(PFC(:,i), MOTOR(:,i), 10000, sidedness = 'larger');
end

T = array2table([p;observeddifference;effectsize;X1{end,3:end}; X2{end,3:end} ] ,VariableNames=windows, RowNames=["pval", "effectsize","observeddifference","PFC_TOTAL", "MOTOR_CORTEX_TOTAL"  ]);
save("PFC_vs_motor", "T")
writetable(T,"PFC_vs_motor.csv", "WriteRowNames",true )


