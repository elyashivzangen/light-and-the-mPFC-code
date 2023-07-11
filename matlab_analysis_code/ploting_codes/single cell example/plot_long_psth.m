data = all_data.cell_4.intensities;
x = data(1).intensty_data
x = x - data(1).intensty_baseline.mean
y = reshape(x,[], 1)
binned_y = bin_psth(y, 10);
%%
f4 = figure;

set(f4,'color', [1 1 1]);
set(f4,'position',[50 50 2000 250]);
plot(binned_y, 'LineWidth', 3)
hold on
for i = 1:20


%     plot([30 30],[-3 8],'--k');
%     plot([130 130],[-3 8],'--k');
%     plot([10 10], [1 6], 'k', 'LineWidth', 4)
    %plot([30 130], [-2 -2], 'k', 'LineWidth', 4)
    patch(([30 130 130 30] + 200*(i-1)),[-15 -15 20 20], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.5, 'EdgeColor', 'none' )
    box off
end
set(gca,'XColor', 'none','YColor','none')

