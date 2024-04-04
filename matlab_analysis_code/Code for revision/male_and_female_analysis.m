%% male and female analysis
clear
clc
cd("I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\MALES_vs_FEMALES")
load("all_cells_PSTH.mat")
%%
all_psthT.mean_ramp = cellfun(@(x) x.mean, all_psthT.ramp, UniformOutput=false);
all_psthT.mean_ramp = cell2mat(all_psthT.mean_ramp);
all_psthT.sex = cellfun(@(x) x{1}, all_psthT.sex);
is_enhanced = mean(all_psthT.nd1(:,65:125),2) > 0;
all_psthT.is_enhanced = is_enhanced;


T = all_psthT;
relevant_ereas = ["PL", "AC","IL","DP","TT"];
% exclude non relevant ereas
T(find(~ismember(T.main_structure,relevant_ereas)),:) = [];
%%
M_VS_F_psth_and_ramp = grpstats(T, "sex",["mean", "sem"], "DataVars",["nd10","nd8","nd6","nd4","nd3","nd2","nd1","mean_ramp", "is_responsive","is_ir", "is_enhanced"]);
save("M_VS_F_psth_and_ramp","M_VS_F_psth_and_ramp")


%%
x = -40:160;
f1 = figure;
f1.Position = [217 131 1445 847];


subplot(2,2,1)
plot(x, M_VS_F_psth_and_ramp.mean_nd1(1,:)')
hold on
plot(x, M_VS_F_psth_and_ramp.mean_nd1(2,:)')
xline(0)
xline(100)
legend(["M", "F"])

subplot(2,2,2)
plot( M_VS_F_psth_and_ramp.mean_mean_ramp(1,:)')
hold on
plot( M_VS_F_psth_and_ramp.mean_mean_ramp(2,:)')
savefig(f1, 'M_VS_F_psth_and_ramp')
%%
responsive_and_IE_per_session = grpstats(all_psthT, ["exp_name", "sex"],"mean", "DataVars",["is_responsive","is_ir"]);
M_F_responsive_and_IE = grpstats(responsive_and_IE_per_session, "sex",["mean","sem"],"DataVars",["mean_is_responsive","mean_is_ir"]);
save("M_F_responsive_and_IE","M_F_responsive_and_IE")
subplot(1,2,1)
boxplot(responsive_and_IE_per_session.mean_is_responsive(:,2),responsive_and_IE_per_session.sex);
title('responsive_per_session')
subplot(1,2,2)
boxplot(responsive_and_IE_per_session.mean_is_ir(:,2),responsive_and_IE_per_session.sex);
title('IE_per_session')
savefig('M_F_responsive_and_IE')



[p,tbl,stats] = anova1(responsive_and_IE_per_session.mean_is_responsive(:,2),responsive_and_IE_per_session.sex)
results = multcompare(stats);
tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"])

%% chi squre M vs F
mkdir('chi2')
cd('chi2')
%% responsieve
mkdir('responsieve')
cd('responsieve')
[transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_responsive(:,1), T.sex);
transient.df = degfree(transient.table);
[sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_responsive(:,2), T.sex);
sustained.df = degfree(sustained.table);

f1 = figure;
f1.Position = [379 330 1227 648];

subplot(1,2,1)
bar(categorical(lables(:,2)), (transient.table(2, :)./sum(transient.table))')
title('transient')
subtitle(['pval: ' num2str(transient.pval)])


subplot(1,2,2)
bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])

sgtitle('Male VS females chi2')

save('transient_data', 'transient')
save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd .. 

%% IE
mkdir('IE')
cd('IE')
[transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_ir(:,1), T.sex);
transient.df = degfree(transient.table);
[sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_ir(:,2), T.sex);
sustained.df = degfree(sustained.table);

f1 = figure;
f1.Position = [379 330 1227 648];

subplot(1,2,1)
bar(categorical(lables(:,2)), (transient.table(2, :)./sum(transient.table))')
title('transient')
subtitle(['pval: ' num2str(transient.pval)])


subplot(1,2,2)
bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])

sgtitle('Male VS females chi2')

save('transient_data', 'transient')
save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd .. 

%% enhanced vs supprressed IE CELLS



mkdir('enhanced_vs_suppressed_IE_cells')
cd('enhanced_vs_suppressed_IE_cells')

IR_cells = T(find(T.is_ir(:,2)),:);
[enhanced_vs_suppressed.table, enhanced_vs_suppressed.chi2, enhanced_vs_suppressed.pval, lables] = crosstab(IR_cells.is_enhanced,IR_cells.sex);
enhanced_vs_suppressed.df = degfree(enhanced_vs_suppressed.table);

f1 = figure;
f1.Position = [379 330 1227 648];

bar(categorical(lables(:,2)), (enhanced_vs_suppressed.table(:, :)./sum(enhanced_vs_suppressed.table))')
legend([ "suppressed","enhanced",])
title('percent of enhanced')
subtitle(['pval: ' num2str(enhanced_vs_suppressed.pval)])


save('enhanced_vs_suppressed', 'enhanced_vs_suppressed')
savefig(f1, 'chi_squre_data')
cd .. 

cd ..

%% per area
mkdir('per area')
cd('per area')
%
T2 = T;

areas = unique(T.position);
main_areas = unique(T.main_structure);
for i = 1:length(main_areas)
    T = T2(find(ismember( T2.main_structure, main_areas{i})),:);
    if length(unique(T.sex)) ==  1
        continue
    end

    
    mkdir(main_areas{i})
    cd(main_areas{i})
    


% chi squre M vs F

% responsieve
mkdir('responsieve')
cd('responsieve')
[transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_responsive(:,1), T.sex);
transient.df = degfree(transient.table);
[sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_responsive(:,2), T.sex);
sustained.df = degfree(sustained.table);

f1 = figure;
f1.Position = [379 330 1227 648];

subplot(1,2,1)
bar(categorical(lables(:,2)), (transient.table(2, :)./sum(transient.table))')
title('transient')
subtitle(['pval: ' num2str(transient.pval)])


subplot(1,2,2)
bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])

sgtitle('Male VS females chi2')

save('transient_data', 'transient')
save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd .. 

% IE
mkdir('IE')
cd('IE')
[transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_ir(:,1), T.sex);
transient.df = degfree(transient.table);
[sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_ir(:,2), T.sex);
sustained.df = degfree(sustained.table);

f1 = figure;
f1.Position = [379 330 1227 648];

subplot(1,2,1)
bar(categorical(lables(:,2)), (transient.table(2, :)./sum(transient.table))')
title('transient')
subtitle(['pval: ' num2str(transient.pval)])


subplot(1,2,2)
bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])

sgtitle('Male VS females chi2')

save('transient_data', 'transient')
save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd .. 

% enhanced vs supprressed IE CELLS



mkdir('enhanced_vs_suppressed_IE_cells')
cd('enhanced_vs_suppressed_IE_cells')

IR_cells = T(find(T.is_ir(:,2)),:);
[enhanced_vs_suppressed.table, enhanced_vs_suppressed.chi2, enhanced_vs_suppressed.pval, lables] = crosstab(IR_cells.is_enhanced,IR_cells.sex);
enhanced_vs_suppressed.df = degfree(enhanced_vs_suppressed.table);

f1 = figure;
f1.Position = [379 330 1227 648];

bar(categorical(lables(:,2)), (enhanced_vs_suppressed.table(:, :)./sum(enhanced_vs_suppressed.table))')
legend([ "suppressed","enhanced",])
title('percent of enhanced')
subtitle(['pval: ' num2str(enhanced_vs_suppressed.pval)])


save('enhanced_vs_suppressed', 'enhanced_vs_suppressed')
savefig(f1, 'chi_squre_data')
cd .. 
%

mkdir('enhanced_vs_suppressed_responsive_cells')
cd('enhanced_vs_suppressed_responsive_cells')

IR_cells = T(find(T.is_responsive(:,2)),:);
[enhanced_vs_suppressed.table, enhanced_vs_suppressed.chi2, enhanced_vs_suppressed.pval, lables] = crosstab(IR_cells.is_enhanced,IR_cells.sex);
enhanced_vs_suppressed.df = degfree(enhanced_vs_suppressed.table);

f1 = figure;
f1.Position = [379 330 1227 648];

bar(categorical(lables(:,2)), (enhanced_vs_suppressed.table(:, :)./sum(enhanced_vs_suppressed.table))')
legend([ "suppressed","enhanced",])
title('percent of enhanced')
subtitle(['pval: ' num2str(enhanced_vs_suppressed.pval)])


save('enhanced_vs_suppressed', 'enhanced_vs_suppressed')
savefig(f1, 'chi_squre_data')
cd ..
cd ..


end
T = T2;

cd ..

%%
%% per layer
mkdir('per layer')
cd('per layer')
%
T2 = T;

areas = unique(T.position);
main_areas = unique(T.main_structure);
for i = 1:length(main_areas)
    T = T2(find(ismember( T2.position, areas{i})),:);
    if length(unique(T.sex)) ==  1
        continue
    end

    
    mkdir(main_areas{i})
    cd(main_areas{i})
    


% chi squre M vs F

% responsieve
mkdir('responsieve')
cd('responsieve')
[transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_responsive(:,1), T.sex);
transient.df = degfree(transient.table);
[sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_responsive(:,2), T.sex);
sustained.df = degfree(sustained.table);

f1 = figure;
f1.Position = [379 330 1227 648];

subplot(1,2,1)
bar(categorical(lables(:,2)), (transient.table(2, :)./sum(transient.table))')
title('transient')
subtitle(['pval: ' num2str(transient.pval)])


subplot(1,2,2)
bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])

sgtitle('Male VS females chi2')

save('transient_data', 'transient')
save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd .. 

% IE
mkdir('IE')
cd('IE')
[transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_ir(:,1), T.sex);
transient.df = degfree(transient.table);
[sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_ir(:,2), T.sex);
sustained.df = degfree(sustained.table);

f1 = figure;
f1.Position = [379 330 1227 648];

subplot(1,2,1)
bar(categorical(lables(:,2)), (transient.table(2, :)./sum(transient.table))')
title('transient')
subtitle(['pval: ' num2str(transient.pval)])


subplot(1,2,2)
bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])

sgtitle('Male VS females chi2')

save('transient_data', 'transient')
save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd .. 

% enhanced vs supprressed IE CELLS



mkdir('enhanced_vs_suppressed_IE_cells')
cd('enhanced_vs_suppressed_IE_cells')

IR_cells = T(find(T.is_ir(:,2)),:);
[enhanced_vs_suppressed.table, enhanced_vs_suppressed.chi2, enhanced_vs_suppressed.pval, lables] = crosstab(IR_cells.is_enhanced,IR_cells.sex);
enhanced_vs_suppressed.df = degfree(enhanced_vs_suppressed.table);

f1 = figure;
f1.Position = [379 330 1227 648];

bar(categorical(lables(:,2)), (enhanced_vs_suppressed.table(:, :)./sum(enhanced_vs_suppressed.table))')
legend([ "suppressed","enhanced",])
title('percent of enhanced')
subtitle(['pval: ' num2str(enhanced_vs_suppressed.pval)])


save('enhanced_vs_suppressed', 'enhanced_vs_suppressed')
savefig(f1, 'chi_squre_data')
cd .. 
%

mkdir('enhanced_vs_suppressed_responsive_cells')
cd('enhanced_vs_suppressed_responsive_cells')

IR_cells = T(find(T.is_responsive(:,2)),:);
[enhanced_vs_suppressed.table, enhanced_vs_suppressed.chi2, enhanced_vs_suppressed.pval, lables] = crosstab(IR_cells.is_enhanced,IR_cells.sex);
enhanced_vs_suppressed.df = degfree(enhanced_vs_suppressed.table);

f1 = figure;
f1.Position = [379 330 1227 648];

bar(categorical(lables(:,2)), (enhanced_vs_suppressed.table(:, :)./sum(enhanced_vs_suppressed.table))')
legend([ "suppressed","enhanced",])
title('percent of enhanced')
subtitle(['pval: ' num2str(enhanced_vs_suppressed.pval)])


save('enhanced_vs_suppressed', 'enhanced_vs_suppressed')
savefig(f1, 'chi_squre_data')
cd ..
cd ..


end
T = T2;

cd ..