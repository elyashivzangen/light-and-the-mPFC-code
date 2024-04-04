%% before_laser_baseline
clear
clc

cd('E:\2023 - ledramp\eopn3\all_psth_T_files')
[file, path] = uigetfile('all_psth_table.mat','MultiSelect','on');%select all_psth_table
cd(path)
%%
T = table;

for i = 1:length(file)
    load(file{i})
    files_data = readtable([file{i}(1:end-4) '.csv']);
    all_psthT.is_before = repmat({files_data.plexon_samples_num > 16500000 & files_data.plexon_samples_num < 16600000}, [length(all_psthT.cell_name), 1]);
    all_psthT.exp_name = repmat(string(file{i}(1:(end-4))), [length(all_psthT.cell_name), 1]);
    T = [T; all_psthT];
end

%%

for i = 1:size(T,1)
    rep_psth = struct2table(T.rep_psth{i},"AsArray",true);
    before(i,1) = rep_psth{:,1};
    after(i,1) = rep_psth{:,2};
end
%%
baselines_before = cellfun(@(x) mean(x(:,1:30),"all"), before);
baselines_after = cellfun(@(x) mean(x(:,1:30),"all"), after);
response_before = cellfun(@(x) mean(x(:,55:125),"all"), before);
response_after = cellfun(@(x) mean(x(:,55:125),"all"), after);

on_before = cellfun(@(x) mean(x(:,42:50),"all"), before);
on_after = cellfun(@(x) mean(x(:,42:50),"all"), after);
%%
figure
histogram(baselines_before - baselines_after)
xline(mean(baselines_before - baselines_after))
[a,b,c,d] = ttest(baselines_before - baselines_after)
title('baseline')
%%
figure
histogram(response_before - response_after)
xline(mean(response_before - response_after))
[a,b,c,d] = ttest(response_before - response_after)
title('response')

%%
figure
histogram(on_before - on_after)
xline(mean(on_before - on_after))
[a,b,c,d] = ttest(on_before - on_after)
title('on')


%% find psth for before and after
for i = 1:size(T,1)
    rep_psth = struct2table(T.rep_psth{i},"AsArray",true);

    for j = 1:sum(T.is_before{i})
        before_idx = find(T.is_before{i});
        after_idx = find(~T.is_before{i});
        ND_name = rep_psth.Properties.VariableNames{before_idx(j)};
        C = strsplit(ND_name,["_", "x"]);
        nd_int = C(2);
        after_nd = find(contains(rep_psth.Properties.VariableNames(after_idx),nd_int));
        if after_nd > 1
            after_nd = after_nd(1);
        end
        if isempty(after_nd)
            continue
        end
        before = rep_psth{:,ND_name}{1};
        after =  rep_psth{:,after_nd}{1};

        all_nds.(['nd' nd_int{1}]).baseline{i,1} =  mean(before(:,1:30),2);
        all_nds.(['nd' nd_int{1}]).baseline{i,2} =  mean(after(:,1:30),2);
        all_nds.(['nd' nd_int{1}]).response{i,1} =  mean(before(:,65:125),2) - all_nds.(['nd' nd_int{1}]).baseline{i,1};
        all_nds.(['nd' nd_int{1}]).response{i,2} =  mean(after(:,65:125),2)- all_nds.(['nd' nd_int{1}]).baseline{i,2};
        all_nds.(['nd' nd_int{1}]).on{i,1} =  mean(before(:,42:51),2) - all_nds.(['nd' nd_int{1}]).baseline{i,1};
        all_nds.(['nd' nd_int{1}]).on{i,2} =  mean(after(:,42:51),2) - all_nds.(['nd' nd_int{1}]).baseline{i,2};



        all_nds.(['nd' nd_int{1}]).psth{i,1} =   mean(before,1) - mean(all_nds.(['nd' nd_int{1}]).baseline{i,1});
        all_nds.(['nd' nd_int{1}]).psth{i,2} =   mean(after,1) - mean(all_nds.(['nd' nd_int{1}]).baseline{i,2});

        isenhanced(1) = mean(all_nds.(['nd' nd_int{1}]).psth{i,1}(65:125))>0;
        isenhanced(2) = mean(all_nds.(['nd' nd_int{1}]).psth{i,2}(65:125))>0;

        if ~isenhanced(1)
            all_nds.(['nd' nd_int{1}]).abs_psth{i,1} =  all_nds.(['nd' nd_int{1}]).psth{i,1}*-1;
        else
            all_nds.(['nd' nd_int{1}]).abs_psth{i,1} =  all_nds.(['nd' nd_int{1}]).psth{i,1}
        end
        if ~isenhanced(2)
            all_nds.(['nd' nd_int{1}]).abs_psth{i,2} =  all_nds.(['nd' nd_int{1}]).psth{i,2}*-1;
        else
            all_nds.(['nd' nd_int{1}]).abs_psth{i,2} =  all_nds.(['nd' nd_int{1}]).psth{i,2};
        end


        [~, pval_all_cells.(['nd' nd_int{1}]){i,1}] = ttest(all_nds.(['nd' nd_int{1}]).baseline{i,1} - all_nds.(['nd' nd_int{1}]).baseline{i,2});
        [~, pval_all_cells.(['nd' nd_int{1}]){i,2}] = ttest(all_nds.(['nd' nd_int{1}]).response{i,1} - all_nds.(['nd' nd_int{1}]).response{i,2});
        [~, pval_all_cells.(['nd' nd_int{1}]){i,3}] = ttest(all_nds.(['nd' nd_int{1}]).on{i,1} - all_nds.(['nd' nd_int{1}]).on{i,2});

    end
end


%%
NDs = fieldnames(all_nds);
for i = 1:length(NDs)
    res = all_nds.(NDs{i}).response;
    abs_res = cellfun(@(x) abs(mean(x)), res);
    res_diff = abs_res(:,1) - abs_res(:,2);
    [laser_effect(i,1), p(i,1)] = ttest(res_diff);

    b = all_nds.(NDs{i}).baseline;
    mean_b = cellfun(@(x) abs(mean(x)), b);
    b_diff = mean_b(:,1) - mean_b(:,2);
    [laser_effect_b(i,1), p_b(i,1)] = ttest(b_diff);


    on = all_nds.(NDs{i}).on;
    mean_on = cellfun(@(x) abs(mean(x)), on);
    on_diff = mean_on(:,1) - mean_on(:,2);
    [laser_effect_on(i,1), p_on(i,1)] = ttest(on_diff);



    f1 = figure;
    f1.Position = [146 128 1540 843];
    subplot(2,2,2)
    histogram(b_diff)
    xline(mean(b_diff))
    title('baseline diff')
    subtitle(['pval: ' num2str(p_b(i,1))])

    subplot(2,2,3)
    histogram(on_diff)
    xline(mean(on_diff))
    title('on diff')
    subtitle(['pval: ' num2str(p_on(i,1))])

    subplot(2,2,1)
    histogram(res_diff)
    xline(mean(res_diff))
    title('response diff')
    subtitle(['pval: ' num2str(p(i,1))])
    

    abs_psth(:,1) = mean(cell2mat(all_nds.(NDs{i}).abs_psth(:,1)));
    abs_psth(:,2) = mean(cell2mat(all_nds.(NDs{i}).abs_psth(:,2)));

    subplot(2,2,4)
    plot(abs_psth)
    title('mean abs psth')
    legend(["before", "after"], "Location","best")

    sgtitle(NDs{i})

    exportgraphics(f1,'before and after laser.pdf', 'Append',true)
end

T2 = table(laser_effect_b, p_b, laser_effect,p, laser_effect_on, p_on, NDs)


