% Constants and setup
lambda0 = 10.71;                % Wavelength in mm
k0 = 2 * pi / lambda0;          % Phase constant [rad/mm]                     % Excitation source distance in mm
uc_p = lambda0/4;
uc_q = uc_p/cos(pi/6);
boundaryRadius = 25.4;
cushion = uc_q/2;

% Dimensions of the array
N = 19;                         % Number of columns
M = 21;                         % Number of rows

% Excitation source coordinates
x0 = -40;                         % x-coordinate of the excitation source
y0 = 0;                         % y-coordinate of the excitation source
F = 150;   

% Beam direction angles
theta_b = 45;                    % Beam direction angle in degrees
phi_b = 90;                      % Beam direction angle in degrees

theta_b = deg2rad(theta_b);     % Convert to radians
phi_b = deg2rad(phi_b);         % Convert to radians

% Load lookup table data
dataPath = 'C:\Users\davidhardy\Documents\Reflectarray Builder\lookUpTable.csv';
lookupData = readmatrix(dataPath);  % Assumes the data is organized as [diagonal, width, phase]

% Initialize figure
figure;
colormap('hsv')

% Define hexagon parameters
radius = (2 * lambda0 / 4 / sqrt(3)) / 2;

for nn = 1:N
    fprintf('Column %d ----------\n', nn);
    for oo = 1:M
        centerX = (nn - (N-1) / 2) * uc_p + mod(oo, 2) / 2 * uc_p;
        centerY_p = (oo - (M-1) / 2) * (3/4);
        centerY = centerY_p*uc_q;
        
        disp(centerY_p)
        
        % Define vertices of the rotated hexagon (90 degrees)
        x_vertices = centerX + radius * cosd(30:60:390);
        y_vertices = centerY + radius * sind(30:60:390);
        
        % Calculate ideal phase
        d = sqrt((x0 - centerX) ^ 2 + (y0 - centerY) ^ 2 + F ^ 2);
        idealPhase = rad2deg(k0 * (d - (centerX * cos(phi_b) + centerY * sin(phi_b)) * sin(theta_b)));
        idealPhase = mod(idealPhase, 360);

        % Find closest match in lookup table
        [~, matchIndex] = min(abs(lookupData(:, 3) - idealPhase));
        color_index = idealPhase;

        ringDiagonalLength = lookupData(matchIndex, 1);
        ringWidth = lookupData(matchIndex, 2);
        ringInnerDiagonalLength = (2 / sqrt(3)) * (sqrt(3) / 2 * ringDiagonalLength - 2 * ringWidth);

        if (centerX^2 + (centerY_p * uc_q)^2) < (boundaryRadius - cushion)^2
            % Plot the hexagon with color based on phase
            patch(x_vertices, y_vertices, color_index, 'EdgeColor', 'k');
            hold on;
        end
    end
end

axis equal;
title('Hexagonal Array with Phase Distribution');
xlabel('X-position [mm]');
ylabel('Y-position [mm]');
colorbar;

