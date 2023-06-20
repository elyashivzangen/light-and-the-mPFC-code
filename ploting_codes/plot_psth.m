data = clusters.cluster_cells.cluster_2{15}.intensities;
%%
%bin and interpulate
plot(data(1).psth.mean)




%%
for i = 1:clusters.num_of_cells(2)
    psth = clusters.cluster_cells.cluster_2{i}.intensities(1).psth.mean;
    interpulated_psth(i, :) = bin_psth(psth, 5);
    mximum_psth(i) = max(abs(interpulated_psth(i, :)));
    %     figure
    %     plot(interpulated_psth)
end
[a, b] = max(mximum_psth)
%% plot PSTH
nac_colores = {'c', 'm', 'r', 'g', 'y', 'k', 'm'	};
% f4 = figure;
% set(f4,'color', [1 1 1]);
% set(f4,'position',[50 50 500 750]);
% for i = 1:36
    figure
    for j = 1:size(clusters.cluster_cells.cluster_2{i}.intensities, 2)
        interpulated_PSTH(j, :) = bin_psth(clusters.cluster_cells.cluster_2{16}.intensities(j).psth.mean, 5);
        interpulated_STE(j, :) = bin_psth(clusters.cluster_cells.cluster_2{16}.intensities(j).psth.std/sqrt(20), 5);
%         shadedErrorBar(1:length(interpulated_PSTH), interpulated_PSTH, interpulated_STE, 'patchSaturation',0.33, 'transparent',1);
%         hold on
    
%         plot(interpulated_PSTH, 'LineWidth',2)
    end
    shadedErrorBar(1:size(interpulated_PSTH,2), interpulated_PSTH, interpulated_STE, 'patchSaturation',0.33, 'transparent',1);

    plot([30 30],[-3 8],'--k');
    plot([130 130],[-3 8],'--k');
    %plot([10 10], [1 6], 'k', 'LineWidth', 4)
    %plot([30 130], [-2 -2], 'k', 'LineWidth', 4)
    patch([30 130 130 30],[-2.9 -2.9 7.5 7.5], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.1, 'EdgeColor', 'none' )
    box off
    hold off
% end