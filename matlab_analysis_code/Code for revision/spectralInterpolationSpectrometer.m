function [selectwl, selectint] = spectralInterpolationSpectrometer(tr, wl, int)
    

%interpolate intensity values to a 0.1 nm interval

for k = 1:size(int,2)

xi = 300:0.1:800; 
pp = interp1(wl(:,k),int(:,k),'linear','pp');
yi(:,k) = ppval(pp,xi);
plot(wl(:,k),int(:,k),'ko'), hold on, plot(xi,yi(:,k),'r:'), hold off;     %plot1 for salinity correction

%select intensity values to a 1 nm interval
yi = yi(:,k);
selectwl(:,k) = xi(find(xi == 300):10:find(xi == 800));  
selectint(:,k) = yi(find(xi == 300):10:find(xi == 800));  

% % smooth +-2 nm
% selectwl(:,k) = smooth(selectwl(:,k),5);
% selectint(:,k) = smooth(selectint(:,k),5);

end
