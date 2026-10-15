import csv

def policz_wiersze_csv(sciezka_do_pliku, czy_zawiera_naglowek=True):
    try:
        # Otwieramy plik z kodowaniem utf-8, co zapobiega błędom z polskimi znakami
        with open(sciezka_do_pliku, mode='r', encoding='utf-8') as plik:
            czytnik = csv.reader(plik)
            
            # Liczymy wiersze "w locie" - nie ładujemy całego pliku do pamięci
            liczba_wierszy = sum(1 for wiersz in czytnik)
            
            # Jeśli plik ma nagłówek (nazwy kolumn), odejmujemy go od wyniku
            if czy_zawiera_naglowek and liczba_wierszy > 0:
                liczba_wierszy -= 1
                
        return liczba_wierszy
        
    except FileNotFoundError:
        return "Błąd: Nie znaleziono wskazanego pliku."
    except Exception as e:
        return f"Wystąpił nieoczekiwany błąd: {e}"

# --- Użycie skryptu ---
sciezka = 'calib_I_drift_16A.csv' # Wpisz tutaj ścieżkę do swojego pliku
wynik = policz_wiersze_csv(sciezka)

print(f"Liczba wierszy z danymi: {wynik}")