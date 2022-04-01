% 29/03/22
% Explore relaxation solutions when stored in .mat format. Produces plots
% of:
% (1) evolution of grounded volme
% (2) videos of evolution of ice velocity and ice velocity difference
% between output time ponts
addpath('../plot_tools');

clear

% preliminaries
folder = "../cases/INVREL_001/run/"; %must end with "/"
sdir = dir(strcat(folder, "*.mat"));
lt = length(sdir);

% grid info
nx = 268; ny = 315; dx = 3000; dy = 3000; %3km resolution


% setup storage
sol.t      = zeros(1,lt);
sol.grfrac = zeros(nx,ny,lt); %grounded fraction
sol.h      = zeros(nx,ny,lt); %ice thickness
sol.u      = zeros(nx,ny,lt); %u velocity
sol.v      = zeros(nx,ny,lt); %v velocity
sol.grv    = zeros(1,lt);

% loop and store
for i = 1:length(sdir)
    fname = strcat(folder, sdir(i).name);
    sol_now = load(fname, 't', 'h', 'grounded_frac', 'u', 'v');
    sol.t(i) = sol_now.t;
    sol.grfrac(:,:,i) = sol_now.grounded_frac;
    sol.h(:,:,i)      = sol_now.h;
    sol.u(:,:,i)      = sol_now.u;
    sol.v(:,:,i)      = sol_now.v;
    sol.grv(i)        = sum(sum(sol_now.h .* sol_now.grounded_frac .* dx * dy));
end

%unchancing co-ordinates
coords = load(fname, 'b','x', 'y', 'h_mask'); %nchanging so use last file
sol.bathy = coords.b;
sol.x     = coords.x;
sol.y     = coords.y;
sol.h_mask= coords.h_mask;
%% Plots
% Plot 1: plot of the grounded fraction as a function of time
figure(1); clf;
plot(sol.t,sol.grv/1e9, 'ro-')
xlabel('time (years)');
ylabel('grounded volume (km^3)')
title('evolution of grounded volume');

% Plot 2: plot (a) ice velocity and (b) difference is ice velocity between
% time output points. Also stores the norm of difference in ice velocites
% between timesteps
norm_vel_diff = nan(1,lt);
figure(2); clf;
for i = 2:5:lt
    
    u = (squeeze(sol.u(:,:,i)));
    v = (squeeze(sol.v(:,:,i)));
    grfrac = squeeze(sol.grfrac(:,:,i));
    uu = sqrt(u.^2 + v.^2);
    uu_diff = uu- sqrt((squeeze(sol.u(:,:,i-1))).^2 + (squeeze(sol.v(:,:,i-1))).^2);
    hh =  (squeeze(sol.h(:,:,i)));
    hh_diff = hh - (squeeze(sol.h(:,:,i-1)));
    
    %remove non-mask entries
    h_mask = sol.h_mask;
    not_mask = (sol.h_mask == 0);
    
    u(not_mask) = nan;
    v(not_mask) = nan;
    uu(not_mask) = nan;
    uu_diff(not_mask) = nan;
    hh(not_mask) = nan;
    hh_diff(not_mask) = nan;
    norm_vel_diff(i) = mean(mean(uu_diff(~not_mask))); %mean of non nan entries

    %h_mask(h_mask == 0) = nan;
    
    %saturate the colorbar
    uu = saturate(uu, 2000*1.1, -2000);
    sv = 100;
    uu_diff = saturate(uu_diff, sv*1.1, -sv);
    hh = saturate(hh, 3000, 0);
    hh_diff = saturate(hh_diff, 5, 0);

    
    %First row: velocities
    clf;
    subplot(2,2,1); title(['t = ' num2str(sol.t(i))])
    hold on; box on
    contourf(sol.x, sol.y, uu, 20, 'linestyle', 'none');
    ax1 = gca; colormap(ax1, 'parula')
    c = colorbar; c.Label.String = 'ice velocity';
    %add ice mask contour
    ax2 = axes;
    contour(sol.x, sol.y, h_mask, [0.5, 0.5],'k')
    ax2.Position = ax1.Position;
    ax2.Visible = 'off';
    
    %Second panel: velocity difference between timesteps
    subplot(2,2,2);    title(['t = ' num2str(sol.t(i))])
    hold on; box on
    contourf(sol.x, sol.y, uu_diff, 20, 'linestyle', 'none');
    ax3 = gca; colormap(ax3, redblue)
    c = colorbar; c.Label.String = 'ice velocity difference';
    %add ice mask contour
    ax4 = axes;
    contour(sol.x, sol.y, h_mask, [0.5, 0.5],'k')
    ax4.Visible = 'off';
    ax4.Position = ax3.Position;
    ax4.Position = ax3.Position;
    
    % Second row: ice thicness
    subplot(2,2,3);
    hold on; box on
    contourf(sol.x, sol.y, hh, 20, 'linestyle', 'none');
    ax5 = gca; colormap(ax5, 'parula')
    c = colorbar; c.Label.String = 'ice thickness';
    %add ice mask contour
    ax6 = axes;
    contour(sol.x, sol.y, h_mask, [0.5, 0.5],'k')
    ax6.Position = ax1.Position;
    ax6.Visible = 'off';
    
    subplot(2,2,4);    title(['t = ' num2str(sol.t(i))])
    hold on; box on
    contourf(sol.x, sol.y, hh_diff, 20, 'linestyle', 'none');
    ax7 = gca; colormap(ax7, parula)
    c = colorbar; c.Label.String = 'ice velocity difference';
    %add ice mask contour
    ax8 = axes;
    contour(sol.x, sol.y, h_mask, [0.5, 0.5],'k')
    ax8.Visible = 'off';
    ax8.Position = ax7.Position;

    drawnow
    %pause
end

%% Plot 3
figure(3); clf;
plot(sol.t, norm_vel_diff, 'ro-')
