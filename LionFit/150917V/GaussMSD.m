% GaussCalcs2

space_units = '?m';
time_units = 's';

%Which experiment?
L=3;

N_particles = size(d{L}.x,2);
N_time_steps = size(d{L}.x{1},1);

MA=msdanalyzer(2,space_units,time_units);

tracks=LionToMSD(d{L},N_particles,N_time_steps);

%add tracks to db
MA=MA.addAll(tracks);

%computeMSD
MA=MA.computeMSD;

dT=0.05;
t = (0 : N_time_steps-1)' * dT;
[T1, T2] = meshgrid(t, t);
all_delays = unique( abs(T1 - T2) );

fprintf('Found %d different delays.\n', numel(all_delays));
fprintf('For %d time-points, found %d different delays.\n', N_time_steps, size(MA.msd{1}, 1 ) );

%% plots
ax = gca; % current axes
ax.FontSize = 16;
set(ax,'LineWidth',2);
%   MA.plotMSD
% MA.plotTracks
% MA.labelPlotTracks;
    MA.plotMeanMSD(gca, true)


%% diffusion coefficient
[fo, gof] = MA.fitMeanMSD;

