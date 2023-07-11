[file, path] = uigetfile('cluster_info.tsv');
datafile = fullfile(path, file);
w = tdfread(datafile);

cd(path)

good_idx = find(w.KSLabel(:, 1) == 'g');
A = readNPY('templates.npy');
waveforms = zeros(length(good_idx), size(A , 2));
tamplate_ind = readNPY('templates_ind.npy');
%%
for i = 1:length(good_idx)
    waveforms(i, :) = A(w.id(good_idx(i))+1 , :, w.ch(good_idx(i))+1);
    figure
    plot(waveforms(i, :))
    title(w.id(good_idx(i)))
end
    