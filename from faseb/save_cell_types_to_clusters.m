expreiments = unique(CTP.experiment_id);
for i = 1:length(expreiments)
    exp_idx = find(contains(upper(clusters.brain_render_table.experiment_name), expreiments{i}));
    exp_CTP = CTP(contains(CTP.experiment_id, expreiments{i}), :);
    for j = 1:length(exp_idx)
        x = find(clusters.brain_render_table.id(exp_idx(j)) == exp_CTP.id);
        if x
           clusters.brain_render_table.cell_type(exp_idx(j)) = exp_CTP.idx(x);
           clusters.brain_render_table.CTP(exp_idx(j)) = {exp_CTP(x, :)};
        end
    end
end
 X =  clusters.brain_render_table;
 clusters.brain_render_table = [clusters.brain_render_table(:, end-1:end) clusters.brain_render_table(:, 1:end-2)]
%%
for i = 1:3
    idx = find(X.cell_type == i);
    cellsnum(i) = length(idx)
    figure
    histogram(X.cluster(idx))
    title(i)
end
%%
y = CTP.idx


%% plot parameters if each cluster

for i = 1:3
    figure
    index = find(CTP.idx == i)
    for j = 1:length(index) 
        norm_wf = CTP.waveforms{index(j)}/max(abs(CTP.waveforms{index(j)}));
        plot(norm_wf)
        hold on
        all_wf(j, :)= norm_wf;
    end
    meanwf(i, :) =  mean(all_wf(j, :),1);
    figure
    plot( meanwf(i, :))
end





