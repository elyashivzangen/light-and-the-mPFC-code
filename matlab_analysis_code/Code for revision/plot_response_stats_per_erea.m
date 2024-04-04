%% response statistics per erea
cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\response statistics per erea')
%%

T = importdata("C57_ALL_CELLS.mat");

%%
T.main_structure = cellfun(@(x) x{1}(1:2),T.region_acronym,UniformOutput=false);
erias = ["AC", "PL", "IL", "DP", "TT"];
T(~(contains(T.main_structure,erias)), :) = [];

%%
T.basline1 =  cellfun(@(x) mean(x(1:30,:), "all"),T.ND1);
T.magnitude = cellfun(@(x) (mean(x(65:125,:),"all")-mean(x(1:30,:),"all"))/mean(x(1:30,:),"all"), T.ND1 );
T.magnitude(~T.basline1) = nan;
T.zscore = cellfun(@(x) (mean(x(65:125,:),"all","omitnan")-std(x(1:30,:),0,"all"))/std(x(1:30,:),0,"all"), T.ND1 );
T.zscore(~T.basline1) = nan;


T.response = cellfun(@(x) (mean(x(65:125,:),"all")-mean(x(1:30,:),"all")), T.ND1 );
% add magnitude vector
NDs = [10, 8, 6, 4, 3, 2, 1];

for i = 1:length(NDs)
    v = T.(['ND' num2str(NDs(i))]);
    mag(:,i) = cellfun(@(x) (mean(x(65:125,:),"all")-mean(x(1:30,:),"all"))/mean(x(1:30,:),"all"), v );
    res(:, i) = cellfun(@(x) (mean(x(65:125,:),"all")-mean(x(1:30,:),"all")), v );
    z_s(:, i) = cellfun(@(x) (mean(x(65:125,:),"all","omitnan")-std(x(1:30,:),0,"all"))/std(x(1:30,:),0,"all"), v );
    mag(isinf(mag(:,i)), i) = nan;
    z_s(isinf(z_s(:,i)),i) = nan;

end
T.magnetude_vector =  mag;
T.IR =  res;
T.Is_enhanced = res(:,end) > 0;
T.z_vector = z_s;
% flip negative cells
T.abs_IR =  res;
T.abs_IR(find(~T.Is_enhanced),:) = T.abs_IR(find(~T.Is_enhanced),:)*-1;

T.abs_magnetude_vector =  mag;
T.abs_magnetude_vector(find(~T.Is_enhanced),:) = T.abs_magnetude_vector(find(~T.Is_enhanced),:)*-1;
T.abs_magnetude_vector(~T.basline1) = nan;

T.abs_z_vector =  z_s;
T.abs_z_vector(find(~T.Is_enhanced),:) = T.abs_z_vector(find(~T.Is_enhanced),:)*-1;
T.abs_z_vector(~T.basline1) = nan;

%%
%% response size per erea
mkdir('reponse size per erea (extended_2_f)')
cd('reponse size per erea (extended_2_f)')
%
% all cells
mkdir('all cells')
cd('all cells')


[p,tbl,stats] = anova1(T.response, T.main_structure);
savefig('response_all_cells_box_plot')
results = multcompare(stats);
resuls_tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
title('all cells response')
savefig('response_all_cells_multiple_comp')
save('response_all_cells_multiple_comp', 'resuls_tbl')
cd ..

% responsive cells
mkdir('responsive cells')
cd('responsive cells')
responsive_cells = T(find(T.Is_reponsive(:,2)),:);


[p,tbl,stats] = anova1(responsive_cells.response, responsive_cells.main_structure);
savefig('response_responsive_cells_box_plot')
results = multcompare(stats);
resuls_tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
title('responsive_cells response')
savefig('response_responsive_cells_multiple_comp')
save('response_responsive_cells_multiple_comp', 'resuls_tbl')

cd ..

% IE cells
mkdir('IE cells')
cd('IE cells')
IE_cells = T(find(T.Is_reponsive_and_IR(:,2)),:);


[p,tbl,stats] = anova1(IE_cells.response, IE_cells.main_structure);
savefig('response_IE_cells_box_plot')
results = multcompare(stats);
resuls_tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
title('IE_cells response')
savefig('response_IE_cells_multiple_comp')
save('response_IE_cells_multiple_comp', 'resuls_tbl')

cd ..