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


T_all = T;

ir_cells = all_psthT(find(all_psthT.is_ir(:,2)),:);
res_cells = all_psthT(find(all_psthT.is_responsive(:,2)),:);



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
% per
rel_eria = ["AC", "IL", "PL"];
for i = 1:length(rel_eria)
    T = T_all(find(ismember(T_all.main_structure, rel_eria{i})), :);
    % chi-squre
    [transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_responsive(:,1), T.layers);
    transient.df = degfree(transient.table);
    [sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_responsive(:,2), T.layers);
    sustained.df = degfree(sustained.table);

    
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
    
    sgtitle(rel_eria{i})

    save([rel_eria{i} '_transient_data'], 'transient')
    save([rel_eria{i} '_sustained_data'], 'sustained')
    savefig(f1, [rel_eria{i} '_chi_squre_data'])
end


cd ..
%%
%% Is IR
mkdir("d - intensity encoding")
cd("d - intensity encoding")
% per
rel_eria = ["AC", "IL", "PL"];
for i = 1:length(rel_eria)
    T = T_all(find(ismember(T_all.main_structure, rel_eria{i})), :);
    % chi-squre
    [transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_ir(:,1), T.layers);
    transient.df = degfree(transient.table);
    [sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_ir(:,2), T.layers);
    sustained.df = degfree(sustained.table);

    
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
    
    sgtitle(rel_eria{i})

    save([rel_eria{i} '_transient_data'], 'transient')
    save([rel_eria{i} '_sustained_data'], 'sustained')
    savefig(f1, [rel_eria{i} '_chi_squre_data'])
end
cd ..

%% enhanced vs supprressed
mkdir("e - enhanced_vs_suppressed")
cd("e - enhanced_vs_suppressed")
for i = 1:length(rel_eria)
    %
    IR_cells = ir_cells(find(ismember(ir_cells.main_structure, rel_eria{i})), :);
    [enhanced_vs_suppressed.table, enhanced_vs_suppressed.chi2, enhanced_vs_suppressed.pval, lables] = crosstab(IR_cells.enhanced,IR_cells.layers);
    enhanced_vs_suppressed.df = degfree(enhanced_vs_suppressed.table);
    
    f1 = figure;
    f1.Position = [379 330 1227 648];
    
    bar(categorical(lables(:,2)), (enhanced_vs_suppressed.table(:, :)./sum(enhanced_vs_suppressed.table))')
    legend([ "suppressed","enhanced",])
    title([rel_eria{i} 'percent of enhanced'])
    subtitle(['pval: ' num2str(enhanced_vs_suppressed.pval)])

    
    
    save([rel_eria{i} '_enhanced_vs_suppressed'], 'enhanced_vs_suppressed')
    savefig(f1, [rel_eria{i} '_chi_squre_data'])
end
cd ..


%% use only layers 2 vs 5/6
T_all_2_vs_5_6 = T_all;
T_all_2_vs_5_6(find(ismember(T_all_2_vs_5_6.layers,'1')),:) = [];
T_all_2_vs_5_6.layers(find(ismember(T_all_2_vs_5_6.layers, ["5", "6"]))) = {'5/6'};
ir_cells_all_2_vs_5_6 = T_all_2_vs_5_6(find(T_all_2_vs_5_6.is_ir_sustanied),:);
mkdir('layers 2-3_vs_5-6')
cd('layers 2-3_vs_5-6')

% Is responsive 
mkdir("c - light responsive")
cd("c - light responsive")
% per
rel_eria = ["AC", "IL", "PL"];
for i = 1:length(rel_eria)
    T = T_all_2_vs_5_6(find(ismember(T_all_2_vs_5_6.main_structure, rel_eria{i})), :);
    % chi-squre
    [transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_responsive(:,1), T.layers);
    transient.df = degfree(transient.table);
    [sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_responsive(:,2), T.layers);
    sustained.df = degfree(sustained.table);

    
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
    
    sgtitle(rel_eria{i})

    save([rel_eria{i} '_transient_data'], 'transient')
    save([rel_eria{i} '_sustained_data'], 'sustained')
    savefig(f1, [rel_eria{i} '_chi_squre_data'])
end


cd ..
%
% Is IR
mkdir("d - intensity encoding")
cd("d - intensity encoding")
% per
rel_eria = ["AC", "IL", "PL"];
for i = 1:length(rel_eria)
    T = T_all_2_vs_5_6(find(ismember(T_all_2_vs_5_6.main_structure, rel_eria{i})), :);
    % chi-squre
    [transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_ir(:,1), T.layers);
    transient.df = degfree(transient.table);
    [sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_ir(:,2), T.layers);
    sustained.df = degfree(sustained.table);

    
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
    
    sgtitle(rel_eria{i})

    save([rel_eria{i} '_transient_data'], 'transient')
    save([rel_eria{i} '_sustained_data'], 'sustained')
    savefig(f1, [rel_eria{i} '_chi_squre_data'])
end
cd ..

mkdir("e - enhanced_vs_suppressed")
cd("e - enhanced_vs_suppressed")
for i = 1:length(rel_eria)
    %
    IR_cells = ir_cells_all_2_vs_5_6(find(ismember(ir_cells_all_2_vs_5_6.main_structure, rel_eria{i})), :);
    [enhanced_vs_suppressed.table, enhanced_vs_suppressed.chi2, enhanced_vs_suppressed.pval, lables] = crosstab(IR_cells.enhanced,IR_cells.layers);
    enhanced_vs_suppressed.df = degfree(enhanced_vs_suppressed.table);
    
    f1 = figure;
    f1.Position = [379 330 1227 648];
    X = categorical(lables(:,2));
    X = reordercats(X, lables(:,2));
    bar(X, (enhanced_vs_suppressed.table(:, :)./sum(enhanced_vs_suppressed.table))')
    legend([ "suppressed","enhanced",])
    title([rel_eria{i} ' percent of enhanced'])
    subtitle(['pval: ' num2str(enhanced_vs_suppressed.pval)])

    
    
    save([rel_eria{i} '_enhanced_vs_suppressed'], 'enhanced_vs_suppressed')
    savefig(f1, [rel_eria{i} '_chi_squre_data'])
end
cd ..







cd .. 



