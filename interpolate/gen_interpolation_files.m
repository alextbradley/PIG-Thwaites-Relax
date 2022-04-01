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

%% define grids for 1km, 2km, 3km resolutions
%3km
grid3km.x0 = -1792500.0;
grid3km.y0 = -838500.;
grid3km.nx = 268;
grid3km.ny = 315;
grid3km.dx = 3000.0;
grid3km.dy = 3000.0;
grid3km.xx = (grid3km.x0 + 0.5*grid3km.dx): grid3km.dx : (grid3km.x0 + 0.5*grid3km.dx + (grid3km.nx-1)*grid3km.dx) ;
grid3km.yy = (grid3km.y0 + 0.5*grid3km.dy): grid3km.dy : (grid3km.y0 + 0.5*grid3km.dy + (grid3km.ny-1)*grid3km.dy) ;
[grid3km.XX, grid3km.YY] = meshgrid(grid3km.xx, grid3km.yy);


%2km
grid2km.nx =  398 ;
grid2km.ny = 468;
grid2km.x0 = -1789000.0;
grid2km.y0 = -833000.0;
grid2km.dx = 2000.0;
grid2km.dy = 2000.0;
grid2km.xx = (grid2km.x0 + 0.5*grid2km.dx): grid2km.dx : (grid2km.x0 + 0.5*grid2km.dx + (grid2km.nx-1)*grid2km.dx) ;
grid2km.yy = (grid2km.y0 + 0.5*grid2km.dy): grid2km.dy : (grid2km.y0 + 0.5*grid2km.dy + (grid2km.ny-1)*grid2km.dy) ;
[grid2km.XX, grid2km.YY] = meshgrid(grid2km.xx, grid2km.yy);


%1km
grid1km.nx =  788 ;
grid1km.ny = 928;
grid1km.x0 = -1784500.0;
grid1km.y0 = -829500.0;
grid1km.dx = 1000.0;
grid1km.dy = 1000.0;
grid1km.xx = (grid1km.x0 + 0.5*grid1km.dx): grid1km.dx : (grid1km.x0 + 0.5*grid1km.dx + (grid1km.nx-1)*grid1km.dx) ;
grid1km.yy = (grid1km.y0 + 0.5*grid1km.dy): grid1km.dy : (grid1km.y0 + 0.5*grid1km.dy + (grid1km.ny-1)*grid1km.dy) ;
[grid1km.XX, grid1km.YY] = meshgrid(grid1km.xx, grid1km.yy);


if input_res == "3km"
    grid_in = grid3km;
elseif input_res == "2km"
    grid_in = grid2km;
elseif input_res == "1km"
    grid_in = grid1km;
else
    error('input resolution')
end

if output_res == "3km"
    grid_out = grid3km;
elseif output_res == "2km"
    grid_out = grid2km;
elseif output_res == "1km"
    grid_out = grid1km;
else
    error('output resolution')
end



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
Fu = scatteredInterpolant(gx,gy,gu);
u_out = zeros(grid_out.nx, grid_out.ny);
for i = 1:grid_out.nx
    for j = 1:grid_out.ny
        u_out(i,j) = Fu(grid_out.xx(i), grid_out.yy(j));
    end
end
fname_outu = strcat(folder_out, "/uvel_", folder_out, ".bin");
fid = fopen(fname_outu, 'w', 'b');
fwrite(fid, u_out, 'real*8');

% v velocity
gv = (input.v); gv = gv(:);
Fv = scatteredInterpolant(gx,gy,gv);
v_out = zeros(grid_out.nx, grid_out.ny);
for i = 1:grid_out.nx
    for j = 1:grid_out.ny
        v_out(i,j) = Fv(grid_out.xx(i), grid_out.yy(j));
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
subplot(2,2,1); contourf(grid_in.XX, grid_in.YY, (saturate((input.h),4000, 0))', 20, 'linestyle', 'none')
c = colorbar;
title(strcat("input: thickness at ", input_res))

%interpolated
fid = fopen(fname_outh); hh = fread(fid, 'real*8', 'b'); hh = reshape(hh, [grid_out.nx, grid_out.ny]);
subplot(2,2,2); contourf(grid_out.XX, grid_out.YY, (saturate((hh),4000, 0))', 20, 'linestyle', 'none')
c = colorbar;
title(strcat("output: interpolated thickness at ", output_res))


%
% velocity
%
%input
invel = sqrt((input.u).^2 + (input.v).^2);
subplot(2,2,3); contourf(grid_in.XX, grid_in.YY, (saturate(invel, 3000, 0))', 20, 'linestyle', 'none')
c = colorbar;
title(strcat("input: velocity at ", input_res))

%interpolated
fid = fopen(fname_outu); uu = fread(fid, 'real*8', 'b'); uu = reshape(uu, [grid_out.nx, grid_out.ny]);
fid = fopen(fname_outv); vv = fread(fid, 'real*8', 'b'); vv = reshape(vv, [grid_out.nx, grid_out.ny]);
interpvel = sqrt((uu).^2 + (vv).^2);
subplot(2,2,4); contourf(grid_out.XX, grid_out.YY, (saturate((interpvel), 3000, 0))', 20, 'linestyle', 'none')
c = colorbar;
title(strcat("output: interpolated velocity at ", output_res))




