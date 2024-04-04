%% sides per session ttest
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\figure1_stats\TTEST_SIDES')

load("all_cells_sides_and_sessions.mat")

%%
G1 = grpstats(T,["sessions","side"],"mean","DataVars",["is_ir","is_responsive"]);
R = G1{find(contains(G1.side,'R')), ["mean_is_responsive","mean_is_ir"]};
L = G1{find(contains(G1.side,'L')), ["mean_is_responsive","mean_is_ir"]};

[prem_pval, t_orig, crit_t]=mult_comp_perm_t2(R, L, 10000, 0);
[h, pval] = ttest2(L,R);
for i = 1:4
    [~, pavl(i)] = ttest2(L(:,i),R(:,i) )
end

save('premutation_pval', "prem_pval")
save('ttest2_pval', "pval")
save('side_per_session_data', "G1")


G2 = grpstats(G1,"side",["mean","sem"],"DataVars",["mean_is_ir","mean_is_responsive"]);

save('mean_side_per_session_data', "G2")

f1 = figrue

subplot(2,2,1)
bar(categorical(G2.side),G2.mean_mean_is_responsive(:,1))
title('transient responsive')
subtitle(['pval:  ' num2str(prem_pval(1))])

subplot(2,2,2)
bar(categorical(G2.side),G2.mean_mean_is_responsive(:,2))
title('sustained responsive')
subtitle(['pval:  ' num2str(prem_pval(2))])


subplot(2,2,3)
bar(categorical(G2.side),G2.mean_mean_is_ir(:,1))
title('transient IE')
subtitle(['pval:  ' num2str(prem_pval(3))])

subplot(2,2,4)
bar(categorical(G2.side),G2.mean_mean_is_ir(:,2))
title('sustained IE')
subtitle(['pval:  ' num2str(prem_pval(4))])


