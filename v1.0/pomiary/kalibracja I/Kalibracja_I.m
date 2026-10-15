pkg load io
clear all; clc; close all;

% ==========================================================
% SEKCJA: KONFIGURACJA TESTU KALIBRACJI
% ==========================================================
cfg.fs = 39000*2;               % Częstotliwość próbkowania [Hz]
cfg.device_name = '';

% WARTOŚĆ WZORCOWA (Referencyjna)
cfg.ref_value = -20.0000;     % Wpisz zadaną wartość (np. 50V lub 2A)

% WYBÓR TRYBU: 'U' (napięcie) lub 'I' (prąd)
cfg.plot_mode = 'I';

% ZAKRES OSI X (Statystyki będą liczone tylko dla tego przedziału!)
##cfg.x_range = [0.1 1.1];     % Zakres czasu [s] - ustaw [] dla całości
cfg.x_range = [38 39];     % Zakres czasu [s] - ustaw [] dla całości

% ZAKRES OSI Y
range_delta = 0.02;
cfg.y_range = [(cfg.ref_value - range_delta) (cfg.ref_value + range_delta)];

% ŚREDNIA KROCZĄCA
cfg.mov_avg_win = 100;
cfg.show_raw_data = true;

% KOLORY I STYL
cfg.color_raw = [0.8, 0.8, 0.8];   % Jasnoszary
cfg.color_avg = [0.0, 0.4, 0.0];   % Ciemnozielony
cfg.color_ref = [1.0, 0.0, 0.0];   % Czerwony (linia wzorca)

cfg.save_to_png = false;
% ==========================================================

% 1. Wybór pliku
[fname, fpath] = uigetfile('*.*', 'Wybierz plik z danymi kalibracji .txt');
if isequal(fname,0), disp('Anulowano.'); return; end
full_path = fullfile(fpath, fname);

% 2. Wczytanie danych
data = dlmread(full_path, ',', 1, 0);
voltage_raw = data(:, 2);
current_raw = data(:, 3);

% 3. Generowanie osi czasu
n = length(voltage_raw);
time = (0:n-1)' / cfg.fs;

% 4. Wycinanie danych do statystyk (tylko zakres x_range)
if isempty(cfg.x_range)
    idx = 1:n;
else
    idx = find(time >= cfg.x_range(1) & time <= cfg.x_range(2));
end

if isempty(idx)
    error('BŁĄD: Wybrany zakres x_range nie zawiera żadnych próbek!');
end

v_sel = voltage_raw(idx);
i_sel = current_raw(idx);

% 5. Obliczenia statystyczne dla wybranych danych
if strcmpi(cfg.plot_mode, 'U')
    y_data_all = voltage_raw;
    y_sel = v_sel;
    unit = 'V';
    label_long = 'Napięcie';
else
    y_data_all = current_raw;
    y_sel = i_sel;
    unit = 'A';
    label_long = 'Natężenie prądu';
end

res.avg = mean(y_sel);
res.max_dev_plus = max(y_sel) - res.avg;
res.max_dev_minus = res.avg - min(y_sel);
res.error = res.avg - cfg.ref_value; % BŁĄD BEZWZGLĘDNY

% 6. Średnia krocząca (dla całego przebiegu do wykresu)
b = (1/cfg.mov_avg_win) * ones(1, cfg.mov_avg_win);
y_smooth = filter(b, 1, y_data_all);
shift = floor(cfg.mov_avg_win / 2);
y_smooth = [y_smooth(shift+1:end); y_smooth(end)*ones(shift,1)];

% 7. Wyświetlenie wyników w terminalu (Format Excel)
to_pl = @(val) strrep(sprintf('%.6f', val), '.', ',');
fprintf('\n--- ANALIZA KALIBRACJI (%s) ---\n', cfg.device_name);
fprintf('Statystyki liczone dla czasu: %s s\n', mat2str(cfg.x_range));
fprintf('Parametr;Wartość Wzorcowa;Średnia Wyliczona;Błąd (Śr-Wz);Odchylenie (+);Odchylenie (-)\n');

fprintf('%s [%s];%s;%s;%s;%s;%s\n', ...
    label_long, unit, ...
    to_pl(cfg.ref_value), ...
    to_pl(res.avg), ...
    to_pl(res.error), ...
    to_pl(res.max_dev_plus), ...
    to_pl(res.max_dev_minus));

% 8. Tworzenie wykresu
plot_title = sprintf('Kalibracja %s: %s (Ref: %.3f %s)', label_long, cfg.device_name, cfg.ref_value, unit);
fig = figure('Name', plot_title, 'Color', [1 1 1]);
hold on;

% Surowe dane
if cfg.show_raw_data
    h1 = plot(time, y_data_all, 'Color', cfg.color_raw, 'LineWidth', 0.5);
end

% Średnia krocząca
h2 = plot(time, y_smooth, 'Color', cfg.color_avg, 'LineWidth', 2);

% Linia wzorcowa (Reference)
h3 = line([time(1) time(end)], [cfg.ref_value cfg.ref_value], ...
    'Color', cfg.color_ref, 'LineStyle', '--', 'LineWidth', 1.5);

% Ustawienia osi i etykiety
xlabel('Czas, s');
ylabel([label_long, ', ', unit]);
title(plot_title);
grid on;

if !isempty(cfg.x_range), xlim(cfg.x_range); end
if !isempty(cfg.y_range), ylim(cfg.y_range); end

% Legenda
leg_entries = {['Średnia krocząca (n=', num2str(cfg.mov_avg_win), ')'], 'Wartość wzorcowa'};
leg_hdls = [h2, h3];
if cfg.show_raw_data
    leg_entries = [{'Dane surowe'}, leg_entries];
    leg_hdls = [h1, leg_hdls];
end
legend(leg_hdls, leg_entries, 'Location', 'northeast');

hold off;

% 9. Zapis PNG
if cfg.save_to_png
    out_name = ['kalibracja_final_', cfg.plot_mode, '_', cfg.device_name, '.png'];
    print(fig, out_name, '-dpng', '-r300');
end
