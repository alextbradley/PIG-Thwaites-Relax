% 05/05/2022

% Demonstrate the relaxation for the 2km bedmap case. 
% !! NB !! This code only works if the restarting is performed by actually restarting the model with thickness file etc, rather than with a pickup.

%
% Preliminaries
%
set(0,'DefaultTextInterpreter','latex','DefaultAxesFontSize',12,'DefaultTextFontSize',12);
addpath('../plot_tools');
outdir = "/data/icesheet_output/aleey/wavi";

%
% Plot flags
% 
vaf_evolution = 1; %plot time evolution of vaf and grounded volume as a function of time
relax_video   = 0; %video evolution of thickness and velocity, and their differences. Also produces a plot of the norm of velocity gradient and thickness gradient
video_out     = 0; %set to one to save the above as a video

% choose case
runspec = '2km_bedmap'; %options: 2km_bedmap, 2km_bedmachine, 3km_bedmap, 3km_bedmachine


if runspec == "2km_bedmap" % 2km bedmap
run_nos = ["008", "009", "009c"];  %bedmap 2km
te      = [70, 200, inf];    %length of the block
vidname       = 'bedmap_2km_relax';
gridsize = 2; %2km


elseif runspec == "2km_bedmachine" % 2km bedmachine
run_nos = ["015"]; %bedmachine 2km
te      = [inf];   
vidname = 'bedmachine_2km_relax';
gridsize = 2;


elseif runspec == "3km_bedmachine"
run_nos = ["012"];
te = [inf];
vidname = 'bedmachine_3km_relax';
gridsize = 3; 

elseif runspec == "3km_bedmap"
run_nos = ["011","011c"];
te = [1950, inf];
vidname = 'bedmap_3km_relax';
gridsize = 3; 

else 
error('incorrect runspec')
end

if gridsize == 2%2km
nx = 398;
ny = 468;
dx = 2000; 
dy = 2000;

elseif gridsize == 3%3km
nx = 268; 
ny = 315;
dx = 3000;
dy = 3000; 
end

cte     = [0, cumsum(te)]; 
cte     = cte(1:end-1);   %cumulative time



%
% Get the data
%
ss = struct;
count = 1;

for ir = 1:length(run_nos)
jdir = dir(strcat(outdir, "/INVREL_", run_nos(ir), "/run/*.mat"));
for is = 1:length(jdir)
	sol = load(strcat(outdir, "/INVREL_", run_nos(ir), "/run/" ,jdir(is).name));
	if sol.t <= te(ir)
		ss(count).t = sol.t + cte(ir);
		ss(count).h = sol.h;
		ss(count).x = sol.x;
		ss(count).y = sol.y;
		ss(count).grfrac = sol.grounded_frac;
		ss(count).u = sol.u;
		ss(count).v = sol.v;
		ss(count).h_mask = sol.h_mask;

		%compute vaf
 		ss(count).grv = sum(sum(sol.h .* sol.grounded_frac .* dx * dy));
		height_above_floatation = sol.h - (1028.0/918.0)*(-sol.b);
    		ss(count).vaf = sum(sum(height_above_floatation(height_above_floatation > 0))) * dx *dy;

		count = count + 1;
	end
end
end

%
% Plots
%
numplot = 1; 

%
% VAF plot
%
if vaf_evolution
	subplot 121;  box on
 	plot([ss.t],[ss.vaf]/1e9, 'ro-')
	xlabel('time (years)');
	ylabel('volume above floatation ($\mathrm{km}^3$)')
	title('evolution of VAF');

	subplot 122;  box on
	plot([ss.t],[ss.grv]/1e9, 'ro-')
	xlabel('time (years)');
	ylabel('grounded volume ($\mathrm{km}^3$)')
	title('evolution of grounded volume');
	numplot = numplot + 1;
end

%
% Video of relaxation
%
if relax_video
if video_out; vid = VideoWriter(strcat(vidname, '.avi'));open(vid); end
for i = 2:length([ss.t])
    
    u = ss(i).u;
    v = ss(i).v;
    grfrac = ss(i).grfrac;
    uu = sqrt(u.^2 + v.^2);
    uu_grad = uu - sqrt(ss(i-1).u.^2 + ss(i-1).v.^2);
    uu_grad = uu_grad ./ (ss(i).t - ss(i-1).t); %velocity gradient
    
    hh = ss(i).h;
    hh_grad = hh - ss(i-1).h;
    hh_grad = hh_grad ./ (ss(i).t - ss(i-1).t); %thickness gradient
    
    %remove non-mask entries
    h_mask = ss(i).h_mask;
    not_mask = (ss(i).h_mask == 0);
    u(not_mask) = nan;
    v(not_mask) = nan;
    uu(not_mask) = nan;
    uu_grad(not_mask) = nan;
    hh(not_mask) = nan;
    hh_grad(not_mask) = nan;
    mean_vel_grad(i) = nanmean(nanmean(uu_grad)); %mean of non nan entries
    mean_thick_grad(i) = nanmean(nanmean(hh_grad)); %mean of non nan entries
    
    %saturate the colorbar
    uu = saturate(uu, 2000*1.1, -2000);
    sv = 0.5;
    uu_grad = saturate(uu_grad, sv*1.1, -sv);
    hh = saturate(hh, 3150, 0);
    hh_grad = saturate(hh_grad, .525, 0);

    
    %First row: velocities
    figure(numplot); clf;
    subplot(2,2,1); title(['t = ' num2str(ss(i).t)])
    hold on; box on
    contourf(ss(i).x, ss(i).y, uu, 20, 'linestyle', 'none');
    ax1 = gca; colormap(ax1, 'parula')
    c = colorbar; c.Label.String = 'ice velocity';
    
    %Second panel: velocity difference between timesteps
    subplot(2,2,2);    title(['t = ' num2str(ss(i).t)])
    hold on; box on
    contourf(ss(i).x, ss(i).y, uu_grad, 20, 'linestyle', 'none');
    ax2 = gca; colormap(ax2, redblue)
    c = colorbar; c.Label.String = 'ice velocity gradient d(|u|)/dt';
    
    % Second row: ice thicness
    subplot(2,2,3);
    hold on; box on
    contourf(ss(i).x, ss(i).y, hh, 20, 'linestyle', 'none');
    ax3 = gca; colormap(ax3, 'parula')
    c = colorbar; c.Label.String = 'ice thickness';
    
    subplot(2,2,4);  
    hold on; box on
    contourf(ss(i).x, ss(i).y, hh_grad, 20, 'linestyle', 'none');
    ax4 = gca; colormap(ax4, parula)
    c = colorbar; c.Label.String = 'ice thickness gradient';
    
    fig = gcf; fig.Position(3:4) = [1200, 600];    
    if video_out; frame = getframe(gcf); writeVideo(vid,frame);
    else drawnow
    end
    %pause
end

if video_out; close(vid); end
numplot = numplot+1;

%plot the norm of velocity difference
figure(numplot); clf;
subplot(1,2,1); box on;
tt = [ss.t];
plot(tt(2:end), mean_vel_grad(2:end), 'ro-', 'linewidth', 2, 'markersize', 4, 'markerfacecolor', 'r')
xlabel('time (yrs)');
ylabel('mean velocity gradient')

subplot(1,2,2); box on;
plot(tt(2:end), mean_thick_grad(2:end), 'ro-', 'linewidth', 2, 'markersize', 4, 'markerfacecolor', 'r')
xlabel('time (yrs)');
ylabel('mean thickness gradient')

end %end flag
