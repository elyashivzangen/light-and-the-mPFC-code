cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\effect size\f6\c')
x = importdata("responsive_with_response_parameters_and_tags.mat")
%%
x1 = sortrows(x,"tag")
x1 = x1(find(~isnan(x1.magnitude)),:)
x1.struct_number = grp2idx(x1.tag);

stats = mes1way(x1.magnitude,'eta2','group',x1.struct_number)

%% post hoc
%% dreadds vs cno
stats = mes(x1.magnitude(x1.struct_number == 1),x1.magnitude(x1.struct_number == 2),'hedgesg')
 d = computeCohen_d(x1.magnitude(x1.struct_number == 1),x1.magnitude(x1.struct_number == 2))
[p, observeddifference, effectsize] =  permutationTest(x1.magnitude(x1.struct_number == 1),x1.magnitude(x1.struct_number == 2),10000)

% %%  DP vs TT
% stats = mes(x1.response(x1.struct_number == 2),x1.response(x1.struct_number == 5),'hedgesg')
%  d = computeCohen_d(x1.response(x1.struct_number == 2),x1.response(x1.struct_number == 5))
% [p, observeddifference, effectsize] =  permutationTest(x1.response(x1.struct_number == 2),x1.response(x1.struct_number == 5),10000)

%% dreadds vs cno
stats = mes(x1.magnitude(x1.struct_number == 1),x1.magnitude(x1.struct_number == 3),'hedgesg')
stats = mes(x1.magnitude(x1.struct_number == 3),x1.magnitude(x1.struct_number == 4),'hedgesg')
stats = mes(x1.magnitude(x1.struct_number == 2),x1.magnitude(x1.struct_number == 3),'hedgesg')
stats = mes(x1.magnitude(x1.struct_number == 2),x1.magnitude(x1.struct_number == 4),'hedgesg')
stats = mes(x1.magnitude(x1.struct_number == 1),x1.magnitude(x1.struct_number == 4),'hedgesg')
