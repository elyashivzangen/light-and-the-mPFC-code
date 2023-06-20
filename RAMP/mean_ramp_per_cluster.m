% caculate mean ramp per cluster
clear
clc
ploting = 1 ;
norm  = 1;
ploting2 =1;
%%
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%%

counts = 0;
for i = 1:length(datafile)
    load(datafile{1,i});
    if iscell(all_data)
        all_data = all_data{1,1};
    end
    %     all_data = all_data.all_data;
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        current_cell = all_data.(cells{j});
        if current_cell.Is_reponsive_and_IR(2)
            baseline = mean(current_cell.baseline_vector.mean);
            counts = counts + 1;
            clusters(counts) = current_cell.cluster;
            ramps(counts, :) = current_cell.ramp.mean;
            smoothed_ramp(counts, :) = smooth(current_cell.ramp.mean);
            if norm
                ramps(counts, :) = current_cell.ramp.mean - mean(current_cell.ramp.mean(1:5));
                %if isfield(current_cell.ramp, 'total')
                 %   cut_end = mod(length(current_cell.ramp.total(5:end)), 20);

                 %   total_ramp = reshape(current_cell.ramp.total(5:end-cut_end), [],20);
                 ramps_sem(counts, :) = current_cell.ramp.sem;
%                 end
                smoothed_ramp(counts, :) = smooth(current_cell.ramp.mean - mean(current_cell.ramp.mean(1:5)));

            end
            int_num = 0;

            for k = 1:length(current_cell.intensities)
                if ~isempty(current_cell.intensities(k).psth)
                    int_num = int_num  + 1;
                    intensities(counts, int_num, :) = current_cell.intensities(k).psth.mean;
                    intensities_sems(counts, int_num, :) = current_cell.intensities(k).psth.std/sqrt(size(current_cell.intensities(k).intensty_data, 2));

                end
            end
        end
    end
end

%%
clust_num = unique(clusters);
f1=figure;
set(f1,'position',[500 500 600 600])
set(f1, 'color', [1 1 1]);
for i = clust_num
    %ramp
    ramp_sem(i, :) = sem(ramps(i == clusters, :), 1);
    ramp_mean(i, :) = mean(ramps(i == clusters, :), 1);
    %smoothed ramp
    smooted_mean(i, :) = mean(smoothed_ramp(i == clusters, :), 1);
    smooted_sem(i, :) = sem(smoothed_ramp(i == clusters, :), 1);




    %7 int
    intensities_mean(i, :, :) = mean(intensities(i == clusters, :, :), 1);
    intensities_sem(i, :, :) = sem(intensities(i == clusters, :, :), 1);

    %
    sus_window = 65:125;
    IR.mean = mean(intensities_mean(:,:,sus_window),3);
    IR.sem = sem(intensities_mean(:,:,sus_window),3);
    x = current_cell.x;
    IR.intensities = x;


    IR_all_cells_sem = sem(intensities(:, :, sus_window), 3);

    IR_all_cells = mean(intensities(:, :, sus_window), 3);
    IR_sem_cells(i, :) = sem(IR_all_cells(i == clusters, :), 1);

    clust_count(i) = sum(i == clusters);



    if ploting
        subplot(4, clust_num(end), i)
        plot(ramp_mean(i, :))
        title(['cluster ' num2str(i),   newline num2str(clust_count(i)) ' cells'])
        subplot(4, clust_num(end),   clust_num(end) + i)
        plot(smooted_mean(i, :))
        subplot(4, clust_num(end),   clust_num(end)*2 + i)
        hold on
        for k = 1:size(intensities_mean, 2)
            plot(squeeze(intensities_mean(i, k, :)))
        end
        hold off
        subplot(4, clust_num(end),   clust_num(end)*3 + i)
        plot(x, IR.mean(i, :), 'o')

    end
end
%% PLOT ALL CELLS for example

if ploting2
    for i = 1:counts
        f(i) = figure;
        set(f(i),'position',[100 100 1600 500])
        set(f(i), 'color', [1 1 1]);

        subplot(1, 4, 1)
        plot(ramps(i, :))
        title(['cell num ' num2str(i)])

        subplot(1, 4, 2)
        plot(smoothed_ramp(i, :))

        subplot(1, 4, 3)
        hold on
        for k = 1:size(intensities, 2)
            plot(bin_psth(squeeze(intensities(i, k, :)),10))
        end
        title(['cluster: ' num2str(clusters(i))])
        legend(num2str(x))
        hold off

        subplot(1, 4, 4)
        plot(x, mean(intensities(i, :, sus_window), 3), 'o')
        exportgraphics(f(i),['cell ' num2str(i) '.png'])

        %close all
    end
    close all
end

%% save specific cell
savecell = 0;
if savecell

n = 12; % cell number


ex_ramp.ramp.mean = ramps(n, :);
ex_ramp.ramp.sem = ramps_sem(n, :);
ex_ramp.intensities.mean = squeeze(intensities(n, :,:));
ex_ramp.intensities.sem = squeeze(intensities_sems(n, :,:));
ex_ramp.IR.mean = squeeze(mean(intensities(n, :,sus_window), 3));
ex_ramp.IR.sem = squeeze(sem(intensities(n, :,sus_window), 3));

f1 = figure;
set(f1,'position',[100 100 1600 500])
set(f1, 'color', [1 1 1]);

subplot(1, 4, 1)
plot(ramps(n, :))
title(['cell num ' num2str(n)])

subplot(1, 4, 2)
plot(smoothed_ramp(n, :))

subplot(1, 4, 3)
hold on
for k = 1:size(intensities, 2)
    plot(smooth(squeeze(intensities(n, k, :))))
end
title(['cluster: ' num2str(clusters(n))])
legend(num2str(x))
hold off

subplot(1, 4, 4)
plot(x, mean(intensities(n, :, sus_window), 3), 'o')
end
%% save all cells
all_ramps.mean = ramps;
all_ramps.sem = ramps_sem;
