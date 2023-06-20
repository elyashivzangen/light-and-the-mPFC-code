clear
close all
clc
%%

[file, path] = uigetfile('*.mat','MultiSelect','off');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
cell_num = (inputdlg("cell_numebr"));
cell_name = ['cell_' cell_num{1}];

%%
load(file)
cluster_num = file(1:(end-4));
mkdir (cluster_num)
cd(cluster_num)
cell_data = all_data.(cell_name); %relevant_cell
response_window = 65:125;
ploting = 0;

mkdir(cell_name)
cd(cell_name)
% cell_data = clusters.cluster_cells.cluster_3{1,31};
%% calculate PSTH all int

count = 0;
for j = 1:size(cell_data.intensities, 2)
        if ~isempty(cell_data.intensities(j).psth)            
            count = count + 1;
            baseline =  mean(cell_data.intensities(j).intensty_data(1:30,:), "all");
            psth(count, :) = cell_data.intensities(j).psth.mean;
            STE(count, :) = sem(cell_data.intensities(j).intensty_data, 2);
            rep_IR = mean(cell_data.intensities(j).intensty_data(response_window, :), 1);
            IR.mean(count) = mean(rep_IR) - baseline;
            IR.ste(count) = sem(rep_IR, 2);
        end
 end
 %% plot binned psth - bin after calculating the psth 
%
% %bin PSTH 
% binned_psth = [];
% for i = 1:size(psth,1)
%     binned_psth(i, :) = bin_psth(psth(i,:), n);
%     binned_STE(i, :) = bin_psth(STE(i,:), n);
% end


%% calculate PSTH alredy binned (bin before calculating std)
count = 0;
 n = 10;%number to downsample
 for j = 1:size(cell_data.intensities, 2)
        if ~isempty(cell_data.intensities(j).psth)            
            count = count + 1;
            binned_intensty_data = reshape(bin_psth(cell_data.intensities(j).intensty_data(:), 10), [], size(cell_data.intensities(j).intensty_data, 2)) - mean(cell_data.intensities(j).intensty_data(1:30,:),'all');
            binned_psth(count, :) = mean(binned_intensty_data, 2);
            binned_STE(count, :) = sem(binned_intensty_data, 2);
        end
 end
 if ploting

f1 = figure;
plot(binned_psth')
hold on
title(' binned psth')
plot([30 30],[-20 20],'--k');
plot([130 130],[-20 20],'--k');
%plot([10 10], [1 6], 'k', 'LineWidth', 4)
%plot([30 130], [-2 -2], 'k', 'LineWidth', 4)
patch([30 130 130 30],[-20 -20 20 20], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.1, 'EdgeColor', 'none' )
xlim([0 length(binned_psth)])
ylim([min(binned_psth,[], 'all') max(binned_psth,[], 'all')])
box off
hold off
legend(string(cell_data.x))
export_fig('all_figs.tif', '-append')
 end
%% plot BASIC PSTH
if ploting
f2 = figure;
plot(psth')
hold on
title('basic psth')
plot([30 30],[-20 20],'--k');
plot([130 130],[-20 20],'--k');
%plot([10 10], [1 6], 'k', 'LineWidth', 4)
%plot([30 130], [-2 -2], 'k', 'LineWidth', 4)
patch([30 130 130 30],[-20 -20 20 20], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.1, 'EdgeColor', 'none' )
xlim([0 length(psth)])
ylim([min(psth,[], 'all') max(psth,[], 'all')])
box off
hold off
legend(string(cell_data.x))
export_fig('all_figs.tif', '-append')
savefig(f2, "basic_psth_fig")
savefig(f1, 'binned_psth_fig')



end

IR.intensities = cell_data.x;
save("all_cell_data", "cell_data")
save([num2str(n) '_binned_psth_with_ste'],"binned_STE","binned_psth")
save("psth_and_ste", "psth", "STE")
fit_data = cell_data.new_fit3(2);
save("fit_data", "fit_data")
save("IR", "IR")

%% plot with shadedd arror bars
if ploting
f3 = figure;
int_colores = {'c','k', 'm', 'r', 'g', 'y', 'b'};
for i = 1:size(psth,1)
    shadedErrorBar(1:length(binned_psth),binned_psth(i, :), binned_STE(i, :), 'lineprops', int_colores{i}, 'patchSaturation',0.1, 'transparent',1);
end
hold on
title(' binned psth')
plot([30 30],[-20 20],'--k');
plot([130 130],[-20 20],'--k');
%plot([10 10], [1 6], 'k', 'LineWidth', 4)
%plot([30 130], [-2 -2], 'k', 'LineWidth', 4)
patch([30 130 130 30],[-20 -20 20 20], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.1, 'EdgeColor', 'none' )
xlim([0 length(binned_psth)])
ylim([min(binned_psth,[], 'all') max(binned_psth,[], 'all')])
box off
hold off
legend(string(cell_data.x))
savefig(f3, 'binned_psth_with_error_Bar')
export_fig('all_figs.tif', '-append')

%% plot fit
f4 = figure;
hold on
plot(cell_data.x,fit_data.y,'o');
plot(fit_data.original_curve,'m');
legend off   
title(['rmse = ',num2str(fit_data.original_rmse),'   n = ',num2str(fit_data.original_curve.n), '   P10 = ',num2str(fit_data.P10_mean)]);
export_fig('all_figs.tif', '-append')
end
cd ..
cd ..
