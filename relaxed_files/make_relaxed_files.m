% 31/03/22
% Make a folder with the relaxed files at the specified time point. 
%
clear
addpath('../utilities');
% Parameters
run_no = "009c"; %run number
res    = "2km";
timestep = 20000; %which number timestep (use to compute time)

% get the grid
[grid, ~] = get_grids(res, res);

% make directory
folder_in = strcat("/data/icesheet_output/aleey/wavi/INVREL_", run_no, "/run/");
fname_in  = strcat("outfile",  num2str(timestep,'%010.f'), ".mat");
fname_in  = strcat(folder_in, fname_in);
input     = load(fname_in);
time      = input.t;        %model time of output
folder_out = strcat("INVREL_" , run_no, "_at_", num2str(time), "yrs");
if exist(folder_out, 'dir') == 7 %if folder exists, delete it and contents
    rmdir(folder_out, 's') 
end 
mkdir(folder_out);  %make the folder if it doesn't exist

%copy all input files:
%folder = strcat("../cases/INVREL_", run_no, "/input/*.bin");
folder = strcat("/data/icesheet_output/aleey/wavi/INVREL_", run_no, "/input/*.bin");
copyfile(folder, strcat(folder_out, "/."));

%remove the thickness and velocity files if they exist
delete(strcat(folder_out, "/*thickness*"));
delete(strcat(folder_out, "/*u_vel*"));
delete(strcat(folder_out, "/*v_vel*"));


% save the relaxed thickness
gh = (input.h);
fname_out = strcat(folder_out, "/thickness_", folder_out, ".bin");
fid = fopen(fname_out, 'w', 'b');
fwrite(fid, gh, 'real*8');

%% interpolate velocities onto the u and v grids and save them
% we have to be careful because the u and v values are generally outputted
% on the h grid, whereas input on the u grid!

%h grid co-ords
gx = (grid.XX)'; gx = gx(:);
gy = (grid.YY)'; gy = gy(:);

% u velocity
gu = (input.u); gu = gu(:);
Fu = scatteredInterpolant(gx,gy,gu); %note that input velocities are on the h grid, so use same co-ords as before
u_out = zeros((grid.nx + 1), grid.ny);
for i = 1:(grid.nx + 1)
    for j = 1:grid.ny
        u_out(i,j) = Fu(grid.xxu(i), grid.yyu(j));
    end
end

% v velocity
gv = (input.v); gv = gv(:); %note that input velocities are on the h grid, so use same co-ords as before
Fv = scatteredInterpolant(gx,gy,gv);
v_out = zeros(grid.nx, grid.ny + 1);
for i = 1:grid.nx
    for j = 1:(grid.ny + 1)
        v_out(i,j) = Fv(grid.xxv(i), grid.yyv(j));
    end
end

%write the velocities
fname_out = strcat(folder_out, "/u_vel_", folder_out, ".bin");
fid = fopen(fname_out, 'w', 'b');
fwrite(fid, u_out, 'real*8');

fname_out = strcat(folder_out, "/v_vel_", folder_out, ".bin");
fid = fopen(fname_out, 'w', 'b');
fwrite(fid, v_out, 'real*8');

%%
% v1 = saturate(v_out, 2000, -2000);
% v2 = saturate((input.v), 2000, -2000);
% 
% clf; subplot(1,2,1); contourf(v1', 20, 'linestyle','none');c = colorbar; 
% subplot(1,2,2); contourf(v2', 20, 'linestyle', 'none'); c = colorbar;
