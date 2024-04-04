cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\effect size\f4\h')

control = importdata('responsive cells per exp_control.mat');
eopn3 = importdata('responsive cells per exp_eopn3.mat');
%%
responsive = [control.reponsive_cells_expsT{:,2};eopn3.reponsive_cells_expsT{:,2}];
IE = [control.IR_sugnificant_cells_expsT{:,2};eopn3.IR_sugnificant_cells_expsT{:,2}];
group = [zeros(size(control,1)-1,1); ones(size(eopn3,1)-1,1) ]

stats = mes(control.reponsive_cells_expsT{:,2},eopn3.reponsive_cells_expsT{:,2},'hedgesg')
 d = computeCohen_d(control.reponsive_cells_expsT{:,2},eopn3.reponsive_cells_expsT{:,2})
[p, observeddifference, effectsize] =  permutationTest(control.reponsive_cells_expsT{:,2},eopn3.reponsive_cells_expsT{:,2},10000)


stats = mes(control.IR_sugnificant_cells_expsT{:,2},eopn3.IR_sugnificant_cells_expsT{:,2},'hedgesg')
 d = computeCohen_d(control.reponsive_cells_expsT{:,2},eopn3.reponsive_cells_expsT{:,2})
[p, observeddifference, effectsize] =  permutationTest(control.reponsive_cells_expsT{:,2},eopn3.reponsive_cells_expsT{:,2},10000)
