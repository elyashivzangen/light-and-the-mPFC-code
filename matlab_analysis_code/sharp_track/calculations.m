% load coordinates of the nearons
coords = struct2cell(CTP.coordinates);
coords = cellfun(@(x) x{1},coords)';
std_devs = [40, 80, 40];
% Load your matrix of structure coordinates
annotation_volume_location = 'C:\Users\elyashivz\Documents\analyzing_slices\annotation_volume_10um_by_index.npy';
structure_coords = readNPY(annotation_volume_location);


% Define the number of Monte Carlo samples to generate for each point
num_samples = 100000;

% Define a random seed for reproducibility
rng(1234);

% Initialize an array to store the probabilities for each point
point_probs = zeros(size(coords, 1), 1);

% Loop over each point in the coordinates matrix
for i = 1:size(coords, 1)
    % Generate Monte Carlo samples for this point
    samples = bsxfun(@plus, randn(num_samples, 3).*std_devs, coords(i,:));
    figure
    scatter3(samples(:, 1), samples(:, 2), samples(:, 3))
    % Calculate the probability that each sample falls within a structure
    sample_probs = zeros(num_samples, 1);
    for j = 1:size(structure_coords, 1)
        dists = pdist2(structure_coords(j,:), samples, 'euclidean', 'Smallest', 1);
        sample_probs = sample_probs + (dists < 1); % Replace 1 with your desired radius
    end

    % Calculate the probability that the original point falls within a structure
    point_probs(i) = mean(sample_probs);
end

% Normalize the point probabilities
point_probs = point_probs / sum(point_probs);
