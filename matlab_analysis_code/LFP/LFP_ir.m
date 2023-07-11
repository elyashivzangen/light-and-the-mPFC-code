%clculate IR for LFP
mkdir('LFP_ir')
cd('LFP_ir')
%%
time = -2.999:0.001:16.001';
binsize = 1000;
x = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];

st = fieldnames(meanLFP);
for i = 1:length(st)
    f1 = figure;
    f1.Position = [100, 100, 1500, 600];
    T = meanLFP.(st{i});
    for j = 1:7
        lp = meanLFP.(st{i}){1, j+1};
        
        
        [p1, p1t] = max(lp(3001:3170));
        [t, tt] = min(lp(3171:3200));
        tt = tt+170;
        [p2, p2t] = max(lp((3001+tt):3300));
        p2t = p2t + tt;
        

        peak1time(j,1) = p1t/binsize;
        peak2time(j,1) = p2t/binsize;
        trough_time(j,1) = tt/binsize;
        
        trough(j,1) = t;
        peak1(j,1) = p1;
        peak2(j,1) = p2;
        amplitude(j,1) =  (t - p2)*-1;
                        
        subplot(2,4, j)
        plot(time, lp)
        xlim([0,0.3])
        hold on
        scatter(peak1time(j), p1)
        scatter(trough_time(j),t)
        scatter(peak2time(j),p2)
        title(T.Properties.VariableNames{j+1}, 'Interpreter','none')
        subtitle(['amplitude: ' num2str(amplitude(j,1))]);
    end
    subplot(2,4, 8)
    plot(flip(x), amplitude, '-o')
    title('amplitude ir')
    sgtitle(st{i})
    savefig(f1, [st{i}])
    exportgraphics(f1,'all_figs.pdf','Append',true)
    all_parameters.(st{i}) = table(amplitude, peak1, peak1time,trough, trough_time, peak2, peak2time);
end
save('all_parameters_table', 'all_parameters')
