cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\per_mouse\figure_1\1i')
T = importdata("side_per_session_data.mat")
%%
T.mouse = cellfun(@(x) x(1:6), T.sessions,UniformOutput=false);
T.res_n = T.GroupCount.*T.mean_is_responsive
T.IE_n = T.GroupCount.*T.mean_is_ir

Tm = grpstats(T,["mouse","side"],@sum,"DataVars",["GroupCount","res_n","IE_n"])
Tm.responsive = Tm.sum_res_n./Tm.sum_GroupCount;
Tm.IE = Tm.sum_IE_n./Tm.sum_GroupCount;



[p.responsive(1),~, effect_size.responsive(1)]  =  permutationTest(Tm.responsive(ismember(Tm.side,'R'),1),Tm.responsive(ismember(Tm.side,'L'),1),100000)
[p.responsive(2),~, effect_size.responsive(2)]  =  permutationTest(Tm.responsive(ismember(Tm.side,'R'),2),Tm.responsive(ismember(Tm.side,'L'),2),100000)
[p.IE(1),~, effect_size.IE(1)]  =  permutationTest(Tm.IE(ismember(Tm.side,'R'),1),Tm.IE(ismember(Tm.side,'L'),1),100000)

[p.IE(2),~, effect_size.IE(2)]  =  permutationTest(Tm.IE(ismember(Tm.side,'R'),2),Tm.IE(ismember(Tm.side,'L'),2),100000)

save('permutation_p_value', 'p')
save('effect_size', 'effect_size')

%%
sides_mean_sem_per_mouse = grpstats(Tm,"side",["mean","sem"],"DataVars",["responsive","IE"]);
save('sides_mean_sem_per_mouse', 'sides_mean_sem_per_mouse')