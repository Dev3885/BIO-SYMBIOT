Et = rawEnvironmental;
Ht = rawHumanValence;
Tt = rawTreeResonance;
Time = timeMinutes;


figure('Name', 'Bio-Symbiosis Analytics');
plot(Time, Et, 'LineWidth', 2); hold on;
plot(Time, Ht, '--', 'LineWidth', 2);
plot(Time, Tt, 'LineWidth', 2);
title('Bio-Symbiosis Analytics (Human vs. Tree Emotional Alignment)');
xlabel('Demonstration Timeline (Minutes)');
ylabel('Signal Amplitude / Biological Resonance Level (%)');
legend('System E_t', 'Human H_t', 'Tree T_t');
grid on;


Fs = 1; 
L = length(Et);
Y = fft(Et);
P2 = abs(Y/L);
P1 = P2(1:floor(L/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;


figure('Name', 'Frequency Domain Analysis');
plot(f, P1, 'r', 'LineWidth', 1.5);
title('Single-Sided Amplitude Spectrum (Noise Suppression Validation)');
xlabel('Frequency (Hz)'); ylabel('|P1(f)|');
grid on;


mdl = fitlm(Tt, Ht);
figure('Name', 'Regression Analysis');
scatter(Tt, Ht, 'filled'); hold on;
coeffs = polyfit(Tt, Ht, 1);
yFit = polyval(coeffs, Tt);
plot(Tt, yFit, 'r-', 'LineWidth', 2);
title('Predictive Resonance Model: Human vs Tree');
xlabel('Tree Biological Resonance (T_t)');
ylabel('Human Limbic Profile (H_t)');
grid on;


fprintf('\n====== SHANNON ENTROPY STABILITY ANALYSIS ======\n');


stateLog = zeros(1, length(Et));
for i = 1:length(Et)
    val = Et(i);
    if     val >= 88,          stateLog(i) = 0; % STATE_HEALTHY
    elseif val >= 78,          stateLog(i) = 4; % STATE_RECOVERING
    elseif val >= 72,          stateLog(i) = 5; % STATE_WATERING
    elseif val >= 65,          stateLog(i) = 6; % STATE_MANUAL_MODE
    elseif val >= 58,          stateLog(i) = 1; % STATE_SOIL_BAD
    elseif val >= 50,          stateLog(i) = 2; % STATE_LIGHT_BAD
    elseif val >= 38,          stateLog(i) = 8; % STATE_SOIL_TOO_HIGH
    elseif val >= 28,          stateLog(i) = 9; % STATE_BOTH_TOO_HIGH
    elseif val >= 18,          stateLog(i) = 3; % STATE_CRITICAL
    else,                      stateLog(i) = 7; % STATE_LIGHT_TOO_HIGH
    end
end


numStates = 10;
probabilities = zeros(1, numStates);
for s = 0:(numStates - 1)
    probabilities(s+1) = sum(stateLog == s) / length(stateLog);
end


activeProbabilities = probabilities(probabilities > 0);
H_entropy = -sum(activeProbabilities .* log2(activeProbabilities));
H_max = log2(numStates);
stability_score = (1 - (H_entropy / H_max)) * 100;


numActiveStates = length(activeProbabilities);


fprintf('Total States Possible       : %d\n', numStates);
fprintf('Active States Observed      : %d\n', numActiveStates);
fprintf('Shannon Entropy (H)         : %.4f bits\n', H_entropy);
fprintf('Maximum Entropy (H_max)     : %.4f bits\n', H_max);
fprintf('System Stability Score      : %.2f%%\n', stability_score);
fprintf('================================================\n');


figure('Name', 'Shannon Entropy - State Distribution');
stateNames = {'HEALTHY','SOIL\_BAD','LIGHT\_BAD','CRITICAL',...
              'RECOVERING','WATERING','MANUAL','LT\_HIGH',...
              'SOIL\_HIGH','BOTH\_HIGH'};
bar(0:9, probabilities * 100, 'FaceColor', [0.2 0.6 0.4]);
xlabel('FSM System State');
ylabel('Probability of Occurrence (%)');
title(sprintf(['State Probability Distribution\n' ...
    'Shannon Entropy = %.4f bits | Stability Score = %.2f%%'], ...
    H_entropy, stability_score));
xticks(0:9);
xticklabels(stateNames);
xtickangle(30);
grid on;


figure('Name', 'System Stability Score');
theta = linspace(pi, 0, 100);
x_arc = cos(theta);
y_arc = sin(theta);
fill([0 x_arc 0], [0 y_arc 0], [0.9 0.9 0.9]); hold on;


theta_red    = linspace(pi,       pi*0.67, 50);
theta_yellow = linspace(pi*0.67,  pi*0.33, 50);
theta_green  = linspace(pi*0.33,  0,       50);
fill([0 cos(theta_red)    0], [0 sin(theta_red)    0], [0.9 0.3 0.3]);
fill([0 cos(theta_yellow) 0], [0 sin(theta_yellow) 0], [0.9 0.8 0.2]);
fill([0 cos(theta_green)  0], [0 sin(theta_green)  0], [0.3 0.8 0.4]);


needle_angle = pi - (stability_score/100) * pi;
quiver(0, 0, 0.7*cos(needle_angle), 0.7*sin(needle_angle), ...
    0, 'k', 'LineWidth', 3, 'MaxHeadSize', 0.5);
text(0, -0.15, sprintf('%.2f%%', stability_score), ...
    'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
title('System Homeostatic Stability Score (Shannon Entropy Method)');
axis equal; axis off;


text(-0.95, 0.15, 'HIGH\nENTROPY', 'Color', 'white', ...
    'FontWeight', 'bold', 'FontSize', 8, 'HorizontalAlignment', 'center');
text(0.95, 0.15, 'LOW\nENTROPY', 'Color', 'white', ...
    'FontWeight', 'bold', 'FontSize', 8, 'HorizontalAlignment', 'center');
text(0, 0.85, 'STABLE', 'Color', [0.2 0.6 0.2], ...
    'FontWeight', 'bold', 'FontSize', 9, 'HorizontalAlignment', 'center');


publish('BioSymbiosis_Analyzer.m', 'pdf');
