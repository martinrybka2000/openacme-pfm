pkg load io
clear all; clc; close all;

% ==========================================================
% SEKCJA: KONFIGURACJA GLOBALNA
% ==========================================================
cfg.device_name = 'Bieżnia 2'; % Nazwa folderu i urządzenia

% KONFIGURACJA OKNA I LINII
cfg.window_size = [300, 100, 1250, 1100];
cfg.line_width = 1.2;       % Grubość linii danych
cfg.axes_line_width = 0.5;  % Grubość linii osi

% ZAKRESY CZASU ([] = cały plik)
cfg.plot_x_range = [130 165];      % Zakres czasu na wykresach
cfg.stat_x_range = [130 165];       % Zakres czasu do wyliczeń średnich

% PARAMETRY WYKRESÓW
cfg.freq_smooth_win = 10;   % Okno średniej kroczącej dla częstotliwości
cfg.freq_y_range = [49.5, 50.5];
cfg.thd_y_limit = 200;       % Limit osi Y dla THD w %

% KOLORY (Zgodne z przebiegami sinus)
cfg.color_v = [0, 0.4470, 0.7410];      % Niebieski
cfg.color_v1 = [0.4, 0.7, 1.0];         % Jasnoniebieski
cfg.color_i = [0.8500, 0.3250, 0.0980]; % Pomarańczowy
cfg.color_i1 = [1.0, 0.6, 0.4];         % Jasnopomarańczowy

cfg.save_files = 1; % Czy tworzyć folder i zapisywać pliki
% ==========================================================

% 1. Wybór pliku i przygotowanie folderu
[fname, fpath] = uigetfile('*.csv', 'Wybierz plik pomiarowy .csv');
if isequal(fname,0), disp('Anulowano wybór pliku.'); return; end
full_path = fullfile(fpath, fname);

if cfg.save_files
    if ~exist(cfg.device_name, 'dir'), mkdir(cfg.device_name); end
end

% 2. Wczytanie i mapowanie danych
fprintf('Wczytywanie danych: %s... \n', fname);
data = dlmread(full_path, ',', 1, 0);
time = data(:, 1);

col.v_avg = 20; col.i_avg = 21; col.u_rms = 22; col.u1_rms = 23;
col.i_rms = 24; col.i1_rms = 25; col.freq = 26; col.p = 27;
col.p1 = 28; col.q = 29; col.q1 = 30; col.s = 31; col.s1 = 32;
col.thd_v = 33; col.thd_i = 34; col.pf = 35; col.dpf = 36;
col.df = 37; col.v_peak = 38; col.i_peak = 39;

% 3. Podział na zakresy czasu
if isempty(cfg.plot_x_range), idx_p = 1:length(time); else idx_p = find(time >= cfg.plot_x_range(1) & time <= cfg.plot_x_range(2)); end
t_p = time(idx_p); d_p = data(idx_p, :);

if isempty(cfg.stat_x_range), idx_s = 1:length(time); else idx_s = find(time >= cfg.stat_x_range(1) & time <= cfg.stat_x_range(2)); end
d_s = data(idx_s, :);

% 4. Statystyki i Raport
target_cols = [col.v_avg, col.i_avg, col.u_rms, col.u1_rms, col.i_rms, col.i1_rms, col.p, col.p1, col.q, col.q1, col.s, col.s1, col.freq, col.thd_v, col.thd_i, col.pf, col.dpf, col.df, col.v_peak, col.i_peak];
labels = {'V_śr', 'I_śr', 'U_rms', 'U1_rms', 'I_rms', 'I1_rms', 'P', 'P1', 'Q', 'Q1', 'S', 'S1', 'Częstotliwość', 'THD_U', 'THD_I', 'PF', 'DPF', 'DF', 'V_szczyt', 'I_szczyt'};
stats_res = [mean(d_s(:,target_cols)); max(d_s(:,target_cols)); min(d_s(:,target_cols))];

report = sprintf('RAPORT POMIAROWY - %s, Range: %s\nParametr;', cfg.device_name, num2str(cfg.stat_x_range));
for l=labels, report = [report, sprintf('%s;', l{1})]; end; report = [report, '\n'];
to_pl = @(v) strrep(sprintf('%.4f', v), '.', ',');
row_n = {'Średnia', 'Max', 'Min'};
for r = 1:3
    report = [report, row_n{r}, ';'];
    for c = 1:columns(stats_res), report = [report, to_pl(stats_res(r,c)), ';']; end; report = [report, '\n'];
end

if cfg.save_files
    fid = fopen(fullfile(cfg.device_name, 'raport_pomiarowy.txt'), 'w');
    fprintf(fid, report); fclose(fid);
end
fprintf(report);

