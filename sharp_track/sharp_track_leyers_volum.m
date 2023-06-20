%load atlas
annotation_volume_location = 'C:\Users\elyashivz\Documents\analyzing_slices\annotation_volume_10um_by_index.npy';
structure_tree_location = 'C:\Users\elyashivz\Documents\analyzing_slices\structure_tree_safe_2017.csv';

if ~exist('av','var') || ~exist('st','var')
    disp('loading reference atlas...')
    av = readNPY(annotation_volume_location);
    st = loadStructureTree(structure_tree_location);
end

clearvars -except st av
clc
%%
relevant_idx = 221:252; %ACA, PL, AND IL indexis in the st location
%use only half brain 
midline = 570;
avx = double(av(:,:,1:570));

for j = 1:length(relevant_idx)
    [z,y,x] = findND(avx==relevant_idx(j));
    if isempty(y)
        continue
    end
    uy = unique(y);
    for i  = 1:length(uy)
        idx = find(y == uy(i));
        maxz = max(z(idx));
        minz = min(z(idx));
        zsize{j}(i) = maxz - minz;

        maxx = max(x(idx));
        minx = min(x(idx));
        xsize{j}(i) = maxx - minx;
    end
    meanx(j) = mean(xsize{j})*10;
    stdx(j) = std(xsize{j})*10;
    meanz(j) = mean(zsize{j})*10;
    stdz(j) = std(zsize{j})*10;

    y_total_size(j) = (max(uy)- min(uy))*10;
end

acro = st.acronym(relevant_idx);
T = table(acro, meanx', stdx', meanz', stdz', y_total_size', VariableNames=["structure", "mean_ML_size", "std_ML_size",  "mean_AP_size",  "std_AP_size", "max_DV_size"]);
size_of_structures = T;
size_of_structures(~T.mean_ML_size, :) = [];
save("size_of_layaers", "size_of_structures")
writetable(size_of_structures, "size_of_layaers.csv")