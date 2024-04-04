
function [tr,wl,int] = correct_irradiance_file

%%%%%%%%%%%%% Loads dark files %%%%%%%%%%%%%%%%%%

[s,w]=dos('dir/B d*.txt');        %display the filenames of the txt files in the current directory that start with d
dtxt=regexp(w, '.txt', 'split');     %splits the character array into cell array of strings
dtxt=deblank(dtxt);                      %remove white space from end
dtxt=strtrim(dtxt);                          %remove white space from start
dtxt(:,length(dtxt)) = [];

dwl=zeros(1494,length(dtxt));         %preallocation for dwl
dint=zeros(1494,length(dtxt));        %preallocation for dint

for k =1:length(dtxt)
    [A,B,C]=loadSpectrometerFile(dtxt{1,k});
    dtr(k)=A;
    dwl(:,k)=B;
    dint(:,k)=C;
end

%%%%%%%%%%%%% Loads scope files %%%%%%%%%%%%%%%%%%
[s,w]=dos('dir/B p*.txt');        %display the filenames of the txt files in the current directory that start with d
txt=regexp(w,'.txt','split');     %splits the character array into cell array of strings
txt=deblank(txt);                      %remove white space from end
txt=strtrim(txt);                          %remove white space from startF
txt(:,length(txt)) = [];

%%%%%%%%%%% Finds the corresponding dark file for each of the scope files
swl=zeros(1494,length(txt));      %preallocation for swl
sint=zeros(1494,length(txt));     %preallocation for sint

for k =1:length(txt)                     % set up a loop for each of the numeric scope (s) files loaded
    [A,B,C] = loadSpectrometerFile(txt{1,k});         % call the LOAD function and return A, B, and C
    str(k)=A;                              %sets str to equal A
    swl(:,k)=B;                           %sets swl to equal B
    sint(:,k)=C;                          %sets sint to equal C

    [m] = arrayfun(@(x)find(x.IntegrationTimesec==str(k).IntegrationTimesec),dtr,'uniformoutput',false);

    for loop=1:length(m)                                               %change empty values in m to 0's
        if isempty(m{loop})
            m{loop}=0;
        end
    end

    m=cell2mat(m);                                                   %convert m to numeric array
    darkloc=find(m==1);                                              %find the locations in vector m == 1

    cint = zeros(length(dint),1);                                    %initialize cint (corrected intensity of the concerned scope file)

    if ~isempty(darkloc)                                                  %check to confirm that a matching dark file integration time was found
        cint(:,1) = sint(:,k) - dint(:,darkloc);         %subtract found dark file from current scope file

        ind = find(cint<0);           %in cint, sets values smaller than 0 to 0.
        cint(ind) = 0;




        % Loads cal_file

        file = 'mcalfile_HL-3plus_2m fiber_HUJI_CC_Mar_16_2020';          %%%%%%%%%%%% change file name % % % % % % %%%%%%%%%%%%%%%%%%%%%%%%%



        fid = fopen([file,'.txt']);
        c = textscan(fid,'%f%f','Delimiter','   ');
        cal_wl = c{1};
        cal_irradiance = c{2};  % come in uJoules/ counts
        fclose(fid)
        
        
        ind = find(cal_wl<=300);           %delete wl smaller than 300 nm
        cal_wl(ind) = [];
        cal_irradiance(ind) = [];

        ind = find(cal_wl>802);           %delete wl larger than 801 nm
        cal_wl(ind) = [];
        cal_irradiance(ind) = [];       
       
        % calculates Joules
        cint = (cal_irradiance./1000000).*cint(:,1);     %divide the interpolated lamp file by the master light file

        % calculates Joule m-2
        fiber = 0.0000119459060652752;  %area of a cosine corrector in meters
        
        %fiber = 0.0000002827 ;         %area of a bare fiber in meters
        
        cint = cint./fiber;

        % calculates Joule m-2 s-1 or W m-2
        int_time = str(k).IntegrationTimesec;          %calculates the integration time of the master in seconds          %calculates the integration time of the slave in seconds
        cint = cint./int_time;

        % calculates W m-2 nm-1
        %%%%% Choose the apropriate polyfit according the spectromter used%%
        %%all polyfit equations are found in the 'calculating wavelength
        % coefficients for Jaz and QE' excel file, in the 'calibration test
        % 191208 - Jaz and QE' folder%%% 
        
 %       polyfit = 4E-11.*swl(:,k).^3-2E-8.*swl(:,k).^2+0.0002.*swl(:,k)+1.2066;         % polyfit for QE%


         %polyfit = 2E-9.*swl(:,k).^3-2E-6.*swl(:,k).^2+0.002.*swl(:,k)+2.1936;       %polyfit for signal channel (0 channel) Jaz%
        

%        polyfit = 1E-9.*swl(:,k).^3-1E-6.*swl(:,k).^2+0.0014.*swl(:,k)+2.3307;          %polyfit for reference channel (1 channel) Jaz%

         
         %polyfit = -3E-8.*swl(:,k).^3+6E-5.*swl(:,k).^2+0.0352.*swl(:,k)+12.281;       %polyfit for USB 4000 Berson lab (June 08 2015)
        
         polyfit = 5E-10.*swl(:,k).^3+7E-7.*swl(:,k).^2+0.0004.*swl(:,k)+0.1568;       %polyfit for Flame Sabbah lab (Feb. 17 2019)
        
        cint = cint.*polyfit;

        %%%% For melanopic EDI calculation - Irradiance in W m-2
        xq=300:1:800
        vq_highest = interp1(swl,cint,xq,'nearest')'
        vq_lowest = interp1(swl,cint./10000000,xq,'nearest')';      % 7 OD


%         % calculates umol photons m-2 nm-1
% 
        cint = (cint.*swl(:,k))/(6.63E-34*3E17);
% 
%         % calculates umol photons cm-2 nm-1
% 
        cint = cint./10000;
% 
%         % calculates umol photons cm-2 sr-1 nm-1
%         %NEED TO CONFIRM THE CONVERSION TO SR %%%%%%
%         
%         solid_angle = 0.0239094170393268;       %units: sr (steradians); % for an acceptance angle restrictor of 5 degrees

%         bb_solid_angle = 0.146572398020731;     % the solid angle of a bare fiber
%         solid_angle_ratio = solid_angle/bb_solid_angle;
          solid_angle = 0.4973425161;     % the solid angle of the bare 8m fiber (core 600um) in the Berson lab
            
          %cint = cint./solid_angle;       
        



        %%%%%% output radiance dark and ND corrected data file [umol photons cm-2 sr-1 nm-1] %%%%%%%%%%%%%%%%%%%%


        outfid = fopen(['c' ,txt{1,k},'.txt'], 'w');   % 'w' erases any existing file and write a new one

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

        for loop2 = 1:length(cint)
            fprintf(outfid,'%3.3f\t%E\n', swl(loop2,k),cint(loop2));
        end
        fclose(outfid); %close finished corrected output file
    end  % if ~isempty
end %for loop

