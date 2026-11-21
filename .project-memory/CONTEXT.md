# Project Context

**Current state of the project.** Updated at the end of every session.

## 1. What this project is about

- **Name:** Flasher32G0
- **Goal:** GUI-утилита (AutoHotkey v2) для прошивки STM32 и настройки Option Bytes через STM32CubeProgrammer CLI (ST-LINK/SWD).
- **Problem it solves:** Не нужно запоминать синтаксис CLI-команд; интерфейс показывает текущие опции и позволяет записать их (BOR, IWDG, RDP, NRST MODE, BOOT0) и/или прошить flash по адресу 0x08000000.

## 2. Stack & Environment

| Component | Value |
| --- | --- |
| Language | AutoHotkey v2 |
| GUI | AutoHotkey `Gui` (Windows, адаптивный ресайз) |
| External tool | STM32CubeProgrammer CLI (`STM32_Programmer_CLI.exe`) |
| Interface | SWD через ST-LINK; family detect по Device ID |
| Families | STM32G0 (полная), STM32G4 (полная), STM32F4 (без NRST/BOOT0), STM32F1 (только RDP) |
| OS | Windows (x86/x64) |
| Repo | `https://github.com/IgerOK/Flasher32G0` (локальный git, main) |

## 3. How to run / build / use

**Run source:**
```
git clone https://github.com/IgerOK/Flasher32G0.git
cd Flasher32G0
Flasher32G0.ahk          # нужен AutoHotkey v2
```
или запустить `Flasher32G0.exe` (компилируется вручную через Ahk2Exe).

**Build (.ahk → .exe):**
- `Ahk2Exe -in Flasher32G0.ahk -out Flasher32G0.exe` (исполняемый AHK v2)

**Memory protocol:**
1. Перед работой → читать `.project-memory/AGENTS.md`, затем `CONTEXT.md`, `TASK.md`, последние 3 записи `SESSIONS.md`.
2. По ходу — вести `.in-progress.md` (crash safety).
3. После работы — дописать `SESSIONS.md`, обновить `TASK.md`/`CONTEXT.md`/`DECISIONS.md`, закрыть `.in-progress.md`.

## 4. Current status

- Репо склонировано в `D:\STM32-prj\Flasher32G0`, локальный git работает (main).
- Код: `Flasher32G0.ahk` (GUI-логика), `Flasher32G0.exe` (старый билд v1.0), `README.md`, `LICENSE`, `screenshot.png`.
- **Доработка (v1.1):** добавлен опшен-байт **BOOT0 / nBOOT_SEL** для семейств G0/G4:
  - чекбокс «Распознавать пин BOOT0» в правой панели;
  - чтение текущего `nBOOT_SEL` через `-ob displ`;
  - запись `nBOOT_SEL=0` (legacy: пин BOOT0 распознаётся → можно уйти в system memory / UART bootloader) или `nBOOT_SEL=1` (управление через бит nBOOT0, заводское значение);
  - расширены предпросмотр, справка, README.
- Коммит: `22ee3b2` (код + README). `.exe` НЕ пересобран — пользователь компилирует сам.

## 5. Next steps

- Пользователь: скомпилировать `.ahk` в новый `.exe` и проверить на реальном STM32G0 (BOOT0 через SWD + UART).
- По желанию: пуш на GitHub (только по явному запросу пользователя — не пушить без подтверждения).
- Опционально: поддержка UART-загрузки прошивки (`port=UART`), если потребуется.

## 6. Session bookkeeping

- **Last session focus:** клонирование + реализация nBOOT_SEL (BOOT0) для G0/G4.
- **Next logical step:** ручная компиляция и наладка пользователем.
