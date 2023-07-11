clear
[file, path] = uigetfile('*.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path
load(datafile)
close all
clc
binsize = 0.1;
downsampling = 5;
nac_colores = {'c','k', 'm', 'r', 'g', 'y'};
dark_colors = {[0.3010 0.7450 0.9330]	 [0 0 0] [0.4940 0.1840 0.5560] [0.6350 0.0780 0.1840]	  [0.4660 0.6740 0.1880]	[0.9290 0.6940 0.1250]	};
f4 = figure;
set(f4,'color', [1 1 1]);
set(f4,'position',[50 50 500 750]);
%%
for i = 1:6
    ax = subplot(3,2,i);
    %ax.Position = [0.1, 0 + (0.3*i), 0.3, 0.3];
    %interpulate before
    cut_end = floor(length(clusters.mean(i, :))/downsampling)*downsampling;
    binned_psth = mean(reshape(clusters.mean(i, 1:cut_end), downsampling, []));
    binned_std = mean(reshape(clusters.std(i, 1:cut_end), downsampling, []));
    binned_ste = mean(reshape(clusters.ste(i, 1:cut_end), downsampling, []));
    
    %interpulate PSTH
    y = 1:length(binned_psth);
    xq = 1:binsize*2:length(binned_psth);
    interpulated_psth = interpn(y, binned_psth, xq, 'linear');
    interpulated_std = interpn(y, binned_std, xq, 'linear');
    interpulated_ste = interpulated_std/sqrt(clusters.num_of_cells(i));
    
    
    plot(1:length(interpulated_psth),interpulated_psth, 'Color', dark_colors{i},'LineWidth',2);
    hold on;

    shadedErrorBar(1:length(interpulated_psth), interpulated_psth, interpulated_ste,'lineprops', nac_colores{i});
    ylim([-4 6]);
    xlim([0 length(interpulated_psth)]);
    set(gca,'FontSize',14);
    set(gca,'XColor', 'none','YColor','none')
    
    text(80, 3, ['n = ',num2str(clusters.num_of_cells(i))], 'FontSize',15, 'FontWeight','bold');
    plot([30 30],[-4 8],'--k');
    plot([130 130],[-4 8],'--k');
    %plot([0 0], [1 6], 'k', 'LineWidth', 4)
%     plot([30 130], [-2 -2], 'k', 'LineWidth', 4)
    patch([30 130 130 30],[-4 -4 7.5 7.5], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.1, 'EdgeColor', 'none' )
    box off
    hold off
    
end

%% plot dms in row
set(f4,'position',[50 50 1500 250]);

counts = 0 ;
for i = 6:-1:1
    counts = counts + 1;
    ax = subplot(1,6,counts);
    %ax.Position = [0.1, 0 + (0.3*i), 0.3, 0.3];
    %interpulate before
    cut_end = floor(length(clusters.mean(i, :))/downsampling)*downsampling;
    binned_psth = mean(reshape(clusters.mean(i, 1:cut_end), downsampling, []));
    binned_std = mean(reshape(clusters.std(i, 1:cut_end), downsampling, []));
    binned_ste = mean(reshape(clusters.ste(i, 1:cut_end), downsampling, []));
    
    %interpulate PSTH
    y = 1:length(binned_psth);
    xq = 1:binsize*2:length(binned_psth);
    interpulated_psth = interpn(y, binned_psth, xq, 'linear');
    interpulated_std = interpn(y, binned_std, xq, 'linear');
    interpulated_ste = interpulated_std/sqrt(clusters.num_of_cells(i));
    
    
    plot(1:length(interpulated_psth),interpulated_psth, 'Color', dark_colors{i},'LineWidth',2);
    hold on;

    shadedErrorBar(1:length(interpulated_psth), interpulated_psth, interpulated_ste,'lineprops', nac_colores{i});
    ylim([-5 6.8]);
    xlim([0 length(interpulated_psth)]);
    set(gca,'FontSize',14);
    set(gca,'XColor', 'none','YColor','none')
    
    text(80, 3, ['n = ',num2str(clusters.num_of_cells(i))]);
    plot([30 30],[-4 8],'--k');
    plot([130 130],[-4 8],'--k');
    %plot([0 0], [1 6], 'k', 'LineWidth', 4)
%      plot([30 130], [-5 -5], 'k', 'LineWidth', 4)
    patch([30 130 130 30],[-4 -4 7.5 7.5], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.1, 'EdgeColor', 'none' )
    box off
    hold off
end
%%
f4 = figure;
set(f4,'color', [1 1 1]);
types = {'unresponsive 2', 'unresponsive 1', 'ON', 'ON-OFF', 'ON transient', 'ON suppressed OFF'};
set(f4,'position',[50 50 500 750]);

Position = {[0.1, 1 - (0.3*1), 0.4, 0.3], [0.6, 1 - (0.3*1), 0.4, 0.3], [0.1, 1 - (0.3*2), 0.4, 0.3], [0.6, 1 - (0.3*2), 0.4, 0.3], [0.1, 1 - (0.3*3), 0.4, 0.3], [0.6, 1 - (0.3*3), 0.4, 0.3]};

counts = 0 ;
for i = 6:-1:1
    counts = counts + 1;

%     Position = [0.1, 1 - (0.3*counts), 0.4, 0.3];
        
    subplot('position', Position{counts})

    %interpulate before
    cut_end = floor(length(clusters.mean(i, :))/downsampling)*downsampling;
    binned_psth = mean(reshape(clusters.mean(i, 1:cut_end), downsampling, []));
    binned_std = mean(reshape(clusters.std(i, 1:cut_end), downsampling, []));
    binned_ste = mean(reshape(clusters.ste(i, 1:cut_end), downsampling, []));
    
    %interpulate PSTH
    y = 1:length(binned_psth);
    xq = 1:binsize*2:length(binned_psth);
    interpulated_psth = interpn(y, binned_psth, xq, 'linear');
    interpulated_std = interpn(y, binned_std, xq, 'linear');
    interpulated_ste = interpulated_std/sqrt(clusters.num_of_cells(i));
    
    
    plot(1:length(interpulated_psth),interpulated_psth, 'Color', dark_colors{i},'LineWidth',2);
    hold on;

    shadedErrorBar(1:length(interpulated_psth), interpulated_psth, interpulated_ste,'lineprops', nac_colores{i});
    xlim([0 length(interpulated_psth)]);
    set(gca,'FontSize',6);
    set(gca,'XColor', 'none','YColor','none')
    
    text(50, 4, ['n = ',num2str(clusters.num_of_cells(i))], 'FontSize',15, 'FontWeight','bold');
    text(32, 6, types{i}, 'FontSize',15, 'FontWeight','bold')
    plot([30 30],[-4 9],'--k');
    plot([130 130],[-4 9],'--k');
        ylim([-4 6.5])

    plot([10 10], [1 3], 'k', 'LineWidth', 4)
    
   if i == 1 || i == 2
        plot([30 130], [-4 -4], 'k', 'LineWidth', 4)
        text(40, -5, '10 sec', 'FontSize',15, 'FontWeight','bold')
   end
   if i == 6
      
       plot([10 10], [2 7], 'k', 'LineWidth', 4)
   end
           patch([30 130 130 30],[-4 -4 7.5 7.5], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.1, 'EdgeColor', 'none' )

    box off
    hold off
end
