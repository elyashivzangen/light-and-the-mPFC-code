x = clusters.mean;
n = 4;
%% calculate new sem
data_matrix = cell2mat(clusters.matrix(:, 5:end));
s_data_matrix = smoothdata(data_matrix, 2,"sgolay", 4);
for i = 1:n
    data_sem(i,:) = sem(s_data_matrix(cell2mat(clusters.matrix(:, 4)) == i,:), 1);
end

f4 = figure;
set(f4,'color', [1 1 1]);
set(f4,'position',[50 50 1250 300]);

for i =1:n
    subplot(1,4,i)
    hold on
    y(i, :) = smoothdata(x(i,:), 'sgolay',4);
%     plot(x(i,:))
    shadedErrorBar(1:length(y), y(i,:), data_sem(i,:))
    plot(y(i,:), 'LineWidth',2)

end