function [grid_in, grid_out] = get_grids(input_res, output_res)

%% 3km
grid3km.x0 = -1792500.0;
grid3km.y0 = -838500.;
grid3km.nx = 268;
grid3km.ny = 315;
grid3km.dx = 3000.0;
grid3km.dy = 3000.0;

%h grid
grid3km.xx = (grid3km.x0 + 0.5*grid3km.dx): grid3km.dx : (grid3km.x0 + 0.5*grid3km.dx + (grid3km.nx-1)*grid3km.dx) ;
grid3km.yy = (grid3km.y0 + 0.5*grid3km.dy): grid3km.dy : (grid3km.y0 + 0.5*grid3km.dy + (grid3km.ny-1)*grid3km.dy) ;
[grid3km.XX, grid3km.YY] = meshgrid(grid3km.xx, grid3km.yy);


%u grid
grid3km.xxu = (grid3km.x0): grid3km.dx : (grid3km.x0 + (grid3km.nx)*grid3km.dx) ;
grid3km.yyu = (grid3km.y0 + 0.5*grid3km.dy): grid3km.dy : (grid3km.y0 + 0.5*grid3km.dy + (grid3km.ny-1)*grid3km.dy) ;
[grid3km.XXu, grid3km.YYu] = meshgrid(grid3km.xxu, grid3km.yyu);

%v grid
grid3km.xxv = (grid3km.x0 + 0.5*grid3km.dx): grid3km.dx : (grid3km.x0 + 0.5*grid3km.dx + (grid3km.nx-1)*grid3km.dx);
grid3km.yyv =  (grid3km.y0): grid3km.dy : (grid3km.y0 + (grid3km.ny)*grid3km.dy) ;
[grid3km.XXv, grid3km.YYv] = meshgrid(grid3km.xxv, grid3km.yyv);

%% 2km
grid2km.nx =  398 ;
grid2km.ny = 468;
grid2km.x0 = -1789000.0;
grid2km.y0 = -833000.0;
grid2km.dx = 2000.0;
grid2km.dy = 2000.0;

%h grid
grid2km.xx = (grid2km.x0 + 0.5*grid2km.dx): grid2km.dx : (grid2km.x0 + 0.5*grid2km.dx + (grid2km.nx-1)*grid2km.dx) ;
grid2km.yy = (grid2km.y0 + 0.5*grid2km.dy): grid2km.dy : (grid2km.y0 + 0.5*grid2km.dy + (grid2km.ny-1)*grid2km.dy) ;
[grid2km.XX, grid2km.YY] = meshgrid(grid2km.xx, grid2km.yy);

%u grid
grid2km.xxu = (grid2km.x0): grid2km.dx : (grid2km.x0 + (grid2km.nx)*grid2km.dx) ;
grid2km.yyu = (grid2km.y0 + 0.5*grid2km.dy): grid2km.dy : (grid2km.y0 + 0.5*grid2km.dy + (grid2km.ny-1)*grid2km.dy) ;
[grid2km.XXu, grid2km.YYu] = meshgrid(grid2km.xxu, grid2km.yyu);

%v grid
grid2km.xxv = (grid2km.x0 + 0.5*grid2km.dx): grid2km.dx : (grid2km.x0 + 0.5*grid2km.dx + (grid2km.nx-1)*grid2km.dx);
grid2km.yyv =  (grid2km.y0): grid2km.dy : (grid2km.y0 + (grid2km.ny)*grid2km.dy) ;
[grid2km.XXv, grid2km.YYv] = meshgrid(grid2km.xxv, grid2km.yyv);

%% 1km
grid1km.nx =  788 ;
grid1km.ny = 928;
grid1km.x0 = -1784500.0;
grid1km.y0 = -829500.0;
grid1km.dx = 1000.0;
grid1km.dy = 1000.0;

% h grid
grid1km.xx = (grid1km.x0 + 0.5*grid1km.dx): grid1km.dx : (grid1km.x0 + 0.5*grid1km.dx + (grid1km.nx-1)*grid1km.dx) ;
grid1km.yy = (grid1km.y0 + 0.5*grid1km.dy): grid1km.dy : (grid1km.y0 + 0.5*grid1km.dy + (grid1km.ny-1)*grid1km.dy) ;
[grid1km.XX, grid1km.YY] = meshgrid(grid1km.xx, grid1km.yy);

%u grid
grid1km.xxu = (grid1km.x0): grid1km.dx : (grid1km.x0 + (grid1km.nx)*grid1km.dx) ;
grid1km.yyu = (grid1km.y0 + 0.5*grid1km.dy): grid1km.dy : (grid1km.y0 + 0.5*grid1km.dy + (grid1km.ny-1)*grid1km.dy) ;
[grid1km.XXu, grid1km.YYu] = meshgrid(grid1km.xxu, grid1km.yyu);

%v grid
grid1km.xxv = (grid1km.x0 + 0.5*grid1km.dx): grid1km.dx : (grid1km.x0 + 0.5*grid1km.dx + (grid1km.nx-1)*grid1km.dx);
grid1km.yyv =  (grid1km.y0): grid1km.dy : (grid1km.y0 + (grid1km.ny)*grid1km.dy) ;
[grid1km.XXv, grid1km.YYv] = meshgrid(grid1km.xxv, grid1km.yyv);

%% Grid selection
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
end
