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
- Код: `Flasher32G0.ahk` (GUI-логика), `README.md` (установка .exe — через GitHub Releases), `LICENSE`, `screenshot.png` (v1.1), `flasher_v1.1.png`, `flasher_v1.1_1.png`, `flasher_v1.1_2.png`, `Option_bytes_1.png`.
- **`.exe` вынесен из репозитория** (коммит `7d97721`): бинарник больше не лежит в корне, раздаётся через GitHub **Releases**; локально `Flasher32G0.exe` (v1.1, скомпилирован пользователем) сохраняется в `.gitignore` для тестов.
- **Доработка (v1.1):** добавлен опшен-байт **BOOT0 / распознавание пина CLKSWD** для семейств G0/G4:
  - чекбокс «Распознавать пин CLKSWD» в правой панели;
  - запись `nBOOT_SEL=0` (чекбокс вкл., legacy: уровень пина определяет загрузку: CLKSWD=0 → user flash, CLKSWD=1 → system memory bootloader, UART+SWD) или `nBOOT_SEL=1` (чекбокс выкл., заводское: пин игнорируется, только SWD);
  - **Семантика (финальная, от пользователя, `8062970`):** чекбокс лишь ОТКРЫВАЕТ ВОЗМОЖНОСТЬ прошиться по SWD или UART; пин CLKSWD управляет пользователь САМОСТОЯТЕЛЬНО до подачи питания (для =1 джампер к VCC; рекомендуется резистор 10к CLKSWD→GND);
  - **Запуск своего кода после прошивки:** снять джампер с VCC (пин через 10к к GND → CLKSWD=0) + RESET; чекбокс при этом можно не трогать;
  - чтение текущего `nBOOT_SEL` через `-ob displ`;
  - расширены предпросмотр, предупреждения, справка, README;
  - починена обрезанная подпись IWDG (чекбокс w170, индикатор ниже чекбокса).
- Коммиты: `22ee3b2` (первичный BOOT0 nBOOT_SEL), `80f142f` (временно на nBOOT0 + IWDG + .exe), `5d57bc5` (семантика текста), `8062970` (исправление: чекбокс управляет nBOOT_SEL, не nBOOT0), `f7d93b0` (примечания BOR/NRST), `982969d` (диод для не-open-drain выхода супервизора), `ee90e00` (лаконичная справка IWDG), `bdbb27d` (README: история версий v1.1 vs v1.0), `a2467bf` (пересобранный .exe + память).
- На GitHub (`origin/main`) всё ещё **v1.0** — локально **22 коммита выше origin**, пуш только по явному запросу.

## 5. Next steps

- Пользователь пересобирает `.exe` (Ahk2Exe) и тестирует на STM32G0:
  - чекбокс ВКЛ (`nBOOT_SEL=0`) + CLKSWD=1 (джампер к VCC) → прошивка по UART;
  - затем снять джампер (CLKSWD=0) + RESET → стартует user flash.
- При необходимости — подправить regex `ReadOptionBytes` под фактический формат `-ob displ` в CLI v2.17.0 (теперь читается `nBOOT_SEL`).
- Пуш на GitHub (только по явному запросу пользователя — не пушить без подтверждения).

## 6. Session bookkeeping

- **Last session focus:** 4-я итерация v1.1 — исправление семантики BOOT0: чекбокс управляет `nBOOT_SEL` (распознавание пина CLKSWD), а не `nBOOT0`.
- **Next logical step:** пользователь пересобирает .exe, тест на чипе, затем пуш по запросу.
