clear
clc
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\new_ramp\ramp_statistics')
% save('all_ramps_table',"T")
T = importdata("all_ramps_table.mat");

T.mean_ramp = T.mean_ramp(:,1:120)
T.norm_ramp = T.mean_ramp - mean(T.mean_ramp(:,1:10),2);

T.short_ramp = T.norm_ramp(:,31:90);
for i = 1:length(T.mean_ramp)
    binned_psth(i,:) = bin_psth(T.norm_ramp(i,:),2);
end
T.binned_psth = binned_psth;
T.short_binned = binned_psth(:,31:90);
T.mag = T.norm_ramp./mean(T.mean_ramp(:,1:10),2);
T.short_mag = T.mag(:,31:90);
IE = T(find(T.is_responsive_and_ir),:);
save("IE ramp", "IE")

%% plot
g1 = grpstats(IE,"cluster","mean")

plot(g1.mean_abs_ramp')
plot(g1.mean_mean_ramp')
plot(g1.mean_short_ramp')
plot(g1.mean_norm_ramp')
%% calculate time of drift
% IE.norm_ramp = IE.short_ramp - IE.baseline
t1 = IE;

% t1.is_enhanced =
[max_response, peek] = max((t1.short_mag(:,16:45)),[],2);
[min_response, trough] = min((t1.short_mag(:,16:45)),[],2);
t1.peek = peek;
t1.is_enhanced = ismember(t1.cluster, [2,4])
t1.peek(~t1.is_enhanced) = trough(~t1.is_enhanced);
t1.peek = t1.peek + 15;
t1.max_response = max_response;
t1.max_response(~t1.is_enhanced) =min_response(~t1.is_enhanced);
g1 = grpstats(t1, "cluster","mean")

% [rho, pba] = corr(t1.peek(t1.cluster == 1)-31,t1.max_response(t1.cluster == 1))
% [rho, pba] = corr(t1.peek(t1.cluster == 2)-31,t1.max_response(t1.cluster == 2))
% [rho, pba] = corr(t1.peek(t1.cluster == 3)-31,t1.max_response(t1.cluster == 3))
% [rho, pba] = corr(t1.peek(t1.cluster == 4)-31,t1.max_response(t1.cluster == 4))
%
% [rho, pba] = corr(t1.peek(~t1.is_enhanced),t1.max_response(~t1.is_enhanced))
% [rho, pba] = corr(t1.peek(t1.is_enhanced),t1.max_response(t1.is_enhanced))


%%
for i = 1:4
    subplot(2,2,i)
    plot(g1.mean_short_ramp(i,:))
    hold on
    xline(g1.mean_peek(i))
    title(i)
end


%%
for i = 1:size(t1,1)

    f1 = figure;
    plot(t1.ramp(i,:))
    hold on
    xline(t1.peek(i))
    title(['cluster ' num2str(t1.cluster(i))])
end
%%
for i = 1:4
    [p(i), t_orig, crit_t] = mult_comp_perm_t1(t1.peek(t1.cluster == i)-30,10000,1)
end
% permutationTest(t1.peek-30,10000, "")
[h,p,ci,stats] = ttest(t1.peek,30)

%%
t1.acending = abs(mean(t1.short_ramp(:,24:30),2));
t1.decending = abs(mean(t1.short_ramp(:,31:37),2));
% t1.curve1 = [];
%  t1.gof1 = [];
t1.diff = t1.acending - t1.decending

g1 = grpstats(t1, "cluster","mean");
for i = 1:4
    p_per_cluster(i) = mult_comp_perm_t1(t1.acending(t1.cluster == i)-t1.decending(t1.cluster == i),100000,-1)
    x2 = mes(t1.acending(t1.cluster == i),t1.decending(t1.cluster == i),'hedgesg')
    effect_size_per_cluster(i) = abs(x2.hedgesg)

%     [p(i), ~, d(i)] = permutationTest(t1.acending(t1.cluster == i)-t1.decending(t1.cluster == i),100000)
end
p_all = mult_comp_perm_t1(t1.acending-t1.decending,10000,-1)
x2 = mes(t1.acending,t1.decending,'hedgesg');
effect_size_all = abs(x2.hedgesg);


g4 = grpstats(t1,"is_responsive_and_ir","mean")
p_enhanced = mult_comp_perm_t1(t1.acending(t1.is_enhanced)-t1.decending(t1.is_enhanced),100000,-1)
p_suppressed = mult_comp_perm_t1(t1.acending(~t1.is_enhanced)-t1.decending(~t1.is_enhanced),100000,-1)
x2 = mes(t1.acending(t1.is_enhanced),t1.decending(t1.is_enhanced),'hedgesg');
effect_size_enhanced(1,1) = abs(x2.hedgesg);
x2 = mes(t1.acending(~t1.is_enhanced),t1.decending(~t1.is_enhanced),'hedgesg');
effect_size_enhanced(2,1) = abs(x2.hedgesg);





g2 = grpstats(t1,"is_enhanced","mean")

p_on = mult_comp_perm_t1(t1.acending(ismember(t1.cluster, [3,4]))-t1.decending(ismember(t1.cluster, [3,4])),100000,-1)
p_on_off = mult_comp_perm_t1(t1.acending(ismember(t1.cluster, [1,2]))-t1.decending(ismember(t1.cluster, [1,2])),100000,-1)
t1.is_on_off = ismember(t1.cluster, [1,2]);

x2 = mes(t1.acending(ismember(t1.cluster, [3,4])),t1.decending(ismember(t1.cluster, [3,4])),'hedgesg')
effect_size_on(1,1) = abs(x2.hedgesg);
x2 = mes(t1.acending(ismember(t1.cluster, [1,2])),t1.decending(ismember(t1.cluster, [1,2])),'hedgesg');
effect_size_on(2,1) = abs(x2.hedgesg);

g3 = grpstats(t1,"is_on_off", "mean")
%% ploting
f1 = figure;
f1.Position =  [115 62 1623 916];
subplot(2,2,1)
% plot(ramp_ints(31:60), mean(g1.mean_short_ramp(:,1:30)))
bar([g1.mean_acending, g1.mean_decending])
xticklabels(["ON-OFF supp", "ON-OFF enha", "ON supp", "ON enha"])
text((1:4)-0.2,max([g1.mean_acending, g1.mean_decending],[],2) + 0.2,[string(p_per_cluster)])
% legend(["ascending","descending"],"Location","best")


subplot(2,2,2)
% plot(ramp_ints(31:60), mean(g1.mean_short_ramp(:,1:30)))
bar([g2.mean_acending, g2.mean_decending])
xticklabels(["supp", "enha"])
text((1:2)-0.2,max([g2.mean_acending, g2.mean_decending],[],2) + 0.2,[string([p_enhanced, p_suppressed])])
% legend(["ascending","descending"],"Location","best")


subplot(2,2,3)
% plot(ramp_ints(31:60), mean(g1.mean_short_ramp(:,1:30)))
bar([g3.mean_acending, g3.mean_decending])
xticklabels(["ON", "ON OFF"])
text((1:2)-0.2,max([g3.mean_acending, g3.mean_decending],[],2) + 0.2,[string([p_on, p_on_off])])
legend(["ascending","descending"],"Location","bestoutside")
% ramp_ints(54:60)
% ramp_ints(61:67)


subplot(2,2,4)
bar([g4.mean_acending, g4.mean_decending])
xticklabels(["ascending", "descending"])

text(1-0.5,min([g4.mean_acending, g4.mean_decending],[],2) + 0.2,[string([p_all])])
% legend(["ascending","descending"],"Location","best")
title('all cells')



save("p_value_for_ascending_vs_descending","p_on_off","p_on","p_suppressed","p_enhanced","p_all","p_per_cluster")
savefig(f1,'ascending vs descending plot')
exportgraphics(f1,'ascending vs descending plot.jpg')

ascending_vs_descending_all_cells = grpstats(t1,[],["mean","sem"],DataVars=["acending","decending"]);
ascending_vs_descending_all_cells.pvalue = p_all;
ascending_vs_descending_all_cells.effect_size = effect_size_all'

save("ascending_vs_descending_all_cells","ascending_vs_descending_all_cells" )

ascending_vs_descending_on_off_vs_on = grpstats(t1,"is_on_off",["mean","sem"],DataVars=["acending","decending"])
ascending_vs_descending_on_off_vs_on.pvalue = [p_on; p_on_off]
ascending_vs_descending_on_off_vs_on.effect_size = effect_size_on

save("ascending_vs_descending_on_off_vs_on","ascending_vs_descending_on_off_vs_on" )


ascending_vs_descending_enhanced_vs_supp = grpstats(t1,"is_enhanced",["mean","sem"],DataVars=["acending","decending"])
ascending_vs_descending_enhanced_vs_supp.pvalue = [p_enhanced;p_suppressed]
ascending_vs_descending_enhanced_vs_supp.effect_size = effect_size_enhanced

save("ascending_vs_descending_enhanced_vs_supp","ascending_vs_descending_enhanced_vs_supp" )


ascending_vs_descending_per_cluster = grpstats(t1,"cluster",["mean","sem"],DataVars=["acending","decending"])
ascending_vs_descending_per_cluster.pvalue = p_per_cluster'
ascending_vs_descending_per_cluster.effect_size = effect_size_per_cluster'
save("ascending_vs_descending_per_cluster","ascending_vs_descending_per_cluster" )









% %% fit each cells
% ramp_ints = importdata('ramp_intensties_120_sec.mat');
% 
% for i = 1:size(t1.short_ramp,1)
%     % ascending
% 
%     y = t1.short_ramp(i,1:30);
%     x = ramp_ints(31:60);
% 
%     fo = fitoptions('Method','NonlinearLeastSquares',...
%         'Algorithm','Trust-Region',...
%         'Display','final',...
%         'TolFun',1.0E-20,...
%         'TolX',1.0E-20,...
%         'Lower',[-1,min(x),-10],...
%         'Upper',[2*max(y),max(x),10],...
%         'StartPoint',[max(y),mean(x),0]);
% 
%     ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
%     [curve1{i,1},gof1{i,1}]=fit(x',y',ft);
% 
%     fittedValues = feval(curve1{i,1}, x);
%     residuals1(i,:) = abs(y - fittedValues');
%     [maxResidual(i,1), idxMaxResidual(i,1)] = max(residuals1(i,:));
% 
% 
% 
% 
% 
% %     f1 = figure;
% %     subplot(1,2,1)
% % 
% %     plot(x,y,'ob','LineWidth',1);
% %     hold on
% %     plot(curve1{i,1},'m');
% 
%     %descending
%     y = t1.short_ramp(i,31:60);
%     x = ramp_ints(61:90);
% 
%     ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
%     [curve1{i,2},gof1{i,2}]=fit(x',y',ft);
% %         subplot(1,2,2)
%     fittedValues = feval(curve1{i,2}, x);
%     residuals2(i,:) = abs(y - fittedValues');
%     [maxResidual(i,2), idxMaxResidual(i,2)] = max(residuals2(i,:));
% 
% 
% 
% %     plot(x,y,'og','LineWidth',1);
% %     hold on
% %     plot(curve1{i,2},'m');
% end
% t1.curve1 = curve1;
% t1.gof1 = gof1;
% t1.residuals2 = residuals2;
% t1.residuals1 = residuals1;
% t1.idxMaxResidual = idxMaxResidual;
% t1.maxResidual = maxResidual;
% 
% %%
% gg = grpstats(t1,"cluster","mean", "DataVars",["maxResidual","idxMaxResidual","residuals1","residuals2", "short_mag", "short_ramp"])
% 
% for i = 1:4
%     subplot(2,2,i)
%     plot(gg.mean_short_ramp(i,:))
%     xline(gg.mean_idxMaxResidual(i,1))
%     xline(gg.mean_idxMaxResidual(i,2)+30)
% end
% 
% %%
% %
% %         original_curve{i,c}=curve1{c};
% %         original_gof{i,c}=gof1{c};
% %         original_rmse(i,c)=gof1{c}.rmse;
% %         original_n(i,c)=curve1{c}.n;
% % %%
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% t1.acending = abs(mean(t1.long_ramp(:,2:61),2))
% t1.decending = abs(mean(t1.long_ramp(:,62:end),2))
% g1 = grpstats(t1, "cluster","mean");
% mean(t1.acending)
% mean(t1.decending)
% for i = 1:4
%     [p(i), t_orig, crit_t] = mult_comp_perm_t1(t1.acending(t1.cluster == i)-t1.decending(t1.cluster == i),10000)
% end
% 
% %% USE ALL RAMP
% T.baseline = mean(T.mean_ramp(:,1:10),2);
% T.is_enhanced = mean(T.norm_ramp(:,45:75),2) >0 ;
% grpstats(T,"cluster","mean")
% T.norm_ramp = T.mean_ramp - T.baseline;
% g2 = grpstats(T,"positive","mean")
% plot(g2.mean_norm_ramp')
% %%
% log_light = ([1:30 30 30:-1:1])
% for i = 1:length(T.mean_ramp)
%     [rho(i), pval(i)] = corr(ramp_ints(31:90)',T.short_ramp(i,:)')
% end
% T.corr = pval';
% T.is_corr = pval' < 0.05
% sum(T.is_corr)
% grpstats(T,"is_corr","mean")
% corr_cells = T(find(T.is_corr),:)
% g4 = grpstats(corr_cells,"is_enhanced","mean")
% plot(g4.mean_mean_ramp')
% plot(g4.mean_norm_ramp')
% grpstats(T,"is_responsive_and_ir","mean")
% grpstats(T,"is_responsive","mean")
% 
% 
% 
% responsive_not_
% 
