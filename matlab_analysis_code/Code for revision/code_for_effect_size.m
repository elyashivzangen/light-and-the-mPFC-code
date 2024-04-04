cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\DREEDDS_VS_CONTROL\effect_size_diff')
clear
clc

c = importdata("all_cells_control.mat");
d = importdata('all_cells_dreadds.mat');
%%
hedgesg = [];
is_res = [];
is_ie = [];
tag = [];
to_remove = []

for i = 1:size(c{1},1)
    data = c{1}(i,:);
    b =  data{1,"intensities"}{1};
    a =  c{2}{i,"intensities"}{1};
    cohensd(i,:) = calculate_effect_size_function(b, a);
    is_res(i,1) =  data.Is_reponsive{1}(2);
    is_ie(i,1) =  data.Is_reponsive_and_IR{1}(2);
    tag{i,1} = 'control';
end

cT  = table(cohensd,is_res,is_ie,tag);
%%
    
cohensd = [];
is_res = [];
is_ie = [];
tag = [];
to_remove = []
for i = 1:size(d{1},1)
    data = d{1}(i,:);
    b =  data{1,"intensities"}{1};
    if size(b,2) == 8
        to_remove = [to_remove; i];
    end
end
d{1}(to_remove,:) = [];
d{2}(to_remove,:) = [];

%%


for i = 1:size(d{1},1)
    data = d{1}(i,:);
    b =  data{1,"intensities"}{1};
    a =  d{2}{i,"intensities"}{1};
    cohensd(i,:) = calculate_effect_size_function(b, a);
    is_res(i,1) =  data.Is_reponsive{1}(2);
    is_ie(i,1) =  data.Is_reponsive_and_IR{1}(2);
    tag{i,1} = 'dreadds';
end
dT  = table(cohensd,is_res,is_ie,tag);

%%
all_ints = [dT; cT]
%
[pval, t_orig, crit_t] = mult_comp_perm_t2(dT.cohensd,cT.cohensd,10000,1,0.05,0,'w',0)
NDs = ["ND1"; "ND2"; "ND3"; "ND4";"ND6";"ND8";"ND10"];
pval = pval';
T = table(NDs, pval);
g1 = grpstats(all_ints, "tag", "mean","DataVars","cohensd");
f1 = figure;
bar([g1.mean_cohensd])
xticklabels(["DREADDS", "CONTROL"])
ylabel('effect size (cohens d)')
legend(NDs)
exportgraphics(f1,'effect size dreadds vs control.jpg')
savefig(f1,'effect size dreadds vs control.fig')
writetable(T, "effect size dreadds vs control.csv")

    %%
    %% only ie cells
    all_ints = [dT(find(dT.is_ie),:); cT(find(cT.is_ie),:)]

[pval, t_orig, crit_t] = mult_comp_perm_t2(dT.cohensd(find(dT.is_ie),:),cT.cohensd(find(cT.is_ie),:),10000,-1,0.05,0,'w',0)
NDs = ["ND1"; "ND2"; "ND3"; "ND4";"ND6";"ND8";"ND10"];
pval = pval';
T = table(NDs, pval);
g1 = grpstats(all_ints, "tag", "mean","DataVars","cohensd");
f1 = figure;
bar([g1.mean_cohensd])
xticklabels(["DREADDS", "CONTROL"])
ylabel('effect size (cohens d)')
legend(NDs)
exportgraphics(f1,'effect size dreadds vs control only IE cells.jpg')
savefig(f1,'effect size dreadds vs control only IE cells.fig')
writetable(T, "effect size dreadds vs control only IE cells.csv")













%% calculate effectsize function
function effectsize = calculate_effect_size_function(b, a)
aint = struct2table(a);
aint = cell2mat(aint.intensty_data');
a_res = mean(aint(65:125,:),1) - mean(aint(1:30,:),1);
ares = reshape(a_res,[20, 7]);

bint = struct2table(b);
bint = cell2mat(bint.intensty_data');
b_res = mean(bint(65:125,:),1) - mean(bint(1:30,:),1);
bres = reshape(b_res,[20, 7]);
is_enhanced = mean(bres(:,1),"all") > 0;

if ~is_enhanced
    ares = ares*(-1);
    bres = bres*(-1);
end

for i = 1:7
    diff = bres(:,i) - ares(:,i);
    effectsize(i) = mean(diff)/std(diff);
end
end





