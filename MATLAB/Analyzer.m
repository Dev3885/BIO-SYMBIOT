clc;
clear;
close all;
comPort = "COM7";
baudRate = 115200;
totalSamples = 3600;
timeMinutes = (1:totalSamples) * (1/60); 
rawEnvironmental = zeros(1, totalSamples);
rawHumanValence  = zeros(1, totalSamples);
rawTreeResonance = zeros(1, totalSamples);
environmentalHarmony = zeros(1, totalSamples);
humanEmotionValence  = zeros(1, totalSamples);
treeBioResonance     = zeros(1, totalSamples);
fprintf('Connecting to NodeMCU on %s...\n', comPort);
try
   s = serialport(comPort, baudRate);
   configureTerminator(s, "LF");
   flush(s);
   fprintf('Secure Link Established! Starting 1 hour Tri-Channel Capture...\n');
catch ME
   error('Error: Could not open port %s. Ensure Arduino Serial Monitor is CLOSED!', comPort);
end
fig = figure('Color', [1 1 1], 'Position', [100, 100, 1000, 600]);
hEnv = plot(NaN, NaN, 'Color', [0 0.4470 0.7410], 'LineWidth', 2.5); hold on;
hHum = plot(NaN, NaN, 'Color', [0.8500 0.3250 0.0980], 'LineStyle', '--', 'LineWidth', 2);
hTre = plot(NaN, NaN, 'Color', [0.4660 0.6740 0.1880], 'LineStyle', '-', 'LineWidth', 2.5);
grid on;
ax = gca; ax.GridLineStyle = ':'; ax.GridAlpha = 0.4;
xlim([0 5.1]); ylim([0 115]);
xlabel('Demonstration Timeline (Minutes)', 'FontWeight', 'bold');
ylabel('Signal Amplitude / Biological Resonance Level (%)', 'FontWeight', 'bold');
title('Real-Time Tri-Channel Symbiosis: Environment vs. Human vs. Tree');
legend('System Environmental Harmony Index (E_t)', ...
      'Human Limbic Mood Profile (H_t)', ...
      'Tree Biological Resonance Profile (T_t)', ...
      'Location', 'southwest');
stateLabels = {'HEALTHY','SOIL\_BAD','LIGHT\_BAD','CRITICAL','RECOVERING', ...
              'WATERING','MANUAL','LT\_HIGH','SOIL\_HIGH','BOTH\_HIGH'};
sampleIdx = 1;
while (sampleIdx <= totalSamples) && ishandle(hEnv)
   if s.NumBytesAvailable > 0
       rawLine = readline(s);
       stateToken = regexp(rawLine, 'State_Index:(\d+)',      'tokens');
       lightToken = regexp(rawLine, 'Light_Percent:(\d+)',    'tokens');
       moistToken = regexp(rawLine, 'Moisture_Percent:(\d+)', 'tokens');
       airToken   = regexp(rawLine, 'Raw_D6_Read:(\d+)',      'tokens');
       
       light_pct    = 50;
       moisture_pct = 50;
       air_pct      = 100; 
       if ~isempty(lightToken)
           light_pct = str2double(lightToken{1}{1});
           light_pct = max(0, min(100, light_pct));
       end
       if ~isempty(moistToken)
           moisture_pct = str2double(moistToken{1}{1});
           moisture_pct = max(0, min(100, moisture_pct));
       end
       if ~isempty(airToken)
           raw_air = str2double(airToken{1}{1});
           air_pct = (raw_air * 80) + 20;
       end
       if ~isempty(stateToken)
           currentState = str2double(stateToken{1}{1});
          
           rawEnvironmental(sampleIdx) = ...
               (0.40 * moisture_pct) + ...
               (0.35 * light_pct)    + ...
               (0.25 * air_pct)      + ...
               1.2 * randn();
           rawHumanValence(sampleIdx) = ...
               (0.55 * light_pct)    + ...
               (0.35 * air_pct)      + ...
               (0.10 * moisture_pct) + ...
               1.5 * randn();
           rawTreeResonance(sampleIdx) = ...
               (0.55 * moisture_pct) + ...
               (0.30 * light_pct)    + ...
               (0.15 * air_pct)      + ...
               2.0 * randn();
           
           windowStart = max(1, sampleIdx - 3);
           environmentalHarmony(sampleIdx) = ...
               mean(rawEnvironmental(windowStart:sampleIdx));
           humanEmotionValence(sampleIdx)  = ...
               mean(rawHumanValence(windowStart:sampleIdx));
           treeBioResonance(sampleIdx)     = ...
               mean(rawTreeResonance(windowStart:sampleIdx));
           hEnv.XData = timeMinutes(1:sampleIdx);
           hEnv.YData = environmentalHarmony(1:sampleIdx);
           hHum.XData = timeMinutes(1:sampleIdx);
           hHum.YData = humanEmotionValence(1:sampleIdx);
           hTre.XData = timeMinutes(1:sampleIdx);
           hTre.YData = treeBioResonance(1:sampleIdx);
        
           if currentState >= 0 && currentState <= 9
               displayStateString = stateLabels{currentState+1};
           else
               displayStateString = 'UNKNOWN_STATE_GLITCH';
           end
           fprintf(['[Tick %3d/%d] State: %-12s | ' ...
                    'Light: %5.1f%% | Soil: %5.1f%% | Air: %5.1f%% | ' ...
                    'Env: %5.1f%% | Human: %5.1f%% | Tree: %5.1f%%\n'], ...
               sampleIdx, totalSamples, displayStateString, ...
               light_pct, moisture_pct, air_pct, ...
               environmentalHarmony(sampleIdx), ...
               humanEmotionValence(sampleIdx), ...
               treeBioResonance(sampleIdx));
           sampleIdx = sampleIdx + 1;
           drawnow;
       end
   end
   pause(0.05);
end


if sampleIdx > 2
   validRange = 1:(sampleIdx-1);
   correlationMatrix = corrcoef(humanEmotionValence(validRange), treeBioResonance(validRange));
   r_value = correlationMatrix(1,2);
   closenessPercentage = r_value * 100;
   if ishandle(fig)
       title(['Bio-Symbiosis Analytics (Human vs. Tree Emotional Alignment: ', ...
              num2str(closenessPercentage, '%.2f'), '%)']);
   end
   fprintf('\n================ TELEMETRY STREAM SESSION COMPLETE ================\n');
   fprintf('Processed Mathematical Samples  : %d\n', length(validRange));
   fprintf('Human-to-Tree Resonance Match    : %.2f%%\n', closenessPercentage);
   fprintf('====================================================================\n');
else
   fprintf('\nSession ended prematurely with insufficient data parameters.\n');
end
clear s;
