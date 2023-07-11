% delete non relevant nds
 [datafile, path] = uigetfile('*.mat','MultiSelect','on');
 cd(path)
nds = [10,8,6,4,3,2,1];




for i = 1:length(datafile)
    load(datafile{1,i});
    if iscell(all_data)
        all_data = all_data{1,1};
    end
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        c = all_data.(cells{j});
        for k = nds
            ints(k) = c.intensities(k);
        end
        c.intensities = ints;
        c.baseline_vector.mean = c.baseline_vector.mean(flip(nds));
        c.baseline_vector.std = c.baseline_vector.std(flip(nds));
        all_data.(cells{j}) = c;
    end
    save(file{1,i}, "all_data")
end