% 5. Stylizacja i funkcje pomocnicze
apply_base_style = @(ax_h) (set(ax_h, 'LineWidth', cfg.axes_line_width, 'XMinorTick', 'on', 'YMinorTick', 'on', 'XMinorGrid', 'on', 'YMinorGrid', 'on'));
save_fig = @(h, name) print(h, fullfile(cfg.device_name, [cfg.device_name '_' name '.png']), '-dpng', '-r200');

% 6. GENEROWANIE WYKRESÓW

% F1: Napięcie RMS
f1 = figure('Position', cfg.window_size, 'Color', [1 1 1]);
h = plot(t_p, d_p(:, col.u_rms), 'Color', cfg.color_v, t_p, d_p(:, col.u1_rms), 'Color', cfg.color_v1);
set(h, 'LineWidth', cfg.line_width); grid on; grid minor; apply_base_style(gca);
title('Napięcie skuteczne RMS, V'); xlabel('Czas, s'); ylabel('Napięcie, V');
legend('U_{skut}', 'U1_{skut}');
if cfg.save_files, save_fig(f1, 'U_rms'); end

% F2: Prąd RMS
f2 = figure('Position', cfg.window_size, 'Color', [1 1 1]);
h = plot(t_p, d_p(:, col.i_rms), 'Color', cfg.color_i, t_p, d_p(:, col.i1_rms), 'Color', cfg.color_i1);
set(h, 'LineWidth', cfg.line_width); grid on; grid minor; apply_base_style(gca);
title('Prąd skuteczny RMS, A'); xlabel('Czas, s'); ylabel('Natężenie prądu, A');
legend('I_{skut}', 'I1_{skut}');
if cfg.save_files, save_fig(f2, 'I_rms'); end

