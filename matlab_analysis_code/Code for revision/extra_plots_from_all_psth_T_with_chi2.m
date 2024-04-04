%% layer and cell types per cluster form all_psthT
clc
clear
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\figure5_S_layers')
load('all_cells_PSTH.mat')
%% pool ACd ACv, 6a 6b
change_position_name = all_psthT.position;
AC_names = find(contains(change_position_name, 'ACA'));
change_position_name(find(contains(change_position_name, '6'))) = cellfun(@(x) x(1:end-1), change_position_name(find(contains(change_position_name, '6'))), 'UniformOutput', false);
change_position_name(AC_names) = cellfun(@(x) x([1:3 find(ismember(x,'12/3456'))]), change_position_name(AC_names), 'UniformOutput',false);
all_psthT.changed_position_name = change_position_name;
all_psthT.is_responsive_sustanied = all_psthT.is_responsive(:,2);
all_psthT.is_ir_sustanied = all_psthT.is_ir(:,2);
all_psthT(find(contains( all_psthT.position, "root")), :) = [];
all_psthT(find(contains( all_psthT.position, "OLF")), :) = [];
all_psthT(find(contains( all_psthT.position, "cing")), :) = [];
all_psthT.layers = cellfun(@(x) x(ismember(x, '12/356')),all_psthT.changed_position_name, "UniformOutput",false);


%% percent responsive from each layer
total_layers = grpstats(all_psthT, "layers","mean","DataVars", ["is_responsive_sustanied", "is_ir_sustanied"] );
total_layers.layer_recorded_percent = total_layers.GroupCount/sum(total_layers.GroupCount);
% suppressed vs enhanced
all_psthT.ir = mean(all_psthT.nd1(:, 65:125), 2);
all_psthT.enhanced = all_psthT.ir > 0;
all_psthT.suppressed = all_psthT.ir < 0;
all_psthT.clusters_enhnced = ismember(all_psthT.cluster, [2,4]);
T = all_psthT(find(ismember(all_psthT.main_structure, ["AC", "IL", "PL"])), :);
ir_cells = all_psthT(find(T.is_ir(:,2)),:);
res_cells = all_psthT(find(T.is_responsive(:,2)),:);
%% SAVE ONLY LAYERS DATA FILES
mkdir("DATA FILES")
cd("DATA FILES")
save('all_cells', 'T')
save('res_cells', 'res_cells')
save('ir_cells', 'ir_cells')
cd .. 
%% Is responsive
mkdir("c - light responsive")
cd("c - light responsive")

[transient.table, ~, transient.pval, lables] = crosstab(T.is_responsive(:,1), T.main_structure);
[sustained.table, ~, sustained.pval,lables] = crosstab(T.is_responsive(:,2), T.main_structure);

f1 = figure;
f1.Position = [379 330 1227 648];

subplot(1,2,1)
bar(categorical(lables(:,2)), transient.table(2, :)./sum(transient.table))
title('transient')
subtitle(['pval: ' num2str(transient.pval)])


subplot(1,2,2)
bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])

sgtitle('all reagions')

save('transient_data', 'transient')
save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd ..









%% responsive Cells suppressed vs enhanced
enhanced_vs_suprressed_per_layer = grpstats(res_cells, "changed_position_name", "mean", "DataVars",["enhanced", "suppressed"]);
enhanced_vs_suprressed_per_layer = sortrows(enhanced_vs_suprressed_per_layer);
enhanced_vs_suprressed_per_layer.enhanced_minus_suprressed = enhanced_vs_suprressed_per_layer.mean_enhanced - enhanced_vs_suprressed_per_layer.mean_suppressed
f1 = figure;
bar(categorical(enhanced_vs_suprressed_per_layer.changed_position_name), enhanced_vs_suprressed_per_layer.enhanced_minus_suprressed)
text((1:length(enhanced_vs_suprressed_per_layer.enhanced_minus_suprressed))'- 0.6,enhanced_vs_suprressed_per_layer.enhanced_minus_suprressed , num2str(enhanced_vs_suprressed_per_layer.GroupCount), "FontSize",14)
title("responsive cells %enhaced - %Suppressed")
% save('responsive_enhanced_vs_suprressed_per_layer', "enhanced_vs_suprressed_per_layer")
% savefig(f1,'responsive_enhanced_vs_suprressed_per_layer')
% exportgraphics(f1, 'allfigs.pdf', 'Append',true)
%% ir Cells suppressed vs enhanced
enhanced_vs_suprressed_per_layer = grpstats(ir_cells, "changed_position_name", "mean", "DataVars",["enhanced", "suppressed"]);
enhanced_vs_suprressed_per_layer = sortrows(enhanced_vs_suprressed_per_layer);
enhanced_vs_suprressed_per_layer.enhanced_minus_suprressed = enhanced_vs_suprressed_per_layer.mean_enhanced - enhanced_vs_suprressed_per_layer.mean_suppressed;
f1 = figure;
bar(categorical(enhanced_vs_suprressed_per_layer.changed_position_name), enhanced_vs_suprressed_per_layer.enhanced_minus_suprressed)
text((1:length(enhanced_vs_suprressed_per_layer.enhanced_minus_suprressed))'- 0.6,enhanced_vs_suprressed_per_layer.enhanced_minus_suprressed , num2str(enhanced_vs_suprressed_per_layer.GroupCount), "FontSize",14)
title("ir cells %enhaced - %Suppressed")
save('ir_enhanced_vs_suprressed_per_layer', "enhanced_vs_suprressed_per_layer")
savefig(f1,'ir_enhanced_vs_suprressed_per_layer')
exportgraphics(f1, 'allfigs.pdf', 'Append',true)
%% ir cells by cluster
main_erias = ["AC", "PL", "IL"];

for i = 1:length(main_erias)
    rel_cells = ir_cells(find(contains(ir_cells.main_structure, main_erias{i})), ["layers", "cluster"]);
    rel_cells.ON_OFF_Suppressed = rel_cells.cluster == 1;
    rel_cells.ON_OFF_enhanced = rel_cells.cluster == 2;
    rel_cells.ON_Suppressed = rel_cells.cluster == 3;
    rel_cells.ON_enhanced = rel_cells.cluster == 4;
    cluster_per_layer = grpstats(rel_cells, "layers", "mean","DataVars",["ON_OFF_Suppressed", "ON_OFF_enhanced","ON_Suppressed","ON_enhanced"] );
    cluster_per_layer = sortrows(cluster_per_layer);
    save([main_erias{i} ' clusters per layer'], "cluster_per_layer")
    f2 = figure;
    f2.Position = [100 100 1500 800];
    bar(categorical(cluster_per_layer.layers), cluster_per_layer{:, 3:end})
    legend(rel_cells.Properties.VariableNames{3:end}, 'Interpreter','none')
    text((1:size(cluster_per_layer,1)), max(cluster_per_layer{:, 3:end}'), num2str(cluster_per_layer.GroupCount),'FontSize',16)
    title([main_erias{i} ' clusters per layer'])
    savefig(f2, [main_erias{i} ' clusters per layer'])
    exportgraphics(f2, 'allfigs.pdf', 'Append',true)
end

%% 2/3 IL
G1 = grpstats(T,"changed_position_name",["sum","mean"],"DataVars",["is_responsive_sustanied","is_ir_sustanied"])
G2 = grpstats(T,"changed_position_name","mean","DataVars",["is_responsive_sustanied","is_ir_sustanied"])

