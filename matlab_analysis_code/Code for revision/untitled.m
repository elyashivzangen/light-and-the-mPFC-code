A = all_psthT.position;
B = T.acronym;
for i = 1:length(A)
    idx(i) = contains(A{i}, B{i})
end
T2 = readtable("cells_coordinates_map.csv");
T2.in_struct_prob = T.in_structure_prob;
for i = 1:length(T2.id)
    rowname{i}= [T2.exp_name{i} '_cell_' num2str(T2.id(i))];
end
T2.Properties.RowNames = rowname;
rowname2 = unique(rowname);