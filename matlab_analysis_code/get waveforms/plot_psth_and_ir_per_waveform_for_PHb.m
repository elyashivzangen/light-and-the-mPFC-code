function plot_psth_and_ir_per_waveform_for_PHb(CTP)
%% plot waveforms for easch cluster and celltype

%ints = CTP.ints;
%%
CTP.psth_high_int = cell2mat(cellfun(@(x) x(1).psth.mean, CTP.ints, 'UniformOutput', false));
%% plot psth per waveform
mkdir('cell_type_PSTH')
cd('cell_type_PSTH')
%%
PSTH_per_waveform = grpstats(CTP, "idx", ["mean","sem"],"DataVars","psth_high_int");
PSTH_per_waveform_fig = figure;
set(PSTH_per_waveform_fig, 'color', [1 1 1]);
set(PSTH_per_waveform_fig,'position',[50 200 600 300]);
for i = 1:size(PSTH_per_waveform, 1)
    subplot(1,2,i)
    errorbar(PSTH_per_waveform.mean_psth_high_int(i,:), PSTH_per_waveform.sem_psth_high_int(i,:))
end
save("PSTH_per_waveform", "PSTH_per_waveform")
savefig(PSTH_per_waveform_fig, "PSTH_per_waveform_fig")
exportgraphics(PSTH_per_waveform_fig,'all_figs.pdf','Append',true)
%%
%% PLOT IR 
% calculate_IR
win = 65:125;
ints = CTP.ints;
for i = 1:length(ints)
    c = ints{i};
    count = 0;
    for j = 1:length(c)
        if isempty(c(j).psth)
            continue
        end
        count = count + 1;
        ir(i, count) = mean(c(j).psth.mean(win));
    end
end
CTP.ir = ir;
save('ir', 'ir')
%% plot per cluster per type
PSTH_per_waveform_and_clust = grpstats(CTP(find(CTP.is_responsive_and_ir(:,2)), :), ["cluster", "idx"], ["mean","sem"],"DataVars",["psth_high_int", "ir"]);
PSTH_per_waveform_and_clust_fig = figure;
set(PSTH_per_waveform_and_clust_fig, 'color', [1 1 1]);
set(PSTH_per_waveform_and_clust_fig,'position',[50 50 400 800]);
for i = 1:size(PSTH_per_waveform_and_clust, 1)
    subplot(4,2,((PSTH_per_waveform_and_clust.cluster(i)-1)*2 + PSTH_per_waveform_and_clust.idx(i)))
    errorbar(PSTH_per_waveform_and_clust.mean_psth_high_int(i,:), PSTH_per_waveform_and_clust.sem_psth_high_int(i,:))
    title(PSTH_per_waveform_and_clust.Properties.RowNames{i},'Interpreter','none')
    subtitle(['n = ' num2str(PSTH_per_waveform_and_clust.GroupCount(i))])
end
save("PSTH_per_waveform_and_clust", "PSTH_per_waveform_and_clust")
savefig(PSTH_per_waveform_and_clust_fig, "PSTH_per_waveform_and_clust_fig")
exportgraphics(PSTH_per_waveform_and_clust_fig,'all_figs.pdf','Append',true)
%% plot ir
IR_per_waveform_and_clust_fig = figure;
set(IR_per_waveform_and_clust_fig, 'color', [1 1 1]);
set(IR_per_waveform_and_clust_fig,'position',[50 50 400 800]);
for i = 1:size(PSTH_per_waveform_and_clust, 1)
    subplot(4,2,((PSTH_per_waveform_and_clust.cluster(i)-1)*2 + PSTH_per_waveform_and_clust.idx(i)))
    errorbar(PSTH_per_waveform_and_clust.mean_ir(i,:), PSTH_per_waveform_and_clust.sem_ir(i,:), '-o')
    title(PSTH_per_waveform_and_clust.Properties.RowNames{i})
    subtitle(['n = ' num2str(PSTH_per_waveform_and_clust.GroupCount(i))])
end
savefig(PSTH_per_waveform_and_clust_fig, "IR_per_waveform_and_clust_fig")
exportgraphics(IR_per_waveform_and_clust_fig,'all_figs.pdf','Append',true)


%%
PSTH_per_waveform_and_clust_fig2 = figure;
set(PSTH_per_waveform_and_clust_fig2, 'color', [1 1 1]);
set(PSTH_per_waveform_and_clust_fig2,'position',[50 200 1200 300]);
count = 0;
for i = 1:4
    subplot(1,4,i)
    plot(PSTH_per_waveform_and_clust.mean_psth_high_int(find(PSTH_per_waveform_and_clust.cluster == i & PSTH_per_waveform_and_clust.idx == 1),:), 'b')
    hold on
    plot(PSTH_per_waveform_and_clust.mean_psth_high_int(find(PSTH_per_waveform_and_clust.cluster == i & PSTH_per_waveform_and_clust.idx == 2),:), 'r')
    title(num2str(PSTH_per_waveform_and_clust.cluster(i)))
end
legend(["FS", "RS"])
savefig(PSTH_per_waveform_and_clust_fig2, "PSTH_per_waveform_and_clust_fig2")
exportgraphics(PSTH_per_waveform_and_clust_fig2,'all_figs.pdf','Append',true)
%%
IR_per_waveform_and_clust_fig2 = figure;
set(IR_per_waveform_and_clust_fig2, 'color', [1 1 1]);
set(IR_per_waveform_and_clust_fig2,'position',[50 200 1200 300]);
count = 0;
for i = 1:4
    subplot(1,4,i)
    plot(PSTH_per_waveform_and_clust.mean_ir(find(PSTH_per_waveform_and_clust.cluster == i & PSTH_per_waveform_and_clust.idx == 1),:),  '-o', 'Color','b')
    
        hold on
    plot(PSTH_per_waveform_and_clust.mean_ir(find(PSTH_per_waveform_and_clust.cluster == i & PSTH_per_waveform_and_clust.idx == 2),:),  '-o', 'Color','r')
    
    title(num2str(PSTH_per_waveform_and_clust.cluster(i)))
end
legend(["FS", "RS"])

savefig(IR_per_waveform_and_clust_fig2, "IR_per_waveform_and_clust_fig2")
exportgraphics(IR_per_waveform_and_clust_fig2,'all_figs.pdf','Append',true)
%%
PSTH_per_waveform_and_clust_fig3 = figure;
set(PSTH_per_waveform_and_clust_fig3, 'color', [1 1 1]);
set(PSTH_per_waveform_and_clust_fig3,'position',[50 200 1200 300]);
count = 0;
for i = 1:4
    subplot(1,4,i)
    errorbar(PSTH_per_waveform_and_clust.mean_psth_high_int(find(PSTH_per_waveform_and_clust.cluster == i & PSTH_per_waveform_and_clust.idx == 1),:),PSTH_per_waveform_and_clust.sem_psth_high_int(find(PSTH_per_waveform_and_clust.cluster == i & PSTH_per_waveform_and_clust.idx == 1),:), 'b')
        hold on
        errorbar(PSTH_per_waveform_and_clust.mean_psth_high_int(find(PSTH_per_waveform_and_clust.cluster == i & PSTH_per_waveform_and_clust.idx == 2),:),PSTH_per_waveform_and_clust.sem_psth_high_int(find(PSTH_per_waveform_and_clust.cluster == i & PSTH_per_waveform_and_clust.idx == 2),:), 'r')
    title(num2str(PSTH_per_waveform_and_clust.cluster(i)))
end
legend(["FS", "RS"])

savefig(PSTH_per_waveform_and_clust_fig3, "PSTH_per_waveform_and_clust_fig2")
exportgraphics(PSTH_per_waveform_and_clust_fig3,'all_figs.pdf','Append',true)
%%
save("CTP_with_psth", "CTP")
IR_CTP = CTP(find(CTP.is_responsive_and_ir(:,2)), :);
save("IR_CTP_with_psth", "CTP")


waveforms_per_cluster = figure;
set(waveforms_per_cluster, 'color', [1 1 1]);
set(waveforms_per_cluster,'position',[50 200 1200 300]);
for i = 1:4
    rel_CTP = IR_CTP(find(IR_CTP.cluster == i), ["norm_waveforms", "idx"]);
    RS = rel_CTP.norm_waveforms(rel_CTP.idx == 1, :)';
    FS = rel_CTP.norm_waveforms(rel_CTP.idx == 2, :)';
    subplot(1,4,i)
    plot(RS, 'b')
    hold on
    plot(FS, 'r')
    xlim([50 150])
end
savefig(waveforms_per_cluster, "waveforms_per_cluster")
exportgraphics(waveforms_per_cluster,'all_figs.pdf','Append',true)

cd ..
end