function hirarcial_ex(N, dont_use_pca, CTP, parameter_names, i, XT)
% use hirarcial
% Load the data matrix X
% Normalize the data
X = XT{:, N{i}};
X_norm = normalize(X);

% Apply PCA to reduce dimensionality
[coeff,score,latent] = pca(X_norm);

% Find the most significant PCs
cumulative_variance = cumsum(latent)./sum(latent);
num_pcs = find(cumulative_variance >= 0.95, 1, 'first');
significant_pcs = score(:,1:num_pcs);

%dont use pca
if dont_use_pca
    significant_pcs = X_norm;
end
% Cluster the neurons into 2 different types using hierarchical clustering
Y = pdist(significant_pcs);

Z = linkage(Y,'ward');
idx = cluster(Z,'maxclust',2);

% Plot the neurons in the PC coordinates
clustering_parameters.significant_pcs = significant_pcs;
clustering_parameters.num_pcs = num_pcs;
clustering_parameters.Z_linkage = Z;
clustering_parameters.Y_pdist = Y;
clustering_parameters.PCA_coeff = coeff;
clustering_parameters.PCA_score = score;
clustering_parameters.PCA_latent = latent;
clustering_parameters.idx = idx;
save("clustering_parameters", "clustering_parameters")

f20 = figure;
scatter(significant_pcs(idx==1,1),significant_pcs(idx==1,2),'.b');
hold on;
scatter(significant_pcs(idx==2,1),significant_pcs(idx==2,2),'.r');
legend('Cluster 1','Cluster 2');
xlabel('PC 1');
ylabel('PC 2');
CTP.idx = idx;
title([parameter_names{N{i}} '_NO_PCA_' num2str(dont_use_pca)]);
savefig(f20, 'PCs')
exportgraphics(f20, 'all_figs.pdf', Append=true)
save("CTP", "CTP")
