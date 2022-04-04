% 31/03/21
% Generate interpolation files. Specify the input and output resolution,
% the case number and the timestep of the input file and this will create
% output interpolated binary files at the specified resolution. Currently
% produces output files for 
% - thickness
% - u velocity
% - v velocity
% [- viscosity]

%% Inputs: specify input resolution, case number, output resolution, time pt
input_res = "3km";
output_res = "2km";
case_number = "001"; %contains the info on the initial state of this run
timestep_of_input = 7000;
addpath('../utilities');

%% define grids for 1km, 2km, 3km resolutions
[grid_in, grid_out] = get_grids(input_res, output_res);

%% load the input file
folder_in = strcat("../cases/INVREL_", case_number, "/run/");
fname_in  = strcat("outfile",  num2str(timestep_of_input,'%010.f'), ".mat");
fname_in  = strcat(folder_in, fname_in);
input     = load(fname_in);

%compute the time output point and make folder
time = input.t;
folder_out = strcat("interp_INVREL" , case_number,"_", input_res, "_at_", num2str(time), "yrs_to", output_res);
if ~exist(folder_out); mkdir(folder_out); end %make the folder if it doesn't exist

%% create a scattered interpolant of input data and write outputs
% thickness
gx = (grid_in.XX)'; gx = gx(:);
gy = (grid_in.YY)'; gy = gy(:);
gh = (input.h); gh = gh(:);
Fh = scatteredInterpolant(gx,gy,gh);
h_out = zeros(grid_out.nx, grid_out.ny);
for i = 1:grid_out.nx
    for j = 1:grid_out.ny
        h_out(i,j) = Fh(grid_out.xx(i), grid_out.yy(j));
    end
end
fname_outh = strcat(folder_out, "/thickness_", folder_out, ".bin");
fid = fopen(fname_outh, 'w', 'b');
fwrite(fid, h_out, 'real*8');

% u velocity
gu = (input.u); gu = gu(:);
Fu = scatteredInterpolant(gx,gy,gu); %note that input velocities are on the h grid, so use same co-ords as before
u_out = zeros((grid_out.nx + 1), grid_out.ny);
for i = 1:(grid_out.nx + 1)
    for j = 1:grid_out.ny
        u_out(i,j) = Fu(grid_out.xxu(i), grid_out.yyu(j));
    end
end
fname_outu = strcat(folder_out, "/uvel_", folder_out, ".bin");
fid = fopen(fname_outu, 'w', 'b');
fwrite(fid, u_out, 'real*8');

% v velocity
gv = (input.v); gv = gv(:); %note that input velocities are on the h grid, so use same co-ords as before
Fv = scatteredInterpolant(gx,gy,gv);
v_out = zeros(grid_out.nx, grid_out.ny + 1);
for i = 1:grid_out.nx
    for j = 1:(grid_out.ny + 1)
        v_out(i,j) = Fv(grid_out.xxv(i), grid_out.yyv(j));
    end
end
fname_outv = strcat(folder_out, "/vvel_", folder_out, ".bin");
fid = fopen(fname_outv, 'w', 'b');
fwrite(fid, v_out, 'real*8');


%% reload solution and compare interpolated
figure(1); clf; 

%
%thickness
%
%input
subplot(3,2,1); contourf(grid_in.XX, grid_in.YY, (saturate((input.h),4000, 0))', 20, 'linestyle', 'none')
c = colorbar;
title(strcat("input: thickness at ", input_res))

%interpolated
fid = fopen(fname_outh); hh = fread(fid, 'real*8', 'b'); hh = reshape(hh, [grid_out.nx, grid_out.ny]);
subplot(3,2,2); contourf(grid_out.XX, grid_out.YY, (saturate((hh),4000, 0))', 20, 'linestyle', 'none')
c = colorbar;
title(strcat("output: interpolated thickness at ", output_res))

%
% u velocity
%
%input
subplot(3,2,3); contourf(grid_in.XX, grid_in.YY, (saturate(input.u, 2000, -2000))', 20, 'linestyle', 'none')
c = colorbar;
title(strcat("input: u-velocity at ", input_res))

%interpolated
fid = fopen(fname_outu); uu = fread(fid, 'real*8', 'b'); uu = reshape(uu, [(grid_out.nx)+1, grid_out.ny]);
subplot(3,2,4); contourf(grid_out.XXu, grid_out.YYu, (saturate((uu), 2000, -2000))', 20, 'linestyle', 'none')
c = colorbar;
title(strcat("output: interpolated u-velocity at ", output_res))
%xlim([-1.7, -1.4]*1e6)

%
% v velocity
%
%input
subplot(3,2,5); contourf(grid_in.XX, grid_in.YY, (saturate(input.v, 2000, -2000))', 20, 'linestyle', 'none')
c = colorbar;
title(strcat("input: v-velocity at ", input_res))

%interpolated
fid = fopen(fname_outv); vv = fread(fid, 'real*8', 'b'); vv = reshape(vv, [(grid_out.nx), (grid_out.ny +1)]);
subplot(3,2,6); contourf(grid_out.XXv, grid_out.YYv, (saturate((vv), 2000, -2000))', 20, 'linestyle', 'none')
c = colorbar;
title(strcat("output: interpolated v-velocity at ", output_res))



