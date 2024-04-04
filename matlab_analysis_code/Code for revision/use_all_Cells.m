%% analize PHb cimogenetics
%% plot all cells before and after
nds = [10,8,6,4,3,2,1];
all_cells{2}.cluster = all_cells{1}.cluster;
%% takeout nan cells
nan_idx = find(sum(isnan(cell2mat(all_cells{1}.ttest_pval)), 2) >1);
nan_cells{1} = all_cells{1}(nan_idx, :);
all_cells{1}(nan_idx,:) = [];
nan_cells{2} = all_cells{2}(nan_idx, :);
all_cells{2}(nan_idx,:) = [];
%%
times = ["before", "after"];
psth = [];
for i = 1:length(nds)
    nd_names{i} = ['nd_' num2str(nds(i))];
    for j = 1:2

    bef = cellfun(@(x) x(nds(i)).psth, all_cells{j}.intensities);
    bef = struct2table(bef);
    psth.(times{j}).(nd_names{i}) = cell2mat(bef.mean')';
    response.(times{j})(:, i) =  mean(psth.(times{j}).(nd_names{i})(:,65:125), 2);    
    end

end
%%



T =[];
for i = 1:2
   T.(times{i}) = struct2table(psth.(times{i}));
   T.(times{i}).cluster = cell2mat(all_cells{i}.cluster);
   T.(times{i}).baseline = cellfun(@(x) x.mean, all_cells{i}.baseline_vector, 'UniformOutput', false);
   T.(times{i}).baseline = cell2mat(T.(times{i}).baseline);
   T.(times{i}).res = cell2mat(all_cells{i}.Is_reponsive);
   T.(times{i}).res_ir = cell2mat(all_cells{i}.Is_reponsive_and_IR);
   T.(times{i}).response = response.(times{i});
   T.(times{i}).enhanced = T.(times{i}).response(:,end) > 0;
end
%% plot
for i = 1:2
    all_cells_compare{i} = grpstats(T.(times{i}), [], ["mean", "sem"]);
    enhanced_vs_supprressed{i} = grpstats(T.(times{i}), "enhanced", ["mean", "sem"]);
    



    % responsive cells
    resT{i} = T.(times{i})(find(T.before.res(:,2)), :);
    responsive_all{i} = grpstats(resT{i}, [], ["mean", "sem"]);
    responsive_enhanced_vs_supprressed{i} = grpstats(resT{i}, "enhanced", ["mean", "sem"]);
    responsive_all_clusters{i} =  grpstats(resT{i}, "cluster", ["mean", "sem"]);
    

    % reponsive ir cells
    res_irT{i} = T.(times{i})(find(T.before.res_ir(:,2)), :);
    res_ir_all{i} = grpstats(res_irT{i}, [], ["mean", "sem"]);
    res_ir_enhanced_vs_supprressed{i} = grpstats(res_irT{i}, "enhanced", ["mean", "sem"]);
    res_ir_all_clusters{i} =  grpstats(res_irT{i}, "cluster", ["mean", "sem"]);
end
%% plot all
mkdir('all_plots')
cd('all_plots')
plot_options(all_cells_compare, 'all_cells_compare')
plot_options(enhanced_vs_supprressed, 'enahaced and supprressed')
plot_options(responsive_all, 'responsive all cells')
plot_options(responsive_enhanced_vs_supprressed, 'responsive_enhanced_vs_supprressed')
plot_options(responsive_all_clusters, 'responsive_all_clusters')

plot_options(res_ir_all, 'res_ir_all')
plot_options(res_ir_enhanced_vs_supprressed, 'res_ir_enhanced_vs_supprressed')
plot_options(res_ir_all_clusters, 'res_ir_all_clusters')
%% plot res IR
res_transient(1,1) = all_cells_compare{1}.mean_res(1);
res_transient(2,1) = all_cells_compare{2}.mean_res(1);


res_sustaind(1,1) = all_cells_compare{1}.mean_res(2);
res_sustaind(2,1) = all_cells_compare{2}.mean_res(2);


ir_res_transient(1,1) = all_cells_compare{1}.mean_res_ir(1);
ir_res_transient(2,1) = all_cells_compare{2}.mean_res_ir(1);

ir_res_sustaind(1,1) = all_cells_compare{1}.mean_res_ir(2);
ir_res_sustaind(2,1) = all_cells_compare{2}.mean_res_ir(2);

T1  = table(res_transient, res_sustaind, ir_res_transient,ir_res_sustaind, RowNames=  times );
%%
f1 = figure;

subplot(2,2,1)
bar(categorical([" before", "after"]),res_transient )
title('res_transient', Interpreter='none')

subplot(2,2,2)
bar(categorical([" before", "after"]),res_sustaind )
title('res_sustaind', Interpreter='none')


subplot(2,2,3)
bar(categorical([" before", "after"]),ir_res_transient)
title('ir_res_transient', Interpreter='none')

subplot(2,2,4)
bar(categorical([" before", "after"]),ir_res_sustaind)
title('ir_res_sustaind', Interpreter='none')

sgtitle('percent of resposive cells')
savefig(f1, 'percent of resposive cells')
    exportgraphics(f1, 'allfigs.pdf' ,'Append',true)
writetable(T1,"percent of resposive cells.csv", "WriteRowNames",true)
%% plot options
function plot_options(g, name)
    f1 = figure;
    t = (-3:0.1:17) - 1.116;
    intensities = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];

    rownum = size(g{1},1);
    f1.Position = [100 100 350*rownum 800];
    for j = 1:rownum
        for i = 1:2
            subplot(3,1*rownum, j)
            plot(t, g{i}.mean_nd_1(j,:))
            xline(0)
            xline(10)
            hold on
            subtitle('ND 1 psth')
            title([g{i}.Properties.VariableNames{1}  '  ' num2str(g{i}{j,1})])

             subplot(3,1*rownum, j + rownum)
             errorbar(flip(intensities), g{i}.mean_response(j,:),  g{i}.sem_response(j,:), '-o')
             hold on
             xlabel("intensity")
             ylabel("fr (HZ) above baseline")
             title("ir curve")

             subplot(3,1*rownum, j + rownum*2)
             errorbar(flip(intensities), g{i}.mean_baseline(j,:),  g{i}.sem_baseline(j,:), '-o')
             hold on
             xlabel("intensity")
             ylabel("fr (HZ) ")
             title("baseline")
        end
        legend(["before", "after"])
        h = sgtitle([name '   n = ' num2str(sum(g{1}.GroupCount))]);
        h.Interpreter = 'none';

    end
    exportgraphics(f1, 'allfigs.pdf' ,'Append',true)
    savefig(f1, name)
    save(name, "g")

end