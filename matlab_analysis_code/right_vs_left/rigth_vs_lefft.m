%% IR+responsive left_vs_right
L_T = T(T.side == "Left","cluster");
L = groupcounts(L_T, "cluster");
L.GroupCount(4) = sum(L.GroupCount);
clusters_text = ["early+stedy"; "early"; "steady"; "total"];
L.cluster = clusters_text;

R_T = T(T.side == "Right","cluster");
R = groupcounts(R_T, "cluster");
R.GroupCount(4) = sum(R.GroupCount);
R.cluster = clusters_text;


T2 = table(L.GroupCount, R.GroupCount , 'RowNames',clusters_text, 'VariableNames',["Right", "Left"]);

writetable(T2, 'left_VS_right_early_and_steady.csv','WriteRowNames', true)
%%
x = table2array(T2);
bar(flip(categorical(T2.Row(1:3))), flip(x(1:3, :)))
legend({'left', 'right'}, 'Location','northeast')
