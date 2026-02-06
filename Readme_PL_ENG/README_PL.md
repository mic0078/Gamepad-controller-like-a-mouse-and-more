# Kontroler_Konfigurator.ps1

# Opis

Skrypt **Kontroler_Konfigurator.ps1** umożliwia konfigurację kontrolera do pracy jako myszka z graficznym interfejsem użytkownika (GUI). Pozwala na dostosowanie ustawień kontrolera według własnych preferencji, zapisując konfigurację w pliku `ControllerConfig.json`.

# Funkcje skryptu
- Konfiguracja przycisków i osi kontrolera do obsługi kursora myszy oraz kliknięć.
- Graficzny interfejs użytkownika ułatwiający wybór i przypisanie funkcji.
- Zapis i odczyt ustawień z pliku konfiguracyjnego JSON.
- Możliwość szybkiej zmiany ustawień bez edycji plików ręcznie.

# Wymagania
- Windows
- PowerShell

#  Użycie
1. Uruchom skrypt `Kontroler_Konfigurator.ps1` w PowerShell.
2. Skorzystaj z GUI do przypisania funkcji przyciskom kontrolera.
3. Zapisz konfigurację – ustawienia zostaną zapisane w pliku `ControllerConfig.json`.

*Ten projekt pozwala na wygodne dostosowanie kontrolera do pracy jako myszka na komputerze z systemem Windows.*


#  Instrukcja obsługi

1. **Uruchomienie skryptu**
	- Kliknij prawym przyciskiem myszy na plik `Kontroler_Konfigurator.ps1` i wybierz „Uruchom z PowerShell” lub otwórz PowerShell w folderze ze skryptem i wpisz:
	  ```powershell
	  ./Kontroler_Konfigurator.ps1
	  ```

2. **Korzystanie z GUI**
	- Po uruchomieniu skryptu pojawi się okno graficzne.
	- Przypisz funkcje (np. ruch myszy, kliknięcia, przewijanie) do wybranych przycisków i osi kontrolera, korzystając z dostępnych opcji w GUI.
	- Możesz testować przypisania na bieżąco, obserwując reakcje kursora.

3. **Zapis konfiguracji**
	- Po zakończeniu konfiguracji kliknij przycisk „Zapisz” i „Uruchom kontroler”.
	- Ustawienia zostaną zapisane w pliku `ControllerConfig.json` w tym samym folderze.
    - Po ustawieniach i zapisie konfiguracji nie zamykaj okna, lecz zminimalizuj do zasobnika systemowego
    - Ważne: Przycisk "ZAMKNIJ" zabija własego siebie (PID) i jego "dzieci" , czyli całkowicie znika z procesów aby kontroler działał , aplikacja powinna być zminimalizowana do zasobnika. 

4. **Zmiana ustawień**
	- Aby zmienić konfigurację, wystarczy zapisać nowe ustawienia. Nowe ustaweinia przeładują się samoczynnie bez konieczności ponownego używania przycisku "URUCHOM KONTROLER".

5. **Przywracanie domyślnych ustawień**
	- Usuń plik `ControllerConfig.json` lub wybierz opcję.
---

W razie problemów sprawdź, czy kontroler jest poprawnie podłączony do komputera i czy masz uprawnienia do uruchamiania skryptów PowerShell.


Twórca: MichAel 2026