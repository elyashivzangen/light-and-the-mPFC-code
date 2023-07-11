% plot beefore and after from all data
clear
clc
ploting =1 ;
window = 2; %(on, sus, off)
sus_window = 65:125;
%%
[file, path] = uigetfile('*before.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path

%load after
[file2, path2] = uigetfile('*after.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
datafile2 = fullfile(path2, file2); %save path
%%
counts = 0;
for i = 1:length(datafile)
    load(datafile{1,i});
    all_data2 =   load(datafile{1,i});
    all_data2 = all_data2.all_data;
    %     all_data = all_data.all_data;
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        current_cell = all_data.(cells{j});
        current_cell2 = all_data2.(cells{j});

        if current_cell.Is_reponsive_and_IR(window)
            counts = counts + 1;
            clusters(counts) = current_cell.cluster;

            int_num = 0;

            for k = 1:length(current_cell.intensities)
                if ~isempty(current_cell.intensities(k).psth)
                    int_num = int_num  + 1;
                    intensities(counts, int_num, :) = current_cell.intensities(k).psth.mean;
                    intensities2(counts, int_num, :) = current_cell2.intensities(k).psth.mean;

                end
            end
        end
    end
end

%%
clust_num = unique(clusters);
f1=figure;
set(f1,'position',[100 100 1500 800])
set(f1, 'color', [1 1 1]);
for i = clust_num

    %7 int
    intensities_mean(i, :, :) = mean(intensities(i == clusters, :, :), 1);
    intensities_sem(i, :, :) = sem(intensities(i == clusters, :, :), 1);

    IR.mean(i, :) = mean(squeeze(intensities_mean(i, :, sus_window)), 2);
    IR.sem(i, :) = sem(squeeze(intensities_mean(i, :, sus_window)), 2);

    clust_count(i) = sum(i == clusters);


    %after:
    intensities_mean2(i, :, :) = mean(intensities2(i == clusters, :, :), 1);
    intensities_sem2(i, :, :) = sem(intensities2(i == clusters, :, :), 1);

    IR2.mean(i, :) = mean(squeeze(intensities_mean2(i, :, sus_window)), 2);
    IR2.sem(i, :) = sem(squeeze(intensities_mean2(i, :, sus_window)), 2);



    if ploting
        subplot(3, clust_num(end), i)
        title(['before injection:      cluster ' num2str(i),   newline num2str(clust_count(i)) ' cells'])
        hold on
        for k = 1:size(intensities_mean, 2)
            plot(smooth(squeeze(intensities_mean(i, k, :))))
        end
        hold off
        legend(num2str(current_cell.x))

        subplot(3, clust_num(end), clust_num(end) + i)
        title('after injection')
        hold on
        for k = 1:size(intensities_mean, 2)
            plot(smooth(squeeze(intensities_mean2(i, k, :))))
        end
        hold off
        legend(num2str(current_cell.x))

        if length(IR.mean(i,:)) > 7
            current_cell.x = [15.4000   14.9000   14.4000   13.9000   13.4000   12.9000   12.4000   11.9000 11.4 9.4 ]
        end
        subplot(3, clust_num(end),clust_num(end)*2 + i)
        errorbar(current_cell.x, IR.mean(i,:),IR.sem(i,:))
        hold on
        errorbar(current_cell.x, IR2.mean(i,:),IR2.sem(i,:))
        hold off

    end
end
