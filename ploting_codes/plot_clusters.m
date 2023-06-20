%%
clear
[file, path] = uigetfile('*.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path
load(datafile)
close all
clc
delay = 1.16;
%%
%sort clusters by size
[~, I] = sort(clusters.num_of_cells, 'descend')

binsize = 0.1;
downsampling = 5;
nac_colores = {'c', 'm', 'r', 'g'	, 'y', 'y'};
dark_colors = {[0.3010 0.7450 0.9330] [0.4940 0.1840 0.5560] [0.6350 0.0780 0.1840]	  [0.4660 0.6740 0.1880]	[0.9290 0.6940 0.1250]	[0.9290 0.6940 0.1250]};
% cluster_names = {'ON trsnsient', 'OFF trsnsient', 'ON-OFF', 'ON sustained', 'ON suppressed OFF'};
cluster_names = {'ON trsnsient', 'OFF trsnsient', 'ON-OFF', 'ON sustained', 'ON suppressed OFF'};

f4 = figure;
set(f4,'color', [1 1 1]);
%  set(f4,'position',[50 50 400 1000]);
set(f4,'position',[50 50 250*size(clusters.mean, 1)  250]);

for i =  1:6 %1:size(clusters.mean, 1)    
%     subplot('Position'  ,[0.1 1-0.2*i 0.55 0.2]);
    subplot(1, size(clusters.mean, 1) , i)

    %     plot((1:3))

    hold off
    %plot(1:length(interpulated_psth),interpulated_psth, 'Color', dark_colors{i},'LineWidth',2);

    patch([30+delay 130+delay 130+delay 30+delay],[-1.7 -1.7 11 11], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.1, 'EdgeColor', 'none' )
    %interpulate before
    cut_end = floor(length(clusters.mean(I(i), :))/downsampling)*downsampling;
    binned_psth = mean(reshape(clusters.mean(I(i), 1:cut_end), downsampling, []));
    binned_std = mean(reshape(clusters.std(I(i), 1:cut_end), downsampling, []));
    binned_ste = mean(reshape(clusters.ste(I(i), 1:cut_end), downsampling, []));
    
    %interpulate PSTH
    y = 1:length(binned_psth);
    xq = 1:binsize*2:length(binned_psth);
    interpulated_psth = interpn(y, binned_psth, xq, 'linear');
    interpulated_std = interpn(y, binned_std, xq, 'linear');
    interpulated_ste = interpulated_std/sqrt(clusters.num_of_cells(I(i)));
    
    
    
    shadedErrorBar(1:length(interpulated_psth), interpulated_psth, interpulated_ste,'lineprops', nac_colores{i});
    hold on;
    
    plot(1:length(interpulated_psth),interpulated_psth, 'Color', dark_colors{i},'LineWidth',2);
    
    ylim([-4 15]);
    xlim([0 length(interpulated_psth)]);
%     set(gca,'FontSize',14);
    set(gca,'XColor', 'none','YColor','none')
    
    text(50, 9, ['n = ',num2str(clusters.num_of_cells(I(i)))], 'FontSize',15, 'FontWeight','bold');
%     text(135, 7, cluster_names{i}, 'FontSize',15, 'FontWeight','bold');
     title(cluster_names{i}, 'FontSize',15, 'FontWeight','bold');

    plot([30+delay 30+delay],[-1.7 11],'--k');
    plot([130+delay 130+delay],[-1.7 11],'--k');
%       plot([30 130], [-2 -2], 'k', 'LineWidth', 4)
    box off
    %     hold off
    
end

%% ploting in a row
for i = 6:-1:1
    subplot(1,6,i);
    %     plot((1:3))
    hold off
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
    
    ylim([-2.9 8]);
    xlim([0 length(interpulated_psth)]);
    set(gca,'FontSize',14);
    set(gca,'XColor', 'none','YColor','none')
    
    %text(80, 3, ['n = ',num2str(clusters.num_of_cells(i))]);
    plot([30 30],[-3 8],'--k');
    plot([130 130],[-3 8],'--k');
    %plot([10 10], [1 6], 'k', 'LineWidth', 4)
    %plot([30 130], [-2 -2], 'k', 'LineWidth', 4)
    %patch([30 130 130 30],[-2.9 -2.9 7.5 7.5], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.1, 'EdgeColor', 'none' )
    box off
    hold off
    
end

%%
