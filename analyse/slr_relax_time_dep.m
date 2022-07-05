% 16/05/22
%
% Make a plot of the SLR contribution over the first 20 years of the simulation.
%

%
% Preliminaries
%
clear
result_dir = "/data/icesheet_output/aleey/wavi/";

%
% Run spec
%
run_nos    = ["101","102","103","104","151","152","153","154","155","156","157","158","159"];
relax_time = [100,200,300,400,70,170,270,370,470,570,670,770,870];
bed_type   = [repmat("bedmachine", [1,4]), repmat("bedmap", [1,9])];
sz         = size(run_nos);

dx = 1000;
dy = 1000;

%
% Generate data
%
ss = struct;
figure(1); clf; hold on
for ir = 1:sz(2);
	%load the result file and quantities
	fname = strcat(result_dir, "INVREL_", run_nos(ir), "/run/outfile.nc");
	ss(ir).t = ncread(fname, "TIME");
	ss(ir).h = ncread(fname, "h");
	ss(ir).grfrac = ncread(fname, 'grounded_frac');
	ss(ir).b = ncread(fname, 'b');

	%compute slr
	haf = ss(ir).h - (1028/918)*ss(ir).b;
	vaf = zeros(1,length(ss(ir).t));
	for it = 1:length(ss(ir).t);
		hafnow = squeeze(haf(:,:,it));
		idx = hafnow > 0;
		vaf(it) = sum(sum(hafnow(idx)))*dx*dy;
	end %end loop over time
	ss(ir).vaf = vaf;
	slr = -(vaf - vaf(1))/1e9/361.8;
	ss(ir).slr = slr;

	%plot the result
	if bed_type(ir) == "bedmap"; lt = "--"; else lt = "-"; end
	plot(ss(ir).t, ss(ir).slr, 'linestyle', lt)
	legendinfo{ir} = strcat(bed_type(ir), ", " , num2str(relax_time(ir)), " yrs")     ;



end %end loop over runs
	
% tidy plot
xlabel('time (yrs)');
ylabel('slr (mm)')
box on
legend(legendinfo, 'location', 'northwest')
