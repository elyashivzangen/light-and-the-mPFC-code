
function [in_structure_prob, G] = calc_structure_probability(measured_coords, std_dev,structure_coords, st,  join_structures)


% measured_coords: a 3-column matrix of measured coordinates for each dot
% std_dev: a 3-element vector of standard deviations for x, y, and z dimensions
% structure_coords: a 3D matrix where each element corresponds to the structure value for that point in the 3D space
% join structures = 1 if i want to take all the layers and join them - and
% present for example the hole ACA as one.
 %This function calculates the probability that each point in a set of measured coordinates lies within a given brain structure.
%
% Inputs:
%   - measured_coords: a 3-column matrix of measured coordinates for each dot
%   - std_dev: a 3-element vector of standard deviations for x, y, and z dimensions
%   - structure_coords: a 3D matrix where each element corresponds to the structure value for that point in the 3D space
%   - st: a structure tree containing information about the brain structures
%   - join_structures: a flag indicating whether to combine multiple brain structures into one
%
% Outputs:
%   - in_structure_prob: a vector containing the probability that each point in measured_coords lies within a brain structure
%   - G: a table containing the mean and standard error of the in_structure_prob for each brain structure
%
%%The function first checks whether the input measured_coords and
% structure_coords are in the correct orientation for compatibility. It then generates random samples around each dot using the provided standard deviation, converts the samples into 10 um coordinates to match the structure_coords, and determines the structure value for each sample.
% 
% The function then calculates the probability that each dot is in the same structure as the measured coordinates by counting the number of samples that have the same structure value as the measured coordinates and dividing by the total number of samples.
% 
% The function creates a table containing the original structure value and the probability of each dot being in that structure. It then groups the table by structure name and acronym and calculates the mean and standard error of the probability for each group. The function creates two figures: one showing the mean probability of each structure and another showing a histogram of the probability distribution for each structure.
% 
% Finally, the function saves the figures, data, and standard deviation used for the analysis.


if ~exist('measured_coords','var')
%load brain render table
[file, path] = uigetfile('clustering_data.csv','MultiSelect','off');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
brain_render_table = readtable(file);
measured_coords = table2array(brain_render_table(:, ["x", "y", "z"]));

%load stf sharp track file
[file, path] = uigetfile('mean_std.mat','MultiSelect','off');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
std_dev = load(file);
std_dev = std_dev.mean_std';

end


if ~exist('av','var') || ~exist('st','var')
    annotation_volume_location = 'C:\Users\elyashivz\Documents\analyzing_slices\annotation_volume_10um_by_index.npy';
    structure_tree_location = 'C:\Users\elyashivz\Documents\analyzing_slices\structure_tree_safe_2017.csv';
    disp('loading reference atlas...')
    structure_coords = readNPY(annotation_volume_location);
    st = loadStructureTree(structure_tree_location);
end

% Change st and structure_coords so layers 6a and 6b will be together
a6 = find(cellfun(@(x) contains(x , '6a'), st.acronym));
for i = 1:length(a6)
    structure_coords(structure_coords == a6(i)) = a6(i) + 1;
end
for  i = 1:length(a6)
    st.acronym{a6(i)} =  st.acronym{a6(i)}(1:end-1);
    st.acronym{a6(i)+1} =  st.acronym{a6(i)+1}(1:end-1);
end

% add dorsal and ventral ACA
ACAv = find(cellfun(@(x) contains(x , 'ACAv'), st.acronym));
ACAd = find(cellfun(@(x) contains(x , 'ACAd'), st.acronym));
for i = 1:length(ACAv)
    st.acronym{ACAv(i)} = (['ACA'  st.acronym{ACAv(i)}(5:end)]);
    st.acronym{ACAd(i)} = (['ACA'  st.acronym{ACAd(i)}(5:end)]);

    structure_coords(structure_coords == ACAv(i)) = ACAd(i);
end



%  join structures to main structures
if ~exist('join_structures', 'var')
    join_structures = 0;
end
if join_structures
    relevent_structs = ["ACA", "IL", "PL", "DP", "TT"]; %chnage to the relevaant stuctures to join in the st table
    for i = 1:length(relevent_structs)
        structures_idx = find(contains(st.acronym,relevent_structs{i}));
        st.acronym(structures_idx) = {relevent_structs{i}};
        structure_coords(ismember(structure_coords,structures_idx)) = structures_idx(1);
    end
end

        
mkdir('structures_probability')
cd('structures_probability')

% set the number of Monte Carlo samples
num_samples = 100000;

% initialize arrays to store the probabilities
in_structure_prob = zeros(size(measured_coords, 1), 1);
original_struct = in_structure_prob;


% flip x and z in measured_coords so itr will work with structure_coords
measured_coords =  flip(measured_coords,2);

% Define a random seed for reproducibility
rng(1234);

% loop through each dot
for i = 1:size(measured_coords, 1)
    samples = bsxfun(@plus, randn(num_samples, 3).*flip(std_dev), measured_coords(i,:));
    samples = round(samples./10); %change to 10 um coordinates like structure_coords
    % get the structure value for each sample
    for j = 1:num_samples
        sample_structures(j) = structure_coords(samples(j,1), samples(j,2), samples(j,3));
    end
    original_point = round(measured_coords(i, :)./10);
    original_struct(i) = structure_coords(original_point(1), original_point(2), original_point(3));
    in_structure_prob(i) = sum(sample_structures == original_struct(i))/num_samples;
end
    T = table(original_struct, in_structure_prob);
    T.struct_names = st.name(T.original_struct);
    T.acronym = st.acronym(T.original_struct);
    G = grpstats(T, ["struct_names", "acronym"], ["mean", "sem"], "DataVars","in_structure_prob");
    mean_probabilty_bar = figure;
    bar(categorical(G.acronym), G.mean_in_structure_prob)
    title('mean probabilty neuron is in structure')
    exportgraphics(mean_probabilty_bar, 'all_figs.pdf','Append',true )

    probabilties_histogram = figure;
    set(probabilties_histogram, 'color', [1 1 1]);
    set(probabilties_histogram,'position',[50 50 1750 800]);
    for i = 1:size(G,1)
        subplot(3,7, i)
        c = T.in_structure_prob(find(ismember(T.acronym, G.acronym{i})));
        histogram(c)
        title(G.acronym{i})
    end
    sgtitle('probabilties histogram')
    exportgraphics(probabilties_histogram, 'all_figs.pdf','Append',true )

    %% save
    savefig(probabilties_histogram,'probabilties_histogram' )
    savefig(mean_probabilty_bar,'mean_probabilty_bar' )
    save('all_cells_structers_probabilty', "T")
    save('mean_sem_structers_probabilty', "G")
    writetable( brain_render_table,"cells_coordinates_map.csv")
    save("shrap_track_std", "std_dev")
    cd ..
end
