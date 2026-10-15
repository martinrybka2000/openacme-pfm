pkg load io

clear all; clc;

% 1. Wybór pliku
[fname, fpath] = uigetfile('*.csv', 'Wybierz plik pomiarowy .csv');
if isequal(fname,0)
    disp('Anulowano wybór pliku.');
    return;
end

full_path = fullfile(fpath, fname);

% 2. Wczytanie danych (pominiecie nagłówka)
% Zakładamy, że Serial Studio używa przecinka jako separatora wewnątrz pliku CSV
data = dlmread(full_path, ',', 1, 0);

% 3. Mapowanie kolumn WYŁĄCZNIE z sekcji "All as data"
% Indeksy na podstawie struktury pliku grzalka.csv (Octave liczy od 1)
% Kolejność zgodna z Twoją tabelą Excel + Freq na końcu
col_map = [
    20, % Vavg [V]    - STM/All as data/avg Voltage
    22, % Vrms [V]    - STM/All as data/U_rms
    23, % V1rms [V]   - STM/All as data/U1_rms
    38, % Vpk [V]     - STM/All as data/peak Voltage
    21, % Iavg [A]    - STM/All as data/avg Current
    24, % Irms [A]    - STM/All as data/I_rms
    25, % I1rms [A]   - STM/All as data/I1_rms
    39, % Ipk [A]     - STM/All as data/peak Current
    27, % P [W]       - STM/All as data/P
    28, % P1 [W]      - STM/All as data/P1
    29, % Q [VAR]     - STM/All as data/Q
    30, % Q1 [VAR]    - STM/All as data/Q1
    31, % S [VA]      - STM/All as data/S
    10, % S1 [VA]     - STM/All as data/S1
    35, % PF          - STM/All as data/PF
    36, % Cos(fi)     - STM/All as data/DPF/Cos(fi)
    37, % DP (DF)     - STM/All as data/DF
    33, % V_THD [%]   - STM/All as data/THD voltage
    34, % I_THD [%]   - STM/All as data/THD Current
    26  % Frequency   - STM/All as data/Frequency (Dodana na końcu)
];

% Wyciągnięcie danych
selected_data = data(:, col_map);

% 4. Obliczenia statystyczne
v_avg  = mean(selected_data);
v_max  = max(selected_data);
v_min  = min(selected_data);
v_diff_plus  = v_max - v_avg;
v_diff_minus = v_avg - v_min;

% Złożenie wyników w macierz (5 wierszy statystyk)
results = [v_avg; v_max; v_min; v_diff_plus; v_diff_minus];

% 5. Wyświetlanie danych sformatowanych pod Excel (średnik i przecinek)
fprintf('\nDane dla pliku: %s\n', fname);
fprintf('Skopiuj poniższe wiersze i wklej do Excela:\n\n');

for i = 1:5
    line_str = '';
    for j = 1:size(results, 2)
        % Formatowanie liczby do stringa z 4 miejscami po przecinku
        val_str = sprintf('%.4f', results(i, j));
        % Zamiana kropki na przecinek
        val_str = strrep(val_str, '.', ',');

        % Budowanie wiersza z separatorem średnika
        if j == 1
            line_str = val_str;
        else
            line_str = [line_str ';' val_str];
        end
    end
    % Wypisanie gotowego wiersza do terminala
    fprintf('%s\n', line_str);
end
