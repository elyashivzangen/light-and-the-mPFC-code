function [tr,wave,intensity] = loadSpectrometerFile(file)

labs = {
'Date:                                  ',
'User:                                  ',
'Spectrometer:                          ',
'Trigger mode:                          ',
'Integration Time (sec):                ',
'Scans to average:                      ',
'Electric dark correction enabled:      ',
'Nonlinearity correction enabled:       ',
'Boxcar width:                          ',
'Number of Pixels in Spectrum:          '};

fid = fopen([file,'.txt']);
for i=1:13
    in = fgetl(fid);
%     if in(1)=='"'
%         in(1)=[];
%     end       
%     if in(end)=='"'
%         in(end)=[];
%     end 
    for j=1:length(labs)
        tlabs=strtrim(labs{j});
        tag=tlabs(1:end-1);
        tag=regexprep(tag,' ','');
        tag=regexprep(tag,'(','');
        tag=regexprep(tag,')','');
        tag=regexprep(tag,'/','Or');
        tag=regexprep(tag,'-','');
        labloc = strfind(in,tlabs);
        if(labloc==1)
            v(1)=labloc(1)+length(tlabs);
            v(2)=length(in);
            if ischar(in(v(1):v(2)))
            tr.(tag)=in(v(1):v(2));
            else
            tr.(tag)=num2str(in(v(1):v(2)));
            end
        end 
    end 
end 

parind=findstr(tr.IntegrationTimesec,'(');
tr.IntegrationTimesec(parind-1:end)=[];
tr.IntegrationTimesec=str2num(tr.IntegrationTimesec);

parind=findstr(tr.Scanstoaverage,'(');
tr.Scanstoaverage(parind-1:end)=[];
tr.Scanstoaverage=str2num(tr.Scanstoaverage);

parind=findstr(tr.Boxcarwidth,'(');
tr.Boxcarwidth(parind-1:end)=[];
tr.Boxcarwidth=str2num(tr.Boxcarwidth);

parind=findstr(tr.Electricdarkcorrectionenabled,'(');
tr.Electricdarkcorrectionenabled(parind-1:end)=[];

parind=findstr(tr.Nonlinearitycorrectionenabled,'(');
tr.Nonlinearitycorrectionenabled(parind-1:end)=[];

parind=findstr(tr.NumberofPixelsinSpectrum,'(');
tr.NumberofPixelsinSpectrum(parind-1:end)=[];
tr.NumberofPixelsinSpectrum=str2num(tr.NumberofPixelsinSpectrum);

c=textscan(fid,'%f%f','delimiter','\t','headerlines',1);
% if file(1)~='c'
% c=textscan(fid,'%f%f','delimiter','\t','headerlines',1);
% end
wave=c{1};
intensity=c{2};

ind=find(wave<=300);           %delete wl smaller than 300 nm
wave(ind)=[];
intensity(ind)=[];

ind=find(wave>802);           %delete wl larger than 801 nm
wave(ind)=[];
intensity(ind)=[];


% c = textscan(fid,'%f%f','Delimiter','   ','headerlines',1);
% dirc = c{1};
% display(dirc)

% save('log2.dat','tr','dirc')        % need to combine log2 and frameWaveLog as a single file 

fclose(fid);


