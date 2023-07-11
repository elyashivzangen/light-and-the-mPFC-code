function interpulated_psth = bin_psth(psth, downsampling)

cut_end = floor(length(psth)/downsampling)*downsampling;
binned_psth = mean(reshape(psth(1:cut_end), downsampling, []));
y = 1:length(binned_psth);
xq = 1/downsampling:1/downsampling:length(binned_psth);
interpulated_psth = interpn(y, binned_psth, xq, 'linear');
interpulated_psth(end:(end+(length(psth) - cut_end))) = interpulated_psth(end);
end

