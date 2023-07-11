clear
clc
[file, path] = uigetfile('clusters.mat','MultiSelect','off');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
load(datafile)
close all
%%
int_colores = {'c','k', 'm', 'r', 'g', 'y', 'b'};

for w = 1:size(clusters.mean, 1)
    cluster_name = ['cluster_' num2str(w)];
    data = clusters.cluster_cells.(cluster_name);
    for i = 1:(length(data) - 1)
        f1=figure;
        set(f1,'position',[200 200 1000 500])
        set(f1, 'color', [1 1 1]);
        %plot fit
         subplot(1,2,2);
         hold on;
         fd = data{1, i}.new_fit3(2);
         plot(data{1, i}.x,fd.y,'o');
         plot(fd.original_curve,'m');
         legend off
         title(['R^2 = ',num2str(fd.original_gof.rsquare)]);
        %plot all intensiteis
        subplot(1,2,1);
        count = 0;
        x = data{1, i}.intensities;
        for j = 1:length(x)
            if ~isempty(x(j).psth)
                count = count + 1;
                int_data = x(j).intensty_data;
                baseline = mean(int_data(1:30, :), 'all');
                int_data = int_data - baseline;
                smoothed = reshape(bin_psth(int_data(:),10), [], size(int_data, 2)) ;
                psth = mean(smoothed, 2);
                ste = sem(smoothed, 2);
                shadedErrorBar(1:length(psth),psth, ste, 'lineprops', int_colores{count}, 'patchSaturation',0.1, 'transparent',1);
                hold on
            end
        end
        legend(num2str(data{1, i}.x))
        title([cluster_name ' cell ' num2str(i)])
        export_fig('ir_by_cluster.tif','-Append')
        close all

    end
end