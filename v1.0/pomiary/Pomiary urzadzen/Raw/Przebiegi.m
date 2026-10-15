pkg load io
clear all; clc; close all;

% ==========================================================
% SEKCJA: KONFIGURACJA WYKRESU I PRÓBKOWANIA
% ==========================================================
cfg.fs = 39000;
cfg.device_name = 'PC';

% --- NOWE: KONFIGURACJA OKNA ---
% [odległość_od_lewej, odległość_od_dołu, szerokość, wysokość]
cfg.window_pos_size = [300, 0, 1250, 1100];

% ZAGĘSZCZENIE SIATKI
cfg.x_intervals = 10;
cfg.v_intervals = 8;
cfg.i_intervals = 8;

cfg.color_voltage = [0, 0.4470, 0.7410];
cfg.color_current = [0.8500, 0.3250, 0.0980];
cfg.line_width = 1.2;

% ZAKRESY OSI
cfg.x_range = [];
cfg.v_range = [-400 400];
cfg.i_range = [-3 3];

cfg.title_base = 'Przebieg napięcia i prądu dla: ';
cfg.grid = 'on';
cfg.save_to_png = false;
% ==========================================================

% 1. Wybór pliku
[fname, fpath] = uigetfile('*.csv', 'Wybierz plik z przebiegami surowymi .csv');
if isequal(fname,0)
    disp('Anulowano wybór pliku.');
    return;
end
full_path = fullfile(fpath, fname);

% 2. Wczytanie danych
fprintf('Wczytywanie danych... \n');
data = dlmread(full_path, ',', 1, 0);
voltage = data(:, 2);
current = data(:, 3);

% 3. Generowanie osi czasu
n = length(voltage);
time = (0:n-1)' / cfg.fs;

% 4. Tworzenie wykresu
full_title = [cfg.title_base, cfg.device_name];

% --- ZMODYFIKOWANA LINIA (Dodano 'Position') ---
fig = figure('Name', full_title, ...
             'Color', [1 1 1], ...
             'Position', cfg.window_pos_size);

[ax, h1, h2] = plotyy(time, voltage, time, current);

% --- USTAWIANIE SIATKI I PODZIAŁÓW (TICKÓW) ---

% Oś X (wspólna dla obu)
if !isempty(cfg.x_range)
    x_ticks = linspace(cfg.x_range(1), cfg.x_range(2), cfg.x_intervals + 1);
    set(ax(1), 'XTick', x_ticks);
    set(ax(2), 'XTick', x_ticks);
    xlim(ax(1), cfg.x_range);
    xlim(ax(2), cfg.x_range);
end

% Oś Y Lewa (Napięcie)
if !isempty(cfg.v_range)
    v_ticks = linspace(cfg.v_range(1), cfg.v_range(2), cfg.v_intervals + 1);
    set(ax(1), 'YTick', v_ticks);
    ylim(ax(1), cfg.v_range);
end

% Oś Y Prawa (Prąd)
if !isempty(cfg.i_range)
    i_ticks = linspace(cfg.i_range(1), cfg.i_range(2), cfg.i_intervals + 1);
    set(ax(2), 'YTick', i_ticks);
    ylim(ax(2), cfg.i_range);
end

% --- STYLIZACJA ---
set(h1, 'Color', cfg.color_voltage, 'LineWidth', cfg.line_width);
set(ax(1), 'YColor', cfg.color_voltage, 'XGrid', cfg.grid, 'YGrid', cfg.grid);

set(h2, 'Color', cfg.color_current, 'LineWidth', cfg.line_width);
set(ax(2), 'YColor', cfg.color_current);

ylabel(ax(1), 'Napięcie, V');
ylabel(ax(2), 'Natężenie prądu, A');
xlabel('Czas, s');
title(full_title);

legend([h1, h2], {'Napięcie, V', 'Prąd, A'}, 'Location', 'northeast');

% 5. Zapis do pliku PNG
if cfg.save_to_png
    out_name = ['wykres_', cfg.device_name, '.png'];
    fprintf('Zapisywanie wykresu do pliku: %s...\n', out_name);
    print(fig, out_name, '-dpng', '-r300');
end

fprintf('Gotowe! Wyświetlono %d próbek przy Fs = %d Hz.\n', n, cfg.fs);
