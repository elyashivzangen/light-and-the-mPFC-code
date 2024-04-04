cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\effect size\f2\n')
x = importdata("IE_cells.mat")
%%
x1 = x;
x1 = sortrows(x1,"main_structure")
x1.struct_number = grp2idx(x1.main_structure);
stats = mes1way(x1.response,'eta2','group',x1.struct_number)

%% post hoc
%% IL vs PL
stats = mes(x1.response(x1.struct_number == 3),x1.response(x1.struct_number == 4),'hedgesg')
 d = computeCohen_d(x1.response(x1.struct_number == 3),x1.response(x1.struct_number == 4))
[p, observeddifference, effectsize] =  permutationTest(x1.response(x1.struct_number == 3),x1.response(x1.struct_number == 4),10000)

%%  DP vs TT
stats = mes(x1.response(x1.struct_number == 2),x1.response(x1.struct_number == 5),'hedgesg')
 d = computeCohen_d(x1.response(x1.struct_number == 2),x1.response(x1.struct_number == 5))
[p, observeddifference, effectsize] =  permutationTest(x1.response(x1.struct_number == 2),x1.response(x1.struct_number == 5),10000)
% %%
% [p,tbl,stats] = anova1(IE_cells.response, IE_cells.main_structure);
% savefig('response_IE_cells_box_plot')
% results = multcompare(stats);
% resuls_tbl = array2table(results,"VariableNames", ...
%     ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
% title('IE_cells response')
% savefig('response_IE_cells_multiple_comp')
% save('response_IE_cells_multiple_comp', 'resuls_tbl')