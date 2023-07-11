clear
clc
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
%%
n = length(file);
all_psth = cell(7,2);
all_cells = cell(1,2);
ploting = 1;




window_times = {40:50, 65:125, 140:150};
win_names = ["early", "steady" , "off"];
windows = ["early_responsive", "steady_responsive", "off_responsive", "early_ir", "steady_ir", "off_ir"];
for w = 1:6
    all_T.(windows(w)).before = table;
    all_T.(windows(w)).after = table;
end
nds = [10,8,6,4,3,2,1];
times = ["before", "after"];

for i = 1:n
    load(file{i})
    %remove_cells_without_both_before_and_after

    before_names = fieldnames(all_data{1,1});
    after_names = fieldnames(all_data{1,2});
    if length(before_names) > length(after_names)
        nonmatch = before_names(~ismember(before_names, after_names));
        all_data{1,1} = rmfield(all_data{1,1},nonmatch);
    end


    for j = 1:length(all_data)

        t = struct2table_open(all_data{1,j});
        cname = t.Properties.RowNames;
        res = cell2mat(t.Is_reponsive(:));
        ir = cell2mat(t.Is_reponsive_and_IR(:));
        res_ir = [res ir];




        %extract all psths
        ints = cellfun(@struct2table, t.intensities, "UniformOutput",false);
        if length(t{1,"x"}{1}) < 7
            all_psth{1, j} = [all_psth{1, j}; NaN(length(ints), 201)];
        end
        for y = (length(nds) - length(t{1,"x"}{1}) +1 ):length(nds) %work in cases the ND - 10 is not presented
            psths = cellfun(@(x) x.psth(nds(y)), ints, "UniformOutput",false);
            mean_p = cellfun(@(x) x{1}.mean, psths, "UniformOutput",false);
            mean_p = cell2mat(mean_p')';
            all_psth{y, j} = [all_psth{y, j}; mean_p];

        end

        %extract all cells
        new_cname = cellfun(@(x) [file{i}(1:end-4) '_' x], cname, 'UniformOutput', false); %cange cells names to includ exp
        t.Properties.RowNames = new_cname;
        if ~isempty(all_cells{1,j})
            t = t(:, all_cells{1,j}.Properties.VariableNames);
        end
        all_cells{1,j} = [all_cells{1,j} ; t];





        %extract responsive per eria
        for w = 1:size(res_ir, 2)
            idx = find(res_ir(:, w));
            rnames = cname(idx);
            nt = t(idx,:);
            number = length(idx);
            win = w;
            if w > 3
                win = w - 3;
            end
            pval = cellfun(@(x) x(win), nt.ttest_pval);
            total = length(cname);
            res_prop = number/total;
            all_T.(windows(w)).(times{j}).responsive_proportion(i) = res_prop;
            all_T.(windows(w)).(times{j}).cell_num(i) = total;
            all_T.(windows(w)).(times{j}).relevant_num(i) = number;
            all_T.(windows(w)).(times{j}).cell_names(i) = {rnames};
            all_T.(windows(w)).(times{j}).relevant_cells_data(i) = {nt};
            all_T.(windows(w)).(times{j}).pval(i) = {pval};
            all_T.(windows(w)).(times{j}).Properties.RowNames(i) = file(i);
        end
    end
end


%% find pvalue of res and ir per experiment
mkdir('cimogenetic_stats_without_mel_ko')
cd("cimogenetic_stats_without_mel_ko")
mkdir("responsive ir per exp")

cd("responsive ir per exp")

for w = 1:length(windows)
    before_prop =  all_T.(windows(w)).before.responsive_proportion;
    after_prop =  all_T.(windows(w)).after.responsive_proportion;
    % remove experaments with no responsive cells before and after
    outliers  = find(~(before_prop+after_prop));
    before_prop(outliers) = [];
    after_prop(outliers) = [];
    before_num(w, 1) = sum(all_T.(windows(w)).before.relevant_num);
    after_num(w, 1) = sum(all_T.(windows(w)).after.relevant_num);
    total(w, 1) = sum(all_T.(windows(w)).after.cell_num);
    p_val_premutation(w, 1) = permutationTest(before_prop, after_prop, 10000);
    [~, p_val_ttest(w, 1)] = ttest(before_prop, after_prop, "Tail","right");
end
responsive_and_ir = table(before_num, after_num, total,p_val_premutation , p_val_ttest, RowNames=windows);



% save responsive_and_ir parameters
writetable(responsive_and_ir, "responsive_and_ir_per_experiment.csv",'WriteRowNames',true)
save("responsive_and_ir_per_experiment", 'responsive_and_ir')
save("all_responsive_cell_per_experiment", "all_T")
%%


%extract rmse
for i = 1:2
    fit = all_cells{:,i}.new_fit3;
    for w = 1:3
        rmse = cellfun(@(x) x(w).original_rmse, fit);
        R2 = cellfun(@(x) x(w).original_gof.rsquare, fit);
        all_rmse{w,i} = rmse;
        all_R2{w,i} = R2;
    end
end

for w = 1:3
    %      figure
    %      histogram(all_R2{w,1} - all_R2{w,2}, 100)
    %      hold on
    %      xline(mean(all_R2{w,1} - all_R2{w,2}) , 'r')

    [~, rmse_pval(w)] = ttest(all_rmse{w,1}, all_rmse{w,2},"Tail","left");
    [q(w), R2_pval(w)] = ttest(all_R2{w,1}, all_R2{w,2},"Tail","right");

end




%% plot and save parameters

for i = 1:size(responsive_and_ir, 1)
    figure
    bar(categorical(["before num", "after num"]), responsive_and_ir{i,["before_num" "after_num"]})
    title((responsive_and_ir.Properties.RowNames(i)))
    subtitle((['Pval = ' num2str(responsive_and_ir{i,"p_val_ttest"})]))
    savefig(responsive_and_ir.Properties.RowNames{i})
end
cd ..
%% plot psth, ir, and responsive per subset of cells/clusters. use dunction plot_and_save_before_and_after_psth
plot_and_save_before_and_after_psth(all_psth, all_cells, 'all_cells')

%% analize all sug cells
%find idx
res_idx = cell2mat(all_cells{1,1}.Is_reponsive);
ir_idx = cell2mat(all_cells{1,1}.Is_reponsive_and_IR);


%exclude eaperiment without 7 intensiteis

for i = 1:length(win_names)
    mkdir(win_names{i})
    cd(win_names{i})
    % responsive
    res_psth = cellfun(@(x) x(find(res_idx(:,i)),:), all_psth,'UniformOutput', false); 
    res_cells = cellfun(@(x) x(find(res_idx(:,i)),:), all_cells,'UniformOutput', false); 
    plot_and_save_before_and_after_psth(res_psth, res_cells, 'responsive')
    cd('responsive')
    %plot per cluster clusters
    clusters = cell2mat(res_cells{1}.cluster);
    u = unique(clusters);
    for j = u'
        idx = find(clusters == j);
        clust_psth = cellfun(@(x) x(idx,:), res_psth,'UniformOutput', false); 
        clust_cells = cellfun(@(x) x(idx,:), res_cells,'UniformOutput', false);
        plot_and_save_before_and_after_psth(clust_psth, clust_cells, ['cluster' num2str(j)])
        close all
    end
    cd ..



    %ir responsive
    res_psth = cellfun(@(x) x(find(ir_idx(:,i)),:), all_psth,'UniformOutput', false); 
    res_cells = cellfun(@(x) x(find(ir_idx(:,i)),:), all_cells,'UniformOutput', false); 
    plot_and_save_before_and_after_psth(res_psth, res_cells, 'ir_responsive')
    cd('ir_responsive')

    clusters = cell2mat(res_cells{1}.cluster);
    u = unique(clusters);
    for j = u'
        idx = find(clusters == j);
        if length(idx) == 1
            continue
        end
        clust_psth = cellfun(@(x) x(idx,:), res_psth,'UniformOutput', false); 
        clust_cells = cellfun(@(x) x(idx,:), res_cells,'UniformOutput', false);
        plot_and_save_before_and_after_psth(clust_psth, clust_cells, ['cluster' num2str(j)])
        close all
    end

    cd ..
    cd ..
end

%% find numebr of reponsive IE cells after from cells that are before
mkdir("responsive_IE_from_responsive_IE_before")

cd("responsive_IE_from_responsive_IE_before")
before_res_ir = cell2mat(all_cells{1}{:,["Is_reponsive","Is_reponsive_and_IR"]});
after_res_ir =  cell2mat(all_cells{2}{:,["Is_reponsive","Is_reponsive_and_IR"]});
expnames = cellfun(@(x) x(1:8), all_cells{1}.Properties.RowNames, UniformOutput=false);
for i = 1:length(windows)
    before_rel_res = before_res_ir(:, i);
    after_rel_res =  after_res_ir(:, i);
    after_rel_res(~before_rel_res) = 0;
    a = table(expnames, before_rel_res, after_rel_res);
    tblstats.(windows{i}) = grpstats(a,"expnames", ["mean", "sum"]);
    tblstats_mean.(windows{i}) = grpstats(tblstats.(windows{i})(:,[3,5]), [], ["mean", "std"]);
    before_num(i,1) = sum(before_rel_res);
    after_num(i,1) = sum(after_rel_res);
    total(i,1) = length(before_rel_res);
    [premutation_pval(i,1)] = mult_comp_perm_t1(tblstats.(windows{i}).mean_before_rel_res-tblstats.(windows{i}).mean_after_rel_res, 10000, 0, 0.05, 0, 0);
    [~ , ttest_pval(i,1)] = ttest(tblstats.(windows{i}).mean_before_rel_res, tblstats.(windows{i}).mean_after_rel_res);
    figure
    bar(categorical(["before num", "after num"]), [before_num(i), after_num(i)])
    title((windows(i)))
    subtitle(['Pval = ' num2str(ttest_pval(i))])
    savefig(windows(i))
    
end
responsive_and_ir_per_experiment = table(windows', before_num, after_num,  total,  premutation_pval, ttest_pval);
save('responsive_and_ir_per_experiment', 'tblstats')
writetable(responsive_and_ir_per_experiment, 'responsive_and_ir_total.csv')
save('mean_std_responsive_per_exp', 'tblstats_mean')
cd ..

    
