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
%% clculate LFP conrdinates form cell_cordinates

%load channel map
load('C:\Users\elyashivz\Dropbox\מחקר\Data for final project\LFP\mapping_for_lfp\updated_new_uM_channelmap_Neuronexus_A1x32_Poly20x2Emat_kilosortChanMap.mat', 'xcoords', 'ycoords');



% load cell cordinates
cd("E:\2022")
[file,path]=uigetfile('*.csv','channels_coordinates');
cd(path)
cell_cordinates = readtable(file);

%load the lfp channels_coordinate
cd("E:\PFC\LFP")
[lfp_file, ~]=uigetfile([file(2:8) '.mat'], file);

%%
coords1D = ycoords;
not_nun = ~isnan(cell_cordinates.ch);
cell_cordinates = cell_cordinates(not_nun, :);
coords3D = table2array(cell_cordinates(:, 2:4));

indices = cell_cordinates.ch + 1;
A = [coords1D(indices), ones(length(coords1D(indices)), 1)];
xyz = (A'*A)\(A'*coords3D);


new3d = [coords1D ones(length(coords1D), 1)]*xyz;
channel = [1:length(coords1D)]';
depth = coords1D;
x = new3d(:, 1);
y = new3d(:, 2);
z = new3d(:, 3);

T = table(channel,depth,x, y ,z );
writetable(T, "Channels_coordinates")






% find the reagoin of each coordinate set in new3d
newxyz = round(new3d/10);
for i = 1:length(new3d)
    channel_coord = newxyz(i,:);
    idx(i) = av(channel_coord(3), channel_coord(2), channel_coord(1)); %sharp track switches beetween x and z (x is AP an Z is ML)
end

relevant_locations =  st(idx, :);

channels_coordinates = [T, relevant_locations(:,   ["acronym" "name"] )];
writetable(channels_coordinates, fullfile(path, "channels_coordinates.csv"))
writetable(channels_coordinates, [lfp_file(1:end-4),'_channels_coordinates.csv'])

% %% save the files by subreigions
% locations = unique(channels_coordinates.acronym);
% short_names = cellfun(@(x) x(1:2), locations, UniformOutput=false);
% short_names = unique(short_names);
% locations = [locations; short_names];
% load(lfp_file)
% for i = 1:size(locations, 1)
%     mkdir(locations{i})
%     relevant_channels = find(contains(channels_coordinates.acronym, locations{i}));
%     newLFP = LFP(:,"ND");
%     for j = 1:size(newLFP, 1)
%         newLFP.eria_mean{j} = squeeze(mean(LFP.all_repetitions{j}(relevant_channels, :, :)));
%         newLFP.eria_std{j} =  squeeze(std(LFP.all_repetitions{j}(relevant_channels, :, :)));
%         newLFP.total_mean{j} = squeeze(mean(newLFP.eria_mean{j}));
%     end
%     LFP.(locations{i}) = newLFP.total_mean;
%     LFP.locations{1} = channels_coordinates;
%     save(['E:\PFC\LFP\' locations{i} '\' lfp_file], "newLFP")
% end
save(['E:\PFC\LFP\' lfp_file], "LFP")


