clear all; clc; close all;

% ==========================================================
% SEKCJA: KONFIGURACJA WYKRESU
% ==========================================================
cfg.show_best_fit = true;    % Czy pokazać linię dopasowaną (regresję)?
cfg.show_ideal_line = true;  % Czy pokazać linię idealną (Wzorzec = Odczyt)?

% ZAKRESY OSI (zgodnie z prośbą -300 do 300)
cfg.plot_range = [-20 20];

cfg.point_color = [0.8, 0, 0];    % Czerwone punkty pomiarowe
cfg.ideal_color = [0, 0, 0.8];    % Niebieska linia idealna
cfg.fit_color = [0, 0.6, 0];      % Zielona linia dopasowana

cfg.line_width = 1.5;
cfg.marker_size = 7;
cfg.title_text = 'Charakterystyka przetwarzania prądu (-20A do 20A)';
% ==========================================================

% 1. Wybór pliku z wynikami
[fname, fpath] = uigetfile('*.txt', 'Wybierz plik z wynikami zbiorczymi .txt');
if isequal(fname,0), return; end
full_path = fullfile(fpath, fname);

% 2. Wczytywanie i konwersja danych
fprintf('Wczytywanie i konwersja danych... \n');
fid = fopen(full_path, 'r');
header = fgetl(fid); % Pomiń nagłówek

raw_data = [];
while ~feof(fid)
    line = fgetl(fid);
    if ischar(line) && ~isempty(line)
        line = strrep(line, ',', '.'); % Przecinek -> Kropka
        parts = strsplit(line, ';');   % Separator średnik
        if length(parts) >= 3
            val_ref = str2double(parts{2});
            val_meas = str2double(parts{3});
            raw_data = [raw_data; val_ref, val_meas];
        end
    end
end
fclose(fid);

x_ref = raw_data(:, 1);
y_meas = raw_data(:, 2);

% 3. Obliczenia regresji liniowej (y = ax + b)
p = polyfit(x_ref, y_meas, 1);

fprintf('\n--- ANALIZA REGRESJI ---\n');
fprintf('Współczynnik nachylenia (a): %.10f\n', p(1));
fprintf('Przesunięcie (b): %.10f\n', p(2));
fprintf('Równanie: y = %.6f * x + (%.6f)\n', p(1), p(2));

% 4. Tworzenie wykresu
fig = figure('Name', 'Analiza Kalibracji', 'Color', [1 1 1]);
hold on;

% Punkty do rysowania linii (cały zakres -300 do 300)
x_line = cfg.plot_range;

h_plots = [];
h_legends = {};

% Rysowanie linii idealnej (y = x)
if cfg.show_ideal_line
    h_ideal = plot(x_line, x_line, '--', 'Color', cfg.ideal_color, 'LineWidth', 1);
    h_plots = [h_plots, h_ideal];
    h_legends{end+1} = 'Linia idealna (y=x)';
end

% Rysowanie linii dopasowanej (Regresja)
if cfg.show_best_fit
    y_fit_line = polyval(p, x_line);
    h_fit = plot(x_line, y_fit_line, 'Color', cfg.fit_color, 'LineWidth', cfg.line_width);
    h_plots = [h_plots, h_fit];
    h_legends{end+1} = sprintf('Regresja: y=%.4fx + %.4f', p(1), p(2));
end

% Rysowanie punktów pomiarowych
h_points = plot(x_ref, y_meas, 'o', 'MarkerEdgeColor', cfg.point_color, ...
                'MarkerFaceColor', [1, 0.8, 0.8], 'MarkerSize', cfg.marker_size);
h_plots = [h_plots, h_points];
h_legends{end+1} = 'Wyniki pomiarów';

% Ustawienia osi
grid on;
set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on'); % Dodatkowa gęstsza siatka
xlabel('Wartość wzorcowa, A');
ylabel('Wartość zmierzona, A');
title(cfg.title_text);

% WYMUSZENIE ZAKRESU -300 do 300
xlim(cfg.plot_range);
ylim(cfg.plot_range);

% Legenda i tekst
legend(h_plots, h_legends, 'Location', 'northwest');
text_str = sprintf('Równanie dopasowania:\ny = %.6fx + %.6f', p(1), p(2));
text(cfg.plot_range(1)+20, cfg.plot_range(2)-80, text_str, 'FontSize', 10, ...
     'FontWeight', 'bold', 'Color', cfg.fit_color, 'BackgroundColor', [1 1 1]);

hold off;

% 5. Zapis do PNG
##out_name = 'wykres_kalibracji_300V.png';
##print(fig, out_name, '-dpng', '-r300');
##fprintf('\nWykres zapisany w zakresie %s jako: %s\n', mat2str(cfg.plot_range), out_name);
