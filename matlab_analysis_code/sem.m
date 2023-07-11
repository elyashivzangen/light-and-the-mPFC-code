%% calculate standart mean error.
%    sem = std(data, 0, dim)/sqrt(size(data,dim));

function sem = sem(data, dim)
    sem = std(data, 0, dim)/sqrt(size(data,dim));



end