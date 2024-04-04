cd('I:\My Drive\ELYASHIV\PFC_paper_results_after_revision\per_mouse\f6i')
clear
clc
x = importdata("all_ints_with_tags.mat");
%%
sp =  split(x.file_name,["_R", "_L",'_r','_l']);
x.mouse = sp(:,1);
per_mouse_per_tag = grpstats(x,["mouse", "tag"],"mean",DataVars=["Is_reponsive","Is_reponsive_and_IR"]);

per_mouse_per_tag.responsive = per_mouse_per_tag.mean_Is_reponsive(:,2);
per_mouse_per_tag.IE = per_mouse_per_tag.mean_Is_reponsive_and_IR(:,2);


mean_sem_per_mouse_per_tag = grpstats(per_mouse_per_tag,"tag",["mean","sem"],"DataVars",["responsive","IE"]);
%%
save('all_mice_c57_vs_DTA_vs_mcherry',"per_mouse_per_tag")

save('mean_sem_per_mouse_c57_vs_DTA_vs_mcherry',"mean_sem_per_mouse_per_tag")

%% stats
[pval,Factual,Fdist] = randanova1(per_mouse_per_tag.responsive,per_mouse_per_tag.tag,100000);
permutation_anova.responsive = pval;
[permutation_anova.IE,Factual,Fdist] = randanova1(per_mouse_per_tag.IE,per_mouse_per_tag.tag,100000);

g1.t = grp2idx(per_mouse_per_tag.tag);

effect_size_anova.responsive = mes1way(per_mouse_per_tag.responsive,'eta2','group',g1.t)
effect_size_anova.IE = mes1way(per_mouse_per_tag.IE,'eta2','group',g1.t)
%% 
[p.responsive_DTA_vs_mcherry, ~, effect_size.responsive_DTA_vs_mcherry] = permutationTest(per_mouse_per_tag.responsive(ismember(per_mouse_per_tag.tag,'DTA')),per_mouse_per_tag.responsive(ismember(per_mouse_per_tag.tag,'CONTROL')),100000)
[p.responsive_DTA_vs_C57, ~, effect_size.responsive_DTA_vs_C57] = permutationTest(per_mouse_per_tag.responsive(ismember(per_mouse_per_tag.tag,'DTA')),per_mouse_per_tag.responsive(ismember(per_mouse_per_tag.tag,'C57')),100000)
[p.responsive_C57_vs_mcherry, ~, effect_size.responsive_C57_vs_mcherry] = permutationTest(per_mouse_per_tag.responsive(ismember(per_mouse_per_tag.tag,'C57')),per_mouse_per_tag.responsive(ismember(per_mouse_per_tag.tag,'CONTROL')),100000)
[p.IE_DTA_vs_mcherry, ~, effect_size.IE_DTA_vs_mcherry] = permutationTest(per_mouse_per_tag.IE(ismember(per_mouse_per_tag.tag,'DTA')),per_mouse_per_tag.IE(ismember(per_mouse_per_tag.tag,'CONTROL')),100000)
[p.IE_DTA_vs_C57, ~, effect_size.IE_DTA_vs_C57] = permutationTest(per_mouse_per_tag.IE(ismember(per_mouse_per_tag.tag,'DTA')),per_mouse_per_tag.IE(ismember(per_mouse_per_tag.tag,'C57')),100000)
[p.IE_C57_vs_mcherry, ~, effect_size.IE_C57_vs_mcherry] = permutationTest(per_mouse_per_tag.IE(ismember(per_mouse_per_tag.tag,'C57')),per_mouse_per_tag.IE(ismember(per_mouse_per_tag.tag,'CONTROL')),100000)


save('permutation_anova', 'permutation_anova')
save('pairwise_pemutation', 'p')
save('pairwise_effect_size', 'effect_size')
save('anova_effect_size', 'effect_size_anova')


    