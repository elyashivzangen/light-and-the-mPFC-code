%% plot pupil deluted VS regular

X = all_data;
 
nac_3 = [4 6 26];
nac_5  = [13 37 48 108 115];
nac_2 = [49 131];

cluster_6 = [17 96 98 99 103 127];
cluster_1 = [92 104 106 109 115];
delay = 1.1;
%%
Y = nac_5;
regular = [];
pupil = [];
for i = 1:length(Y)
    cell_name = (['cell_' num2str(Y(i))]);
    
    
    regular(i, :) = X{1, 1}.(cell_name).intensities(6).psth.mean; % /max(abs(X{1, 1}.(cell_name).intensities(6).psth.mean));
    pupil(i, :) = X{1, 2}.(cell_name).intensities(6).psth.mean; %/max(abs(X{1, 2}.(cell_name).intensities(6).psth.mean));
%     

%     plot(regular(i, :))
%     hold on
%     plot(pupil(i, :))
end

figure
mean_regular = mean(regular,1);
regular_ste = std(regular,1)/size(regular,1);
mean_pupil = mean(pupil ,1);
pupil_ste = std(pupil,1)/size(pupil,1);
    
  mean_pupil = bin_psth(mean_pupil, 4);
  mean_regular = bin_psth(mean_regular, 4);
  pupil_ste = bin_psth(pupil_ste, 4);
  regular_ste = bin_psth(regular_ste, 4);
  plot(smooth(mean_pupil),'r', 'LineWidth',2)

hold on
plot(smooth(mean_regular),'b', 'LineWidth',2)
%  plot(mean_regular, 'LineWidth',2)
shadedErrorBar(1:length(mean_regular), smooth(mean_regular), smooth(regular_ste),'lineprops', 'b')

shadedErrorBar(1:length(mean_pupil), smooth(mean_pupil), smooth(pupil_ste), 'lineprops', 'r')

%  plot(mean_pupil, 'LineWidth',2)
title('ON-OFF')
subtitle(['n = ' num2str(length(Y))])
% set(gca,'XColor', 'none','YColor','none')
    
%     text(50, 9, ['n = ',num2str(clusters.num_of_cells(I(i)))], 'FontSize',15, 'FontWeight','bold');
%     text(135, 7, cluster_names{i}, 'FontSize',15, 'FontWeight','bold');
%      title(cluster_names{i}, 'FontSize',15, 'FontWeight','bold');

    plot([30+delay 30+delay],[-5 15],'--k');
    plot([130+delay 130+delay],[-5 15],'--k');
%       plot([30 130], [-2 -2], 'k', 'LineWidth', 4)
%     box off
    patch([30+delay 130+delay 130+delay 30+delay],[-5 -5 15 15], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.1, 'EdgeColor', 'none' )
    ylim([-2.5 12]);
    xlim([0 195]);

legend('Dilated pupil','Basline',  'FontSize',15, 'FontWeight','bold')