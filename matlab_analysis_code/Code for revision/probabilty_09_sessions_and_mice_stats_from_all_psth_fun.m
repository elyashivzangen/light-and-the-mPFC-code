%% eria stats for all_psthT
%load all psthT
clear
clc
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\using 0.9 probability')
all_psthT =  importdata('all_cells_PSTH.mat');
T2 = readtable("cells_coordinates_map.csv");
T =  importdata('all_cells_structers_probabilty.mat');




%% add structure probabilty to all_psthT
for i = 1:length(all_psthT.position)
    rel_idx(i) = find(all_psthT.coordinats{i}.z{1} == T2.z & all_psthT.coordinats{i}.y{1} == T2.y & all_psthT.id(i) == T2.id);
    prob(i) = T.in_structure_prob(rel_idx(i));

end

all_psthT.in_structure_probability =  prob';

all_psthT(find(all_psthT.in_structure_probability < 0.9), :) = [];


%% leave only relevant sturctures in the table and add isenhanced to the table
erias = ["AC", "PL", "IL", "DP", "TT"];
is_enhanced = mean(all_psthT.nd1(:,65:125),2) > 0;
all_psthT.is_enhanced = is_enhanced;
T = all_psthT(:, ["is_ir","is_responsive","main_structure","position","cluster","is_enhanced", "in_structure_probability"]);
T(~(contains(T.main_structure,erias)), :) = [];
x = T.Properties.RowNames;
% T.is_ir = array2table(T.is_ir, VariableNames=["transient", "steady"]);
% T.is_responsive = array2table(T.is_responsive, VariableNames=["transient", "steady"]);

%% add sessions mice and sides

sessions = cellfun(@(x) x(1:11), x, 'UniformOutput', false);
T.sessions =sessions;
mice_and_settions = split(sessions,'_');
mice = mice_and_settions(:,1);
T.mouse = mice;
T.side = mice_and_settions(:,2);
T.side = cellfun(@(x) x(1), T.side, 'UniformOutput', false);
%% figure 1
mkdir("figure1")
cd("figure1")
%% i total
mkdir("i")
cd("i")
per_mouse = grpstats(T,"mouse","mean","DataVars","is_responsive");
per_mouse.mouse = zeros(length(per_mouse.mouse),1);
mean_per_mouse = grpstats(per_mouse, "mouse","mean");
sem_per_mouse = grpstats(per_mouse, "mouse","sem");
save('mean_per_mouse', 'mean_per_mouse')
save('sem_per_mouse', 'sem_per_mouse')
cd ..
%% h sides
mkdir("h")
cd("h")

per_session_and_side = grpstats(T,["sessions", "side"], "mean","DataVars","is_responsive");
mean_per_side_per_session = grpstats(per_session_and_side, "side", "mean", "DataVars","mean_is_responsive");
sem_per_side_per_session = grpstats(per_session_and_side, "side", "sem", "DataVars","mean_is_responsive");
f1 = figure;
f1.Position = [680 301 926 677];


subplot(1,2,1)
grpstats(per_session_and_side.mean_is_responsive(:,1), per_session_and_side.side, 0.05)
subtitle('transient')


subplot(1,2,2)
grpstats(per_session_and_side.mean_is_responsive(:,2), per_session_and_side.side, 0.05)
subtitle('sustained')


L = per_session_and_side.mean_is_responsive(ismember(per_session_and_side.side, 'L'),:);
R = per_session_and_side.mean_is_responsive(ismember(per_session_and_side.side, 'R'),:);
transient_sides_pval = mult_comp_perm_t2(L(:,1),R(:,1),10000);
sustained_sides_pval = mult_comp_perm_t2(L(:,2),R(:,2),10000);

anova1(per_session_and_side.mean_is_responsive(:,2),per_session_and_side.side)


save('transient_sides_pval', 'transient_sides_pval')
save('sustained_sides_pval', 'sustained_sides_pval')
save('mean_per_side_per_session', 'mean_per_side_per_session')
save('sem_per_side_per_session', 'sem_per_side_per_session')
savefig(f1, 'per_side_per_session')
savefig('anova')

% using chi-squre on the proportions
mkdir('chi_squre')
cd('chi_squre')
% chi-squre
[transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_responsive(:,1), T.side);
transient.df = degfree(transient.table);
[sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_responsive(:,2), T.side);
sustained.df = degfree(sustained.table);


f1 = figure;
f1.Position = [379 330 1227 648];

subplot(1,2,1)
bar(categorical(lables(:,2)), transient.table(2, :)./sum(transient.table, 1))
title('transient')
subtitle(['pval: ' num2str(transient.pval)])


subplot(1,2,2)
bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table, 1))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])

save('transient_data', 'transient')
save('sustained_data', 'sustained')

savefig(f1, 'chi_squre_data')
cd ..
cd ..

%% f main_structure
close all

mkdir("f")
cd('f')
T2 = T(T.in_structure_probability > 0.001,:);
per_session_and_main_structure = grpstats(T2,["main_structure","sessions"], "mean","DataVars",["is_responsive", "is_ir"]);




% wieght data by number of cells in experement (every cell gets the value
% of the mean percentage of responsive cells in the structure


mean_per_side_per_main_structure = grpstats(per_session_and_main_structure, "main_structure", "mean", "DataVars",["mean_is_responsive","mean_is_ir"]);
sem_per_side_per_main_structure = grpstats(per_session_and_main_structure, "main_structure", "sem", "DataVars","mean_is_responsive");

per_session_and_main_structure2 = per_session_and_main_structure(per_session_and_main_structure.GroupCount > 5,:);
% per_session_and_main_structure3 = per_session_and_main_structure(per_session_and_main_structure. > 5,:);

% use chi-2 test
T_only_mPFC = T;
mPFC_idx = find(ismember(T.main_structure,["IL"]));
MPFC(mPFC_idx) = 1;
MPFC(find(~ismember(T.main_structure,["IL"]))) = 0;
T.MPFC = MPFC';
per_main_struct = grpstats(T, "MPFC", @sum, "DataVars",["is_ir", "is_responsive"])
% [h,p, chi2stat,df] = prop_test(per_main_struct.sum_is_responsive(:,2) , per_main_struct.GroupCount-per_main_struct.sum_is_responsive(:,2),false)





f1 = figure;
f1.Position = [163 301 1443 677];
subplot(1,2,1)
grpstats(per_session_and_main_structure.mean_is_responsive(:,1), per_session_and_main_structure.main_structure, 0.05)
subtitle('transient')

subplot(1,2,2)
grpstats(per_session_and_main_structure.mean_is_responsive(:,2), per_session_and_main_structure.main_structure, 0.05)
subtitle('sustained')

savefig(f1, 'per_side_per_session')
save('mean_per_side_per_main_structure', 'mean_per_side_per_main_structure')
save('sem_per_side_per_main_structure', 'sem_per_side_per_main_structure')
[p,tbl,stats] = anova1(per_session_and_main_structure2.mean_is_responsive(:,2),per_session_and_main_structure2.main_structure)
results = multcompare(stats);
tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"])


%
%% using chi-squre on the proportions
mkdir('chi_squre')
cd('chi_squre')
% chi-squre
[transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_responsive(:,1), T.main_structure);
transient.df = degfree(transient.table);
[sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_responsive(:,2), T.main_structure);
sustained.df = degfree(sustained.table);


f1 = figure;
f1.Position = [379 330 1227 648];

subplot(1,2,1)
bar(categorical(lables(:,2)), transient.table(2, :)./sum(transient.table))
title('transient')
subtitle(['pval: ' num2str(transient.pval)])


subplot(1,2,2)
bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])

sgtitle('all reagions')

save('transient_data', 'transient')
save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd ..



%% use_ch-squre to test vmPFC_VS_non_vmPFC

mkdir('chi_squre_vmPFC_VS_non_vmPFC')
cd('chi_squre_vmPFC_VS_non_vmPFC')
% chi-squre
T.vmPFC = ismember(T.main_structure,["IL","PL"]);

[transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_responsive(:,1), T.vmPFC);
transient.df = degfree(transient.table);
[sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_responsive(:,2), T.vmPFC);
sustained.df = degfree(sustained.table);

f1 = figure;
f1.Position = [379 330 1227 648];

subplot(1,2,1)
bar(categorical(["non vmPFC", "vmPFC(IL/PL)"]), transient.table(2, :)./sum(transient.table))
title('transient')
subtitle(['pval: ' num2str(transient.pval)])


subplot(1,2,2)
bar(categorical(["non vmPFC", "vmPFC(IL/PL)"]), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])

sgtitle('vmPFC(IL/PL) VS  non vmPFC')

save('transient_data', 'transient')
save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd ..
cd ..

%% IL vs non IL
%% use_ch-squre to test vmPFC_VS_non_vmPFC

mkdir('chi_squre_IL_VS_non_IL')
cd('chi_squre_IL_VS_non_IL')
% chi-squre
T.IL = ismember(T.main_structure,["IL"]);

[transient.table, transient.chi2, transient.pval, lables] = crosstab(T.is_responsive(:,1), T.IL);
transient.df = degfree(transient.table);
[sustained.table, sustained.ch, sustained.pval,lables] = crosstab(T.is_responsive(:,2), T.IL);
sustained.df = degfree(sustained.table);

f1 = figure;
f1.Position = [379 330 1227 648];

subplot(1,2,1)
bar(categorical(["non IL", "IL"]), transient.table(2, :)./sum(transient.table))
title('transient')
subtitle(['pval: ' num2str(transient.pval)])


subplot(1,2,2)
bar(categorical(["non IL", "IL"]), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])

sgtitle('IL VS  non IL')

save('transient_data', 'transient')
save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd ..
cd ..
%% pfc vs non PFC
T2.is_vmPFC = ismember(T2.main_structure, ["IL", "PL"]);
per_session_and_is_vmPFC = grpstats(T2,["is_vmPFC","sessions"], "mean","DataVars","is_responsive");
X = grpstats(per_session_and_is_vmPFC, "is_vmPFC", "mean", "DataVars","mean_is_responsive");
[p,tbl,stats] = anova1(per_session_and_is_vmPFC.mean_is_responsive(:,2),per_session_and_is_vmPFC.is_vmPFC)
[pval, x] = ttest2(per_session_and_is_vmPFC.mean_is_responsive(per_session_and_is_vmPFC.is_vmPFC,2), per_session_and_is_vmPFC.mean_is_responsive(~per_session_and_is_vmPFC.is_vmPFC,2) )
results = multcompare(stats);
tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"])




%% figure 2 - intensity encoding

mkdir('figure2')
cd('figure2')
%%
mkdir('IE across hemispheres')
cd('IE across hemispheres')

% using chi-squre on the proportions
mkdir('chi_squre')
cd('chi_squre')
% chi-squre

[sustained.table, sustained.chi2, sustained.pval, lables] = crosstab(T.is_ir(:,2), T.side);
sustained.df = degfree(sustained.table);



f1 = figure;

bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table, 1))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])

save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd ..
cd ..

%% 'j (IE across ereas)'
mkdir('j (IE across ereas)')
cd('j (IE across ereas)')

% using chi-squre on the proportions
mkdir('chi_squre')
cd('chi_squre')
% chi-squre
[sustained.table, sustained.chi2, sustained.pval, lables] = crosstab(T.is_ir(:,2), T.main_structure);
sustained.df = degfree(sustained.table);



f1 = figure;


bar(categorical(lables(:,2)), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])


save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd ..
%% use_ch-squre to test vmPFC_VS_non_vmPFC

mkdir('chi_squre_vmPFC_VS_non_vmPFC')
cd('chi_squre_vmPFC_VS_non_vmPFC')
T.vmPFC = ismember(T.main_structure,["IL","PL"]);

% chi-squre
[sustained.table, sustained.chi2, sustained.pval, lables] = crosstab(T.is_ir(:,2), T.vmPFC);
sustained.df = degfree(sustained.table);

f1 = figure;
f1.Position = [379 330 1227 648];


bar(categorical([ "non vmPFC", "vmPFC(IL/PL)"]), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])


save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd ..



%%
%% use_ch-squre to test IL VS NON IL

mkdir('chi_squre_IL_VS_non_IL')
cd('chi_squre_IL_VS_non_IL')
T.IL = ismember(T.main_structure,["IL"]);

% chi-squre
[sustained.table, sustained.chi2, sustained.pval, lables] = crosstab(T.is_ir(:,2), T.IL);
sustained.df = degfree(sustained.table);

f1 = figure;
f1.Position = [379 330 1227 648];


bar(categorical([ "non IL", "IL"]), sustained.table(2, :)./sum(sustained.table))
title('sustained')
subtitle(['pval: ' num2str(sustained.pval)])


save('sustained_data', 'sustained')
savefig(f1, 'chi_squre_data')
cd ..

cd ..
%% enhanced vs supprressed
mkdir('l(enhanced_vs_suppressed')
cd('l(enhanced_vs_suppressed')
%
IR_cells = T(find(T.is_ir(:,2)),:);
[enhanced_vs_suppressed.table, enhanced_vs_suppressed.chi2, enhanced_vs_suppressed.pval, lables] = crosstab(IR_cells.is_enhanced,IR_cells.main_structure);
enhanced_vs_suppressed.df = degfree(enhanced_vs_suppressed.table);

f1 = figure;
f1.Position = [379 330 1227 648];

bar(categorical(lables(:,2)), enhanced_vs_suppressed.table(:, :)./sum(enhanced_vs_suppressed.table))
legend([ "suppressed","enhanced",])
title('percent of enhanced')
subtitle(['pval: ' num2str(enhanced_vs_suppressed.pval)])


save('enhanced_vs_suppressed', 'enhanced_vs_suppressed')
savefig(f1, 'chi_squre_data')



%% enhanced vs supprressed 
mkdir('IL_VS_PL')
cd('IL_VS_PL')

%
IL_PL = IR_cells(find(ismember(IR_cells.main_structure, ["IL", "PL"])),:);
[enhanced_vs_suppressed.table, enhanced_vs_suppressed.chi2, enhanced_vs_suppressed.pval, lables] = crosstab(IL_PL.is_enhanced,IL_PL.main_structure);
enhanced_vs_suppressed.df = degfree(enhanced_vs_suppressed.table);
f1 = figure;
f1.Position = [379 330 1227 648];

bar(categorical(lables(:,2)), enhanced_vs_suppressed.table(:, :)./sum(enhanced_vs_suppressed.table))
legend([ "suppressed","enhanced",])
title('enhanced vs suppressed')
subtitle(['pval: ' num2str(enhanced_vs_suppressed.pval)])


save('enhanced_vs_suppressed', 'enhanced_vs_suppressed')
savefig(f1, 'chi_squre_data')

cd ..

%% TT vs DP
mkdir('TT vs DP')
cd('TT vs DP')

%
TT_DP = IR_cells(find(ismember(IR_cells.main_structure, ["TT", "DP"])),:);
[enhanced_vs_suppressed.table, enhanced_vs_suppressed.chi2, enhanced_vs_suppressed.pval, lables] = crosstab(TT_DP.is_enhanced,TT_DP.main_structure);
enhanced_vs_suppressed.df = degfree(enhanced_vs_suppressed.table);

f1 = figure;
f1.Position = [379 330 1227 648];

bar(categorical(lables(:,2)), enhanced_vs_suppressed.table(:, :)./sum(enhanced_vs_suppressed.table))
legend([ "suppressed","enhanced",])
title('enhanced vs suppressed')
subtitle(['pval: ' num2str(enhanced_vs_suppressed.pval)])


save('enhanced_vs_suppressed', 'enhanced_vs_suppressed')
savefig(f1, 'chi_squre_data')

cd ..
cd ..
%% CLUSTERS
mkdir('k_m(CLUSTERS)')
cd('k_m(CLUSTERS)')
%
mkdir('k_ereas')
cd('k_ereas')

%
[cluster.table, cluster.chi2, cluster.pval, lables] = crosstab(IR_cells.cluster,IR_cells.main_structure);
cluster.df = degfree(cluster.table);


f1 = figure;
f1.Position = [379 330 1227 648];

bar(categorical(lables(:,2)), cluster.table(:, :)./sum(cluster.table))
legend(["ON-OFF supp", "ON-OFF enha", "ON enha", "ON supp"])
title('clusters')
subtitle(['pval: ' num2str(cluster.pval)])


save('enhanced_vs_suppressed', 'enhanced_vs_suppressed')
savefig(f1, 'chi_squre_data')

cd ..
%
mkdir('m_sides')
cd('m_sides')

%
[cluster.table, cluster.chi2, cluster.pval, lables] = crosstab(IR_cells.cluster,IR_cells.side);
cluster.df = degfree(cluster.table);


f1 = figure;
f1.Position = [379 330 1227 648];

bar(categorical(lables(1:2,2)), cluster.table(:, :)./sum(cluster.table))
legend(["ON-OFF supp", "ON-OFF enha", "ON enha", "ON supp"])
title('clusters')
subtitle(['pval: ' num2str(cluster.pval)])


save('enhanced_vs_suppressed', 'enhanced_vs_suppressed')
savefig(f1, 'chi_squre_data')

cd ..

%%
%%
function df = degfree(t)
   df = (size(t,1)-1)* (size(t,1)-1);
end

