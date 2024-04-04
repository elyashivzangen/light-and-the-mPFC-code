
function [tr, wl, int] = mselect_wls(file)


%%%%%%%%%%%%% Loads scope files %%%%%%%%%%%%%%%%%%

[s, w] = dos('dir/B c*.txt');        %display the filenames of the txt files in the current directory that start with rs
txt = regexp(w, '.txt', 'split');     %splits the character array into cell array of strings
txt = deblank(txt);                      %remove white space from end
txt = strtrim(txt);                          %remove white space from start
txt(:, length(txt)) = [];
txt(:);                                  %display txt



%%%%%%%%%%%% open one scope file %%%%%%%%%%%%%
for k = 1:length(txt)
    [A, B, C] = loadSpectrometerFile(txt{1,k});         % call the LOAD function and return A, B, and C
    str(k) = A;                              %sets str to equal A
    swl(:,k) = B;
    sint(:,k) = C;
    
    %     sint(:,k) = sint(:,k)./str(k).Time;   % normalize sint to an integration time of 1
    %
    %     %%% calculate reflectance; divide the measured reflectance by the
    %     %%% standard reflectance%%%%
    %
    %     cint(:,k) = sint(:,k)./stdint;
    
    % Calculate mean wl and intensity at a 1 nm interval for signal and reference files
    
    [wlselect, intselect] = spectralInterpolationSpectrometer(str(:,k), swl(:,k), sint(:,k));
    all_intselect(:,k) = intselect;
    
    outfid = fopen(['s' ,txt{1,k},'.txt'], 'w');   % 'w' erases any existing file and write a new one
    
    %output header lines
    
        fprintf(outfid, '%s \n','SpectraSuite Data File');
        fprintf(outfid, '%s \n', '++++++++++++++++++++++++++++++++++++');
        fprintf(outfid, '%s \n', ['Date: ',str(k).Date]);
        fprintf(outfid, '%s \n', ['User: ',str(k).User]);
        fprintf(outfid, '%s \n', ['Spectrometer: ',str(k).Spectrometer]);
        fprintf(outfid, '%s \n', ['Integration Time (sec): ',num2str(str(k).IntegrationTimesec)]);
        fprintf(outfid, '%s \n', ['Trigger mode: ',num2str(str(k).Triggermode)]);
        fprintf(outfid, '%s \n', ['Scans to average: ',num2str(str(k).Scanstoaverage)]);
        fprintf(outfid, '%s \n', ['Boxcar width: ',num2str(str(k).Boxcarwidth)]);
        fprintf(outfid, '%s \n', ['Electric dark correction enabled: ',str(k).Electricdarkcorrectionenabled]);
        fprintf(outfid, '%s \n', 'Nonlinearity correction enabled: No');
        fprintf(outfid, '%s \n', ['Number of Pixels in Spectrum: ', num2str(str(k).NumberofPixelsinSpectrum)]);
        fprintf(outfid, '%s \n', '>>>>>Begin Spectral Data<<<<<');
    
    %output numeric data line by line to file
    
    for loop2 = 1:length(intselect)
        fprintf(outfid,'%3.3f\t%E\n', wlselect(loop2),intselect(loop2));
    end
    fclose(outfid); %close finished corrected output file
    
end


outfid = fopen('Summary.txt', 'w+');   % 'w' erases any existing file and write a new one


fprintf(outfid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s', txt{:});
fprintf(outfid,'\n');
for loop2 = 1:length(intselect)
    fprintf(outfid,'%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E\t%E', all_intselect(loop2,:));
    fprintf(outfid,'\n');
end


fclose(outfid); %close finished corrected output file
end