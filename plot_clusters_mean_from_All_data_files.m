% plot clusters from all data file WITH IR
clear
clc
ploting =1 ;
window = 2; %(on, sus, off)
sus_window = 650:1250;
 nd2reduce= [9;7;5];
%%
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%%
counts = 0;
for i = 1:length(datafile)
    load(datafile{1,i});
    %     all_data = all_data.all_data;
    if iscell(all_data)
        all_data = all_data{1};
    end
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        current_cell = all_data.(cells{j});
        if current_cell.Is_reponsive_and_IR(window)
            counts = counts + 1;
            clusters(counts) = current_cell.cluster;
           
            int_num = 0;
            if length(current_cell.intensities) > 7
            current_cell.intensities(nd2reduce) = [];
            end
            for k = 1:length(current_cell.intensities)
                if ~isempty(current_cell.intensities(k).psth)
                    int_num = int_num  + 1;
                    intensities(counts, int_num, :) = current_cell.intensities(k).psth.mean;
                end
            end
        end
    end
end

%%
clust_num = unique(clusters);
f1=figure;
set(f1,'position',[100 100 800 500])
set(f1, 'color', [1 1 1]);
for i = clust_num  
    
    %7 int
    intensities_mean(i, :, :) = mean(intensities(i == clusters, :, :), 1);
    intensities_sem(i, :, :) = sem(intensities(i == clusters, :, :), 1);
    
    IR.mean(i, :) = mean(squeeze(intensities_mean(i, :, sus_window)), 2);
    IR.sem(i, :) = sem(squeeze(intensities_mean(i, :, sus_window)), 2);

    clust_count(i) = sum(i == clusters);


    if ploting
        subplot(3, clust_num(end), i)
        title(['cluster ' num2str(i),   newline num2str(clust_count(i)) ' cells'])
        hold on
        for k = 1:size(intensities_mean, 2)
            plot(smooth(squeeze(intensities_mean(i, k, :))))
        end
        hold off
        legend(num2str(current_cell.x))

        subplot(3, clust_num(end),clust_num(end) + i)
        errorbar(current_cell.x, IR.mean(i,:),IR.sem(i,:))

        
        subplot(3, clust_num(end),clust_num(end)*2 + i)
        plot(squeeze(intensities_mean(i, 1, :)))
        hold on
        %plot(smooth(squeeze(intensities_mean(i, 1, :)),3), 'LineWidth',1)

        title("ND = 1")
    end
end
savefig("psth_And_ir_all_clusters")
exportgraphics(f1, "psth_And_ir_all_clusters.tif")

%% save parameters and plots
save("psth_mean","intensities_mean")
save("psth_sem","intensities_sem")
save("IR_data", 'IR')
