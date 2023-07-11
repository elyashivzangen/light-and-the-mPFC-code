for i = 1:5
    index(i) = sum(all_clusters_idx == i)
    
end
%%
all_idx = [];
for i = 1:3
    all_idx = [all_idx; idx{i}]
end
%%
for i = 1:5
    subplot(1, 5, i)
    plot(mean(cell2mat(data(all_idx(all_clusters_idx == i), 5:end)), 1))
    ylim([-2 6])
end
    