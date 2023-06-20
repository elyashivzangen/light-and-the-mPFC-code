% save data from clusters
clusters_data.mean = clusters.mean;
clusters_data.std = clusters.std;
clusters_data.ste = clusters.ste;
clusters_data.num_of_cells = clusters.num_of_cells;

save("clusters4shai.mat", "clusters_data")
