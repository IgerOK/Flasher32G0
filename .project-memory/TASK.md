# Current task

Явное текущее состояние работы. Агент читает этот файл при старте и обновляет его по событиям, а не только в конце сессии. Длина активной части — компактная (~60 строк), старые записи живут в `SESSIONS.md`.

## Теперь (текущий статус)

status: idle (v1.1 опубликована на GitHub)

## Последняя задача (резюме)

- 2026-11-21 (итерация 11): **v1.1 полностью опубликована**:
  1. пуш `main` → origin (32 коммита, `6ce159c..3db5fca`) — на GitHub v1.1: changelog, новый скриншот, .exe убран из корня;
  2. аннотированный тег `v1.1` создан и запушен;
  3. релиз `v1.1` (id 453797442) создан через GitHub API, ассет `Flasher32G0.exe` (1 015 515 байт) загружен: https://github.com/IgerOK/Flasher32G0/releases/download/v1.1/Flasher32G0.exe
  Токен брался из Windows Credential Manager (`git credential fill`), временный файл `%TEMP%\ghcred.txt` удалён после операции.

## Open work (если status != idle)

- next step: тест v1.1 на реальном STM32G0 (BOOT0-путь: UART-прошивка → снять джампер → user flash); следующая итерация → tег v1.2 + релиз
- checks to run: если `-ob displ` не выводит `nBOOT_SEL` — подправить regex в `ReadOptionBytes`
- blockers: нет
- decisions to reference: DECISIONS.md (Binaries via GitHub Releases)

## Подпись последнего обновления

last-updated: 2026-11-21
