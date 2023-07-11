data =cell_data.intensities(1).intensty_data;
data = data(:);

interpulated_psth = bin_psth(data, 2);

f4 = figure;
set(f4,'position',[50 50 2000  250]);

plot(interpulated_psth)
hold on
for i = 1:40
    plot([(-70 + 100*i) (-70 + 100*i)],[0 65],'--k');
end
for j = 1:20
    patch([(30 + 200*(j-1))  (130+ 200*(j-1)) (130+ 200*(j-1)) (30 + 200*(j-1))],[0 0 65 65], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.1, 'EdgeColor', 'none' )
end