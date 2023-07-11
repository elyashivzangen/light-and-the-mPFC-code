[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
old_int_encoding = [];
new_int_encoding = [];
all_cells = 0;
for i = 1:length(datafile)
    load(datafile{1,i});
    %all_data = all_data.all_data;
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        current_cell = all_data.(cells{j}).fit_data;
        old_int_encoding = [old_int_encoding current_cell.on.isIntEncoding_mean];
        new_int_encoding = [new_int_encoding current_cell.on.isIntEncoding];
        all_cells = all_cells + 1;
        figure
        plot(current_cell.on.x, current_cell.on.y + abs(min(current_cell.on.y)), 'o')
        hold on
        x = current_cell.on.x;
        y = current_cell.on.y;
        fo = fitoptions('Method','NonlinearLeastSquares',...
            'Algorithm','Trust-Region',...
            'Display','final',...
            'TolFun',1.0E-20,...
            'TolX',1.0E-20,...
            'Lower',[-1,min(x),-2],...
            'Upper',[2*max(y),max(x),2],...
            'StartPoint',[max(y),mean(x),0]);

        ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
        [curve1,gof1]=fit(current_cell.on.x, (current_cell.on.y + abs(min(current_cell.on.y))),ft);

        x = current_cell.on.intensities;
        y = current_cell.on.IR.mean';

        fo = fitoptions('Method','NonlinearLeastSquares',...
            'Algorithm','Trust-Region',...
            'Display','final',...
            'TolFun',1.0E-20,...
            'TolX',1.0E-20,...
            'Lower',[-1,min(x),-2],...
            'Upper',[2*max(y),max(x),2],...
            'StartPoint',[max(y),mean(x),0]);

        ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
        [curve2,gof2]=fit(current_cell.on.intensities, current_cell.on.IR.mean' + current_cell.on.shift ,ft);

        plot(curve1)
        plot(curve2, 'm')
        scatter(current_cell.on.intensities, current_cell.on.IR.mean + current_cell.on.shift, 'magenta')
        title(['rmse: ', num2str(current_cell.on.original_rmse)])
        subtitle([ 'P10: ' num2str(current_cell.on.P10)])
    end
end
bar([sum(old_int_encoding)/all_cells, sum(new_int_encoding)/all_cells])
