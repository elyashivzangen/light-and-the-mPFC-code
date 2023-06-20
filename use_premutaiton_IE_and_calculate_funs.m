%% use premutation + IE + calculate number of IE responsive FUN
[file, path] = uigetfile('*.mat','MultiSelect','on');
%%
calculate_IE_fun(file, path)
calculate_premutation_t1_for_3_ints_win(file, path)
calculate_IE_responsive_fun(file, path)