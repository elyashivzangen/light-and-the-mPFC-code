data = clusters.matrix;

x = find(cell2mat(data(:,4)) == 4);

for i = 1:length(x)
    psth = cell2mat(data(x(i),5:end));
    figure
    plot(psth)
    hold on
    plot([30 30],[-5 9],'--k');
    plot([130 130],[-5 9],'--k');
    title(data{x(i),1})
end