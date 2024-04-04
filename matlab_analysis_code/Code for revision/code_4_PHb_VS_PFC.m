clear
clc
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\figure4 ( PHb)')
PHB = importdata("PHB_IR_all_ints_data.mat");
PFC = importdata("PFC_IR_all_ints_data.mat");


%% add tags 
PHB.tag = repmat({'PHB'}, size(PHB, 1), 1);
PFC.tag = repmat({'PFC'}, size(PFC, 1), 1);

%% CANGE PHb CLUSTER NUMBERS
PHB.cluster = cell2mat(PHB.cluster);

PFC.cluster = cell2mat(PFC.cluster);

PHB.clusters_new = PHB.cluster;
new_order = [2 4 3 1];
for i = 1:4
    PHB.clusters_new(PHB.cluster == i) = new_order(i);
end
PHB.cluster = PHB.clusters_new;
%%

% combine tables
commonVars = intersect(PHB.Properties.VariableNames,PFC.Properties.VariableNames);

T =  [PHB(:, commonVars); PFC(:, commonVars)];
T.tag = cell2mat(T.tag);

% T.cluster = cell2mat(T.cluster);
    

T.is_enhanced = ismember(T.cluster, [2 4]);




%% chi squre for clusters
mkdir('clusters')
cd('clusters')

[cluster.table, cluster.chi2, cluster.pval, lables] = crosstab(T.cluster,T.tag);
cluster.df = degfree(cluster.table);

f1 = figure;
f1.Position = [379 330 1227 648];

bar(categorical(lables(1:2,2)), cluster.table(:, :)./sum(cluster.table))
legend(["ON-OFF supp", "ON-OFF enha", "ON enha", "ON supp"])
title('clusters')
subtitle(['pval: ' num2str(cluster.pval)])


save('cluster', 'cluster')
savefig(f1, 'chi_squre_data')
cd .. 
%% chi squre for enhanced vs supp
mkdir('enhanced_vs_suppressed')
cd('enhanced_vs_suppressed')

[enhanced_vs_suppressed.table, enhanced_vs_suppressed.chi2, enhanced_vs_suppressed.pval, lables] = crosstab(T.is_enhanced,T.tag);
enhanced_vs_suppressed.df = degfree(enhanced_vs_suppressed.table);

f1 = figure;
f1.Position = [379 330 1227 648];

bar(categorical(lables(:,2)), (enhanced_vs_suppressed.table./sum(enhanced_vs_suppressed.table))')
legend([ "suppressed","enhanced",])
title('enhanced vs suppressed')
subtitle(['pval: ' num2str(enhanced_vs_suppressed.pval)])


save('enhanced_vs_suppressed', 'enhanced_vs_suppressed')
savefig(f1, 'chi_squre_data')

cd .. 