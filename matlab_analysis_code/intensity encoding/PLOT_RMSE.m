for n =1:3
cells = fieldnames(all_data);
for j = 1:length(cells)
    current_cell = all_data.(cells{j});
    x = current_cell.x;
    y = current_cell.new_fit(n).y;
    curve1 = current_cell.new_fit(n).original_curve;
    gof1 = current_cell.new_fit(n).original_gof;
    original_rmse = current_cell.new_fit(n).original_rmse;
    P10 = current_cell.new_fit(n).P10_mean;
    shuffle_rmse = current_cell.new_fit(n).shuffle_rmse;
    f1=figure;
    set(f1,'position',[200 200 800 300])
    set(f1, 'color', [1 1 1]);
    subplot(1,2,1);
    hold on;
    plot(x,y,'o');
    plot(curve1,'m');
    legend off
    title(['rmse = ',num2str(gof1.rmse),'   n = ',num2str(curve1.n)]);


    subplot(1,2,2);
    hold on;
    histogram(shuffle_rmse,10);
    plot([P10 P10],[0 50],'-k');
    plot([original_rmse original_rmse],[0 50],'-m','LineWidth',2);
    legend off
    title(['rmse 5th percentile = ',num2str(P10),'   original rmse = ',num2str(original_rmse)]);
end
end
