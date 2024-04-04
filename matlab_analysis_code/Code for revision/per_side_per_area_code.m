clear
clc
erias = ["AC", "PL", "IL", "DP", "TT"];
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\figure1_stats\sides')
load("all_psth_T_with_sides.mat")

%% pool ACd ACv, 6a 6b
change_position_name = T.position;
AC_names = find(contains(change_position_name, 'ACA'));
change_position_name(find(contains(change_position_name, '6'))) = cellfun(@(x) x(1:end-1), change_position_name(find(contains(change_position_name, '6'))), 'UniformOutput', false);
change_position_name(AC_names) = cellfun(@(x) x([1:3 find(ismember(x,'12/3456'))]), change_position_name(AC_names), 'UniformOutput',false);
T.changed_position_name = change_position_name;
T.is_responsive_sustanied = T.is_responsive(:,2);
T.is_ir_sustanied = T.is_ir(:,2);
T(find(contains( T.position, "root")), :) = [];
T(find(contains( T.position, "OLF")), :) = [];
T(find(contains( T.position, "cing")), :) = [];
T.layers = cellfun(@(x) x(ismember(x, '12/356')),T.changed_position_name, "UniformOutput",false);
T.layers = cellfun(@(x) strrep(x,'/','_'),T.layers, "UniformOutput",false);
%
for i = 1:length(erias)
    mkdir(erias{i})
    cd(erias{i})
    relT = T(find(ismember(T.main_structure, erias{i})),:);
    mkdir('responsive')
    cd('responsive')
    [transient.table, transient.chi2, transient.pval, lables] = crosstab(relT.is_responsive(:,1), relT.side);
    transient.df = degfree(transient.table);
    [sustained.table, sustained.chi2, sustained.pval,lables] = crosstab(relT.is_responsive(:,2), relT.side);
    sustained.df = degfree(sustained.table);

    f1 = figure;
    f1.Position = [379 330 1227 648];

    subplot(1,2,1)
    bar(categorical(lables(:,2)), transient.table(2, :)/sum(transient.table, "all"))
    title('transient')
    subtitle(['pval: ' num2str(transient.pval)])


    subplot(1,2,2)
    bar(categorical(lables(:,2)), sustained.table(2, :)/sum(sustained.table, "all"))
    title('sustained')
    subtitle(['pval: ' num2str(sustained.pval)])

    save('transient_data', 'transient')
    save('sustained_data', 'sustained')

    savefig(f1, 'chi_squre_data')

    cd ..

    mkdir('IE')
    cd('IE')

    [sustained.table, sustained.chi2, sustained.pval, lables] = crosstab(relT.is_ir(:,2), relT.side);
    sustained.df = degfree(sustained.table);



    f1 = figure;

    bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table, 1))
    title('sustained')
    subtitle(['pval: ' num2str(sustained.pval)])

    save('sustained_data', 'sustained')
    savefig(f1, 'chi_squre_data')
    cd ..
    % layers
    layers = ["1", "2_3", "5","6"];
    G = grpstats(relT, ["layers", "side"]);
    for j = 1:length(layers)
        if sum(ismember(G.layers, layers{j})) > 1
            mkdir(['layer_' layers{j}])
            cd(['layer_' layers{j}])
            layerT = relT(find(ismember(relT.layers,layers{j})),:);
            mkdir('responsive')
            cd('responsive')
            [transient.table, transient.chi2, transient.pval, lables] = crosstab(layerT.is_responsive(:,1), layerT.side);
            transient.df = degfree(transient.table);
            [sustained.table, sustained.chi2, sustained.pval,lables] = crosstab(layerT.is_responsive(:,2), layerT.side);
            sustained.df = degfree(sustained.table);

            f1 = figure;
            f1.Position = [379 330 1227 648];

            subplot(1,2,1)
            bar(categorical(lables(:,2)), transient.table(2, :)/sum(transient.table, "all"))
            title('transient')
            subtitle(['pval: ' num2str(transient.pval)])


            subplot(1,2,2)
            bar(categorical(lables(:,2)), sustained.table(2, :)/sum(sustained.table, "all"))
            title('sustained')
            subtitle(['pval: ' num2str(sustained.pval)])

            save('transient_data', 'transient')
            save('sustained_data', 'sustained')

            savefig(f1, 'chi_squre_data')

            cd ..

            mkdir('IE')
            cd('IE')

            [sustained.table, sustained.chi2, sustained.pval, lables] = crosstab(layerT.is_ir(:,2), layerT.side);
            sustained.df = degfree(sustained.table);



            f1 = figure;

            bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table, 1))
            title('sustained')
            subtitle(['pval: ' num2str(sustained.pval)])

            save('sustained_data', 'sustained')
            savefig(f1, 'chi_squre_data')
            cd ..
            cd ..

        end

    end






    cd ..
end