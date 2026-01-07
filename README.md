# UEC2_MTM_Project_Duck_Hunt
# Duck Hunt FPGA - Multiplayer

Projekt odwzorowujący klasyczną grę **Duck Hunt** (znaną z konsoli NES) na układzie FPGA **Digilent Basys 3**. Gra została napisana w języku SystemVerilog i wzbogacona o tryb wieloosobowy (Multiplayer) komunikujący się między dwiema płytkami za pomocą interfejsu UART.

## 🎮 O Projekcie

Głównym celem projektu była implementacja gry zręcznościowej w technice cyfrowej, wykorzystując architekturę potokową VGA oraz maszyny stanów (FSM) do sterowania logiką gry. Projekt obsługuje sterowanie myszką USB (interfejs PS/2) oraz wyświetlanie obrazu w rozdzielczości VGA.

### Główne funkcjonalności:
* **Rozgrywka**: Strzelanie do generowanych pseudolosowo kaczek poruszających się po ekranie.
* **Sterowanie**: Obsługa myszki komputerowej do celowania i strzelania.
* **Grafika**: Generowana sprzętowo grafika 2D wykorzystująca sprite'y (kaczka, pies, chmury, trawa) przechowywane w pamięci ROM.
* **Multiplayer**: Możliwość gry na dwie osoby przy użyciu dwóch płytek Basys 3 połączonych kablem UART. Wyniki i status gry są synchronizowane między graczami.
* **System punktacji**: Licznik trafień oraz limit amunicji (nabojów).

---

## 🖼️ Wygląd gry (Visuals)

Gra odwzorowuje klasyczną estetykę 8-bitową. Ekran składa się z kilku warstw renderowanych sprzętowo:

1.  **Tło**: Błękitne niebo z poruszającymi się chmurami (`cloud_64x17`).
2.  **Pierwszy plan**: Zielona trawa (`grass_128x35`) oraz drzewo, za którymi chowają się kaczki.
3.  **Postacie**:
    * **Kaczki**: Animowane sprite'y (`duck_96x60`) zmieniające klatki w zależności od kierunku lotu i stanu (żywa/zestrzelona).
    * **Pies**: Kultowa postać psa (`dog_rom`), która reaguje na wyniki gracza (łapie kaczki lub śmieje się przy pudle).
4.  **Interfejs (HUD)**:
    * Celownik sterowany myszką.
    * Liczba naboi (`draw_bullets`).
    * Aktualny wynik liczbowy (`draw_string`).

*(Aby dodać zrzut ekranu, wykonaj zdjęcie monitora lub wyeksportuj stronę z raportu jako obraz i umieść go w folderze `doc/`, a następnie odkomentuj linię poniżej)*

![Rozgrywka Duck Hunt](doc/gameplay_placeholder.png)
> *Przykładowy widok rozgrywki: celownik namierzający kaczkę nad 8-bitową trawą.*

---

## 🛠️ Architektura Sprzętowa

Projekt przeznaczony jest na płytkę rozwojową **Digilent Basys 3** z układem Artix-7.

### Wymagania:
* **Płytka FPGA**: Basys 3 (xc7a35tcpg236-1).
* **Wyświetlacz**: Monitor VGA (rozdzielczość 640x480 lub 800x600).
* **Sterowanie**: Myszka USB (obsługiwana przez port USB-HID w trybie emulacji PS/2).
* **Połączenie (opcjonalne)**: Kabel micro-USB do programowania oraz połączenie Pmod/UART do trybu multiplayer.

### Struktura modułów:
* `top_vga_basys3`: Główny moduł spinający wszystkie komponenty.
* `MouseCtl`: Kontroler myszy (odczytuje ruch X/Y i kliknięcia).
* `vga_timing`: Generowanie sygnałów synchronizacji poziomej i pionowej.
* `draw_*`: Moduły odpowiedzialne za wyświetlanie poszczególnych elementów (kaczka, tło, napisy).
* `game_control_fsm`: Maszyna stanów zarządzająca logiką gry (Start -> Gra -> Koniec rundy).
* `uart_tx/rx`: Moduły komunikacji szeregowej do wymiany wyników między graczami.

---

## 🚀 Jak uruchomić (Build & Run)

Projekt wykorzystuje środowisko **Xilinx Vivado**. W katalogu `fpga/scripts` oraz `tools/` znajdują się skrypty ułatwiające budowanie.

1.  **Sklonuj repozytorium:**
    ```bash
    git clone <adres_repozytorium>
    cd UEC2_MTM_Project_Duck_Hunt
    ```

2.  **Wygeneruj bitstream (Linux/Bash):**
    Możesz skorzystać z gotowych skryptów w folderze `tools/`:
    ```bash
    cd tools
    ./generate_bitstream.sh
    ```
    *Alternatywnie otwórz Vivado, dodaj pliki z folderu `fpga/rtl` oraz `fpga/constraints` i uruchom "Generate Bitstream".*

3.  **Zaprogramuj układ:**
    Podłącz płytkę Basys 3 i uruchom:
    ```bash
    ./program_fpga.sh
    ```

---

## 🕹️ Sterowanie

| Akcja | Urządzenie | Opis |
| :--- | :--- | :--- |
| **Celowanie** | Myszka | Ruch myszką przesuwa celownik na ekranie. |
| **Strzał** | LPM (Lewy Przycisk) | Wystrzelenie pocisku w stronę kaczki. |
| **Reset** | Przycisk `BTNC` | Reset gry / powrót do menu głównego. |

---

## 📂 Struktura plików

* `fpga/` – Kody źródłowe projektu (RTL, Constraints, Skrypty Tcl).
* `rtl/` – Główna logika gry i moduły rysujące (Draw files, Game Control).
    * `Data_files/` – Dane bitmapowe sprite'ów (hex/data).
    * `Draw_files/` – Logika wyświetlania obiektów.
    * `Mouse_Control/` – Obsługa myszy PS/2.
* `sim/` – Testbench'e do symulacji poszczególnych modułów.
* `doc/` – Dokumentacja projektu (Raport PDF, schematy).

---

## 👥 Autorzy

Projekt zrealizowany w ramach kursu **UEC2 (Układy Elektroniczne Cyfrowe 2)**.
* **LG** (L. Gasecki)
* **OSZ** (O. Sz.)

> *Wszelkie prawa do oryginalnej marki "Duck Hunt" należą do Nintendo. Projekt ma charakter wyłącznie edukacyjny.*
