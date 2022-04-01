% 31/03/22
% Make a folder with the relaxed files at the specified time point. 
%
clear

% Parameters
run_no = "001"; %run number
timestep = 5000; %which number timestep (use to compute time)

% make directory
folder_in = strcat("../cases/INVREL_", run_no, "/run/");
fname_in  = strcat("outfile",  num2str(timestep,'%010.f'), ".mat");
fname_in  = strcat(folder_in, fname_in);
input     = load(fname_in);
time      = input.t;        %model time of output
folder_out = strcat("INVREL_" , run_no, "_at_", num2str(time), "yrs");
if exist(folder_out) == 7 %if folder exists, delete it and contents
    rmdir(folder_out, 's') 
end 
mkdir(folder_out);  %make the folder if it doesn't exist

%copy all input files:
folder = strcat("../cases/INVREL_", run_no, "/input/*.bin");
copyfile(folder, strcat(folder_out, "/."));

%remove the thickness file
delete(strcat(folder_out, "/*thickness*"));

% save the relaxed thickness
gh = (input.h);
fname_out = strcat(folder_out, "/thickness_", folder_out, ".bin");
fid = fopen(fname_out, 'w', 'b');
fwrite(fid, gh, 'real*8');