% F3: Zbiorczy RMS (Tylko lewa siatka)
f3 = figure('Position', cfg.window_size, 'Color', [1 1 1]);
[ax, h1, h2] = plotyy(t_p, d_p(:, [col.u_rms, col.u1_rms]), t_p, d_p(:, [col.i_rms, col.i1_rms]));
set(h1(1), 'Color', cfg.color_v); set(h1(2), 'Color', cfg.color_v1);
set(h2(1), 'Color', cfg.color_i); set(h2(2), 'Color', cfg.color_i1);
set([h1; h2], 'LineWidth', cfg.line_width);
set(ax(1), 'YColor', cfg.color_v, 'LineWidth', cfg.axes_line_width);
set(ax(2), 'YColor', cfg.color_i, 'LineWidth', cfg.axes_line_width);
grid(ax(1), 'on'); grid(ax(1), 'minor');
set(ax(1), 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on');
set(ax(2), 'YMinorGrid', 'off', 'YMinorTick', 'on');
title('Zbiorcza analiza RMS'); xlabel('Czas, s'); ylabel(ax(1), 'Napięcie, V'); ylabel(ax(2), 'Natężenie prądu, A');
legend([h1; h2], 'U_{skut}', 'U1_{skut}', 'I_{skut}', 'I1_{skut}');
if cfg.save_files, save_fig(f3, 'Zbiorczy_RMS'); end

% F4: Moc Pełna
f4 = figure('Position', cfg.window_size, 'Color', [1 1 1]);
h = plot(t_p, d_p(:, col.p), 'g', t_p, d_p(:, col.p1), 'y', t_p, d_p(:, col.q), 'r', t_p, d_p(:, col.q1), 'm', t_p, d_p(:, col.s), 'b', t_p, d_p(:, col.s1), 'c');
set(h, 'LineWidth', cfg.line_width); grid on; grid minor; apply_base_style(gca);
title('Analiza mocy: P, Q, S (Wszystkie składowe)'); xlabel('Czas, s'); ylabel('Moc, W/VAR/VA');
legend('P', 'P1', 'Q', 'Q1', 'S', 'S1');
if cfg.save_files, save_fig(f4, 'Moc_Pelna'); end

% F5: Częstotliwość (Średnia krocząca)
f5 = figure('Position', cfg.window_size, 'Color', [1 1 1]);
win = cfg.freq_smooth_win; b = (1/win)*ones(1,win); zi = 50 * (1 - cumsum(b)(1:end-1));
fv = filter(b, 1, d_p(:, col.freq), zi); fv = [fv(floor(win/2)+1:end); fv(end)*ones(floor(win/2),1)];
h = plot(t_p, fv, 'Color', [0, 0.5, 0]); set(h, 'LineWidth', cfg.line_width);
ylim(cfg.freq_y_range); grid on; grid minor; apply_base_style(gca);
title('Częstotliwość sieci, Hz'); xlabel('Czas, s'); ylabel('Częstotliwość, Hz');
if cfg.save_files, save_fig(f5, 'Czestotliwosc'); end

% F6: THD
f6 = figure('Position', cfg.window_size, 'Color', [1 1 1]);
h = plot(t_p, d_p(:, col.thd_v), 'Color', cfg.color_v, t_p, d_p(:, col.thd_i), 'Color', cfg.color_i);
set(h, 'LineWidth', cfg.line_width); ylim([0 cfg.thd_y_limit]); grid on; grid minor; apply_base_style(gca);
title('Współczynnik zawartości harmonicznych THD, %'); xlabel('Czas, s'); ylabel('THD, %');
legend('THD U', 'THD I');
if cfg.save_files, save_fig(f6, 'THD'); end

% F7: Współczynniki
f7 = figure('Position', cfg.window_size, 'Color', [1 1 1]);
h = plot(t_p, d_p(:, col.pf), 'k', t_p, d_p(:, col.dpf), 'b--', t_p, d_p(:, col.df), 'r:');
set(h, 'LineWidth', cfg.line_width); grid on; grid minor; apply_base_style(gca);
title('Współczynniki mocy'); xlabel('Czas, s'); ylabel('Wartość współczynnika, -');
legend('PF', 'DPF/Cos(fi)', 'DF');
if cfg.save_files, save_fig(f7, 'Wspolczynniki'); end

% F8: Średnie Symetryczne (Tylko lewa siatka)
f8 = figure('Position', cfg.window_size, 'Color', [1 1 1]);
[ax, h1, h2] = plotyy(t_p, d_p(:, col.v_avg), t_p, d_p(:, col.i_avg));
v_l = max(abs(d_p(:, col.v_avg)))*1.1; i_l = max(abs(d_p(:, col.i_avg)))*1.1;
set(ax(1), 'YLim', [-v_l, v_l], 'YColor', cfg.color_v, 'LineWidth', cfg.axes_line_width);
set(ax(2), 'YLim', [-i_l, i_l], 'YColor', cfg.color_i, 'LineWidth', cfg.axes_line_width);
set(h1, 'Color', cfg.color_v); set(h2, 'Color', cfg.color_i); set([h1; h2], 'LineWidth', cfg.line_width);
grid(ax(1), 'on'); grid(ax(1), 'minor');
set(ax(1), 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on');
set(ax(2), 'YMinorGrid', 'off', 'YMinorTick', 'on');
title('Średnie wartości Napięcia i Prądu'); xlabel('Czas, s');
ylabel(ax(1), 'Napięcie średnie, V'); ylabel(ax(2), 'Natężenie prądu średnie, A');
legend([h1, h2], 'U_{śr}', 'I_{śr}');
if cfg.save_files, save_fig(f8, 'Srednie_Symetryczne'); end

% F9: Wartości szczytowe Peak (Tylko lewa siatka)
f9 = figure('Position', cfg.window_size, 'Color', [1 1 1]);
[ax, h1, h2] = plotyy(t_p, d_p(:, col.v_peak), t_p, d_p(:, col.i_peak));
set(h1, 'Color', cfg.color_v); set(h2, 'Color', cfg.color_i); set([h1; h2], 'LineWidth', cfg.line_width);
set(ax(1), 'YColor', cfg.color_v, 'LineWidth', cfg.axes_line_width);
set(ax(2), 'YColor', cfg.color_i, 'LineWidth', cfg.axes_line_width);
grid(ax(1), 'on'); grid(ax(1), 'minor');
set(ax(1), 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on');
set(ax(2), 'YMinorGrid', 'off', 'YMinorTick', 'on');
title('Wartości szczytowe'); xlabel('Czas, s');
ylabel(ax(1), 'Napięcie szczytowe, V'); ylabel(ax(2), 'Natężenie prądu szczytowe, A');
legend([h1, h2], 'U_{peak}', 'I_{peak}');
if cfg.save_files, save_fig(f9, 'Peak'); end

% F10: Moc Całkowita
f10 = figure('Position', cfg.window_size, 'Color', [1 1 1]);
h = plot(t_p, d_p(:, col.p), 'Color', [0, 0.6, 0], t_p, d_p(:, col.q), 'Color', [0.8, 0, 0], t_p, d_p(:, col.s), 'Color', [0, 0, 0.8]);
set(h, 'LineWidth', cfg.line_width); grid on; grid minor; apply_base_style(gca);
title('Moc całkowita: P, Q, S'); xlabel('Czas, s'); ylabel('Moc, W/VAR/VA');
legend('P, W', 'Q, VAR', 'S, VA');
if cfg.save_files, save_fig(f10, 'Moc_Calkowita'); end

fprintf('\nZakończono. Wszystkie dane i 10 wykresów zapisano w folderze: %s\n', cfg.device_name);
