function estimatedPower = permutationTestPowerAnalysis()
%%
% Parameters
nSimulations = 1000; % Number of simulations to estimate power
sampleSize = 300; % Number of observations per group
effectSize = 0.5; % Mean difference you want to detect
nPermutations = 1000; % Number of permutations for each test
alphaLevel = 0.05; % Significance level
powerCount = 0; % Count of tests rejecting null hypothesis

for i = 1:nSimulations
    % Generate data under null hypothesis
    % Random different SDs for each group
       % Split n into two parts for two samples
        n1 = floor(sampleSize / 2);
         n2 = sampleSize - n1;
    
    % Assign random different standard deviations for each sample
    SD = rand(1) + 0.5; % Ensures SD > 0.5 for sample 1
    
    % Assume means that would potentially lead to the desired effect size
    % The actual effect size may vary since we're now using different SDs
    M1 = 0;
    
   
    % Generate samples
    group1 = normrnd(M1, SD, [n1, 1]);
    M2 = mean(M1) + effectSize * SD; % Adjust M2 based on average SD

    group2 = normrnd(M2, SD, [n2, 1]);
%     group1 = normrnd(0, 1, [sampleSize, 1]);
    % Generate data under alternative hypothesis with specified effect size
%     group2 = normrnd(effectSize, 1, [sampleSize, 1]);
    [pValue, observeddifference(i), effectsize(i)] =  permutationTest(group1,group2,nPermutations);
    d(i) = computeCohen_d(group1,group2);
    % Perform permutation test
%     pValue = performPermutationTest(group1, group2, nPermutations);
    
    % Check if the test rejects the null hypothesis
    if pValue < alphaLevel
        powerCount = powerCount + 1;
    end
end

% Calculate estimated power
estimatedPower = powerCount / nSimulations;

fprintf('Estimated Power: %.4f\n', estimatedPower);
%%
end

function pValue = performPermutationTest(sample1, sample2, nPermutations)
observedDiff = abs(mean(sample1) - mean(sample2));
combined = [sample1; sample2];
moreExtreme = 0;

for i = 1:nPermutations
    permuted = combined(randperm(length(combined)));
    permSample1 = permuted(1:length(sample1));
    permSample2 = permuted((length(sample1)+1):end);
    permDiff = abs(mean(permSample1) - mean(permSample2));
    
    if permDiff >= observedDiff
        moreExtreme = moreExtreme + 1;
    end
end

pValue = moreExtreme / nPermutations;

end
