%plot before and after per cluster
%calcualte_mean_psth
clear
clc
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
%%

for w = 1:length(file)
    
    clearvars -except file w
   

    load(file{w})
    folder_name = file{w}(1:end-4);
    if isfolder(folder_name)
        rmdir(folder_name, 's')
    end
    mkdir(folder_name)
    cd(file{w}(1:end-4))
    window_times = {40:50, 65:125, 140:150};
    win_names = ["ON", "Sustanied" , "OFF"];
    win = 2;
    for u = 1:length(win_names)
        if contains(file{w}, win_names{u})
            win = u;
        end
    end

    intenseties_used = [1, 2, 3,4,6,8,10];
    counts = zeros(4,1);
    fields = fieldnames(all_data{1,1});
    for i = 1:length(fields)
        s = all_data{1,1}.(fields{i});
        counts(s.cluster) =  counts(s.cluster) + 1;
        mean_psth{s.cluster, 1}(counts(s.cluster),:) = s.intensities(1).psth.mean;
        mean_psth{s.cluster, 2}(counts(s.cluster),:) = all_data{1,2}.(fields{i}).intensities(1).psth.mean;
        
        rmse{s.cluster, 1}(counts(s.cluster)) = all_data{1,1}.(fields{i}).new_fit3(win).original_rmse;
        rmse{s.cluster, 2}(counts(s.cluster)) = all_data{1,2}.(fields{i}).new_fit3(win).original_rmse;

        after_res_ir{s.cluster}(counts(s.cluster)) =  all_data{1,2}.(fields{i}).Is_reponsive_and_IR(win);
        after_res{s.cluster}(counts(s.cluster)) = all_data{1,2}.(fields{i}).Is_reponsive(win);

        % plot all ints
        for j = 1:length(s.x)
            all_ints{s.cluster, 1}(counts(s.cluster), j,:) = s.intensities(intenseties_used(j)).psth.mean;
            all_ints{s.cluster, 2}(counts(s.cluster), j,:) = all_data{1,2}.(fields{i}).intensities(intenseties_used(j)).psth.mean;
            all_ir{s.cluster, 1}(counts(s.cluster), j) = mean(s.intensities(intenseties_used(j)).psth.mean(window_times{win}));
            all_ir{s.cluster, 2}(counts(s.cluster), j) = mean(all_data{1,2}.(fields{i}).intensities(intenseties_used(j)).psth.mean(window_times{win}));

        end
    end

    %% plot
    f1 = figure;

    f2 = figure;

    f3 = figure;

    f4 = figure;

    f5 = figure;

    f6 = figure;
    
    mean_rmse = cellfun(@mean, rmse);
    std_rmse = cellfun(@std, rmse);
    length_rmse = cellfun(@length, rmse);
    sem_rmse = std_rmse./(sqrt(length_rmse));
    mean_sem_ramse = table(mean_rmse, std_rmse,  sem_rmse);

    t = categorical(["before", "after"]);
    for i = 1:size(mean_psth, 1)
        figure(f1)
        n = size(mean_psth{i, 1}, 1);
        if n == 0
            continue
        end
        subplot(2,2,i)
        before_psth(i,:) = mean(mean_psth{i, 1}, 1);
        after_psth(i,:) = mean(mean_psth{i, 2}, 1);
        before_psth_sem(i,:) = sem(mean_psth{i, 1}, 1);
        after_psth_sem(i,:) = sem(mean_psth{i, 2}, 1);

        plot(smooth(before_psth(i,:)))
        hold on
        plot(smooth(after_psth(i,:)))
        legend(t)
        title(['n = ' num2str(n)])
        hold off


        before_all_ints = squeeze(mean(all_ints{i, 1}, 1));
        after_all_ints = squeeze(mean(all_ints{i, 2}, 1));
        before_all_ints_sem = squeeze(sem(all_ints{i, 1}, 1));
        after_all_ints_sem = squeeze(sem(all_ints{i, 2}, 1));

        figure(f2)
        f2.Position = [100, 100, 1700, 800];
        subplot(2,4,i)
        plot(before_all_ints')
        title(["before"    'cluster: ' num2str(i)])
        subplot(2,4,i + 4 )
        plot(after_all_ints')
        title(["after"     'cluster: ' num2str(i)])


        %plot_ir
        figure(f3)
        subplot(2,2,i)
        before_ir(i, :) = mean(all_ir{i, 1}, 1);
        after_ir(i, :) = mean(all_ir{i, 2}, 1);
        before_ir_sem(i, :) = sem(all_ir{i, 1}, 1);
        after_ir_sem(i, :) = sem(all_ir{i, 2}, 1);
        x = s.x;
        plot(x, before_ir(i, :), '-o')
        hold on
        plot(x, after_ir(i, :), '-o')
        hold off
        legend(t)

        figure(f4)
        sgtitle('responsive and IE')
        responsive_ir(i, 1) =  length(after_res_ir{i});
        responsive_ir(i, 2) = sum(after_res_ir{i});
        subplot(2,2,i)
        bar(t,responsive_ir(i,:))
        title(['cluster = ' num2str(2)])

        figure(f5)
        sgtitle('responsive')
        responsive(i, 1) =  length(after_res{i});
        responsive(i, 2) = sum(after_res{i});
        subplot(2,2,i)
        bar(t,responsive(i,:))
        title(['cluster = ' num2str(2)])

        figure(f6)
        sgtitle('mean rmse')
        [~, ttest_rmse(i)] = ttest(rmse{i,1}',rmse{i,2}','Tail','left');
        subplot(2,2,i)
        bar(t,[mean_rmse(i, 1), mean_rmse(i, 2)])
        title(['cluster = ' num2str(i)])
        subtitle(['ttest_pval = ' num2str(ttest_rmse(i))])


    end
    savefig(f1, [file{w}(1:end-4) '.fig'])
    savefig(f2, [file{w}(1:end-4) '_all_ints'])
    savefig(f3, [file{w}(1:end-4) '_ir'])
    savefig(f4, [file{w}(1:end-4) '_ir_responsive'])
    savefig(f5, [file{w}(1:end-4) '_responsive'])
    savefig(f6, [file{w}(1:end-4) '_rmse'])
    



    exportgraphics(f1, [file{w}(1:end-4) '_allfigs.pdf'], 'Append',true)
    exportgraphics(f2, [file{w}(1:end-4) '_allfigs.pdf'], 'Append',true)
    exportgraphics(f3, [file{w}(1:end-4) '_allfigs.pdf'], 'Append' ,true)
    exportgraphics(f4, [file{w}(1:end-4) '_allfigs.pdf'], 'Append',true)
    exportgraphics(f5, [file{w}(1:end-4) '_allfigs.pdf'], 'Append',true)
    exportgraphics(f6, [file{w}(1:end-4) '_allfigs.pdf'], 'Append' ,true)

    mean_sem_ramse.ttest_pval = ttest_rmse';
    num_of_res_ie_cells = table(responsive, responsive_ir);
    ir_mean_sem = table(before_ir, after_ir, before_ir_sem, after_ir_sem);
    all_int_psth = table(before_all_ints, after_all_ints, before_all_ints_sem, after_all_ints_sem);
    save('IR_mean_sem', 'ir_mean_sem')
    save('all_int_psth_mean_sem', 'all_int_psth')
    save('all_rmse', "rmse")
    save('mean_rmse', "mean_sem_ramse")
    save('num_of_res_ie_cells', "num_of_res_ie_cells")
    writetable(num_of_res_ie_cells,"num_of_res_ie_cells.csv" )
    close all
    %%
    cd ..
end

