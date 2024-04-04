%% premutation test sensativity analysis
mdes = sensativity_analysis_premutation_test

%%
function mdes = sensativity_analysis_premutation_test()
    desired_power = 0.80;
    alpha = 0.05;
    n_per_group = 60;
    n_simulations = 1000;
    effect_sizes = 0.3:0.01:0.6; % Adjust the range based on your context

    for effect_size = effect_sizes
        power_estimate = simulate_power(effect_size, n_per_group, n_simulations, alpha);
        if power_estimate >= desired_power
            fprintf('Minimum detectable effect size with desired power of %f is: %f\n', desired_power, effect_size);
            mdes = effect_size;
            return;
        end
    end
end

function power_estimate = simulate_power(effect_size, n_per_group, n_simulations, alpha)
    rejections = 0;
    for i = 1:n_simulations
        group1 = normrnd(0, 1, [n_per_group, 1]);
        group2 = normrnd(effect_size, 1, [n_per_group, 1]);
        combined = [group1; group2];
        actual_diff = abs(mean(group1) - mean(group2));
        permutation_diffs = zeros(1, 1000);
        for j = 1:1000
            shuffled = combined(randperm(length(combined)));
            shuffled_group1 = shuffled(1:n_per_group);
            shuffled_group2 = shuffled((n_per_group + 1):end);
            permutation_diffs(j) = abs(mean(shuffled_group1) - mean(shuffled_group2));
        end
        p_value = mean(permutation_diffs >= actual_diff);
        if p_value < alpha
            rejections = rejections + 1;
        end
    end
    power_estimate = rejections / n_simulations;
end
