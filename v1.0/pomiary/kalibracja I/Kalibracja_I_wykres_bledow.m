clear all; clc; close all;

% ==========================================================
% SEKCJA: KONFIGURACJA WYKRESU BŁĘDÓW
% ==========================================================
cfg.device_name = '';
cfg.plot_range_x = [-20 20];

cfg.color_abs = [0, 0.4470, 0.7410]; % Niebieski dla błędu bezwzględnego
cfg.color_rel = [0.8500, 0.3250, 0.0980]; % Pomarańczowy dla błędu względnego

cfg.marker_size = 8;
cfg.line_width = 1.2;
% ==========================================================

% 1. Wybór pliku
[fname, fpath] = uigetfile('*.txt', 'Wybierz plik z wynikami zbiorczymi .txt');
if isequal(fname,0), return; end
full_path = fullfile(fpath, fname);

% 2. Wczytywanie i konwersja danych
fid = fopen(full_path, 'r');
header = fgetl(fid);
raw_data = [];
while ~feof(fid)
    line = fgetl(fid);
    if ischar(line) && ~isempty(line)
        line = strrep(line, ',', '.');
        parts = strsplit(line, ';');
        if length(parts) >= 3
            raw_data = [raw_data; str2double(parts{2}), str2double(parts{3})];
        end
    end
end
fclose(fid);

x_ref = raw_data(:, 1);
y_meas = raw_data(:, 2);

% 3. Obliczanie błędów
err_abs = y_meas - x_ref; % Błąd bezwzględny [V]

% Błąd względny [%] - omijamy zero, żeby nie dzielić przez zero
idx_nonzero = find(x_ref != 0);
x_ref_rel = x_ref(idx_nonzero);
err_rel = (err_abs(idx_nonzero) ./ abs(x_ref_rel)) * 100;

% 4. Obliczanie symetrycznych zakresów osi Y
% Wyznaczamy max wartość bezwzględną i dodajemy 10% marginesu
max_abs_val = max(abs(err_abs)) * 1.1;
if max_abs_val == 0, max_abs_val = 1; end % Zabezpieczenie przed zerem

max_rel_val = max(abs(err_rel)) * 1.1;
if max_rel_val == 0, max_rel_val = 1; end % Zabezpieczenie przed zerem

% 5. Tworzenie wykresu z dwiema osiami Y
fig = figure('Name', 'Analiza Błędów Kalibracji', 'Color', [1 1 1], 'Position', [100, 100, 1000, 600]);

[ax, h1, h2] = plotyy(x_ref, err_abs, x_ref_rel, err_rel);

% --- Stylizacja i SYMETRIA osi lewej (Błąd Bezwzględny) ---
set(h1, 'Marker', 's', 'LineStyle', '-', 'Color', cfg.color_abs, 'MarkerFaceColor', cfg.color_abs, 'LineWidth', cfg.line_width);
ylabel(ax(1), 'Błąd bezwzględny \DeltaV, V', 'Color', cfg.color_abs);
set(ax(1), 'YColor', cfg.color_abs, 'YGrid', 'on', 'XGrid', 'on');
% Ustawienie symetrycznych granic [-max, +max]
ylim(ax(1), [-max_abs_val, max_abs_val]);

% --- Stylizacja i SYMETRIA osi prawej (Błąd Względny) ---
set(h2, 'Marker', 'o', 'LineStyle', '--', 'Color', cfg.color_rel, 'MarkerFaceColor', 'none', 'LineWidth', cfg.line_width);
ylabel(ax(2), 'Błąd względny \delta, %', 'Color', cfg.color_rel);
set(ax(2), 'YColor', cfg.color_rel);
% Ustawienie symetrycznych granic [-max, +max]
ylim(ax(2), [-max_rel_val, max_rel_val]);

% --- Wspólne ustawienia ---
xlabel('Napięcie wzorcowe I_{ref}, A');
title(['Analiza błędów kalibracji ', cfg.device_name]);
xlim(ax(1), cfg.plot_range_x);
xlim(ax(2), cfg.plot_range_x);

% Dodanie linii ZERO (poziom idealny) - będzie teraz dokładnie na środku
hold(ax(1), 'on');
line(cfg.plot_range_x, [0 0], 'Parent', ax(1), 'Color', [0.3 0.3 0.3], 'LineStyle', '-', 'LineWidth', 1);

% Legenda
legend([h1, h2], {'Błąd bezwzględny, I', 'Błąd względny, %'}, 'Location', 'southoutside', 'Orientation', 'horizontal');

% Wyświetlanie statystyk w terminalu
fprintf('\nStatystyki błędów:\n');
fprintf('Max błąd bezwzględny: %.6f V\n', max(abs(err_abs)));
fprintf('Zakres osi lewej: +/- %.6f V\n', max_abs_val);
fprintf('Max błąd względny: %.4f %%\n', max(abs(err_rel)));
fprintf('Zakres osi prawej: +/- %.4f %%\n', max_rel_val);

% Opcjonalny zapis (odkomentuj jeśli potrzebujesz)
% out_name = 'wykres_bledow_symetryczny.png';
% print(fig, out_name, '-dpng', '-r300');
