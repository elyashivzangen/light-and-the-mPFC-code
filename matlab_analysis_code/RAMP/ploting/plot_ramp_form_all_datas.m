% plot ramp from all_data
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
w = 2;% window for ploting (2 = sustaneid)
%%
for i = 1:length(datafile)
    load(datafile{1,i});
    %     all_data = all_data.all_data;
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        current_cell = all_data.(cells{j});
        if current_cell.new_fit3(w).isIntEncoding && ~current_cell.Is_reponsive(w)
            f1=figure;
            set(f1,'position',[200 200 1000 500])
            set(f1, 'color', [1 1 1]);
            subplot(1,2,1);
            for k = 1:length(current_cell.intensities)
                if isempty( current_cell.intensities(k).intensty_data )
                    continue
                end
                plot(bin_psth(current_cell.intensities(k).psth.mean, 10))
                hold on
                legend(num2str(current_cell.x))
            end
            title(['pvalue = ',num2str(current_cell.pval_table(w, 3)) ' baseline = ' num2str(mean(current_cell.baseline_vector.mean))]);

            subplot(1,2,2);
            hold on;
            fd = current_cell.new_fit3(2);
            plot(current_cell.x,fd.y,'o');
            plot(fd.original_curve,'m');
            legend off
            title(['rmse = ',num2str(fd.original_rmse),'   n = ',num2str(fd.original_curve.n), 'P10 = ',num2str(fd.P10_mean), file{i}, cells{j}]);
            exportgraphics(f1,'ir_not_responsive2.pdf','Append',true)
            close all
        end
    end
end