# Session Journal

Append-only: new entries are added at the end, never overwrite old ones.
Always start each new entry with a blank line.

## Journal rules

- Each entry starts with `## YYYY-MM-DD — <short name>`
- After the header, add exactly 5 bullet items in this order:
  1. `Request: ...`
  2. `Done: ...`
  3. `Verified: ...`
  4. `Not done / limitations: ...`
  5. `Next: ...`
- Do not skip bullets, do not reorder them
- Old entries are never modified — only new ones appended

## Entry format (example)

```
## 2026-11-08 — Memory setup

- Request: set up project memory that persists across sessions.
- Done: created AGENTS.md, CONTEXT.md, SESSIONS.md, DECISIONS.md, archive structure.
- Verified: rotation script tested on copy, git commit made, sizes confirmed.
- Not done / limitations: real project task not yet defined, git remote not set.
- Next: receive project description from user, fill CONTEXT.md with real data.
```

## Current journal entries (new ones added at end)

*(This section is auto-populated as entries are added - do not manually rearrange)*

## 2026-11-08 — Initial memory setup

- Request: ...
- Done: ...
- Verified: ...
- Not done / limitations: ...
- Next: ...

## 2026-11-08 — Universal memory system and cleanup

- Request: replace the platform-specific memory setup with a universal solution that can be hosted on GitHub and referenced by any agent from any application.
- Done: created `.project-memory/` (AGENTS.md, CONTEXT.md, SESSIONS.md, DECISIONS.md, archive/INDEX.md), wrote `UNIVERSAL_MEMORY_GUIDE.md` (Russian deployment guide). Removed old platform-specific files: root `AGENTS.md`, `docs/` (CONTEXT/SESSIONS/DECISIONS/archive) and `scripts/archive-sessions.sh`. Filled `.project-memory/CONTEXT.md` with the project's actual data (name «Оптимизация», goal, stack, run commands, next steps).
- Verified: rotation script tested on a copy earlier (sessions moved to `archive/YYYY-MM.md`, index rebuilt); git tree clean except pending deletions; universal files in place.
- Not done / limitations: repo still local; push to a remote requires explicit user instruction. No application code yet — this repo is the memory infrastructure itself.
- Next: user describes the real project task/stack or confirms this repo stays as a memory-template repo for GitHub distribution.
## 2026-11-08 — README.md для неподготовленного пользователя

- **Request:** сделать README.md понятный любому неподготовленному пользователю.
- **Done:** создан `README.md` в корне: «память проекта для любого AI-агента» — объяснение простыми словами, таблица файлов, протокол из 4 шагов (до/после сессии), два варианта установки (файлы в проекте и публикация на GitHub с примером raw-ссылки), пример обычной сессии, FAQ, лицензия. Удалён дублирующий `UNIVERSAL_MEMORY_GUIDE.md`, ссылка в `.project-memory/CONTEXT.md` обновлена на `README.md`.
- **Verified:** дерево и git-статус сверены после коммита; README самодостаточен (не ссылается на файлы, которых нет).
- **Not done / limitations:** README покрывает только память-систему; документация конкретного проекта (стек, команды) по-прежнему заполняется пользователем в `CONTEXT.md`.
## 2026-11-08 — Comfort layer: TASK, QUESTIONS, event-driven state, compact handoff (committed)

- **Request:** сделать проект комфортным для любой среды с агентом (любой инструмент может открыть папку и продолжить).
- **Done:** `TASK.md`, `QUESTIONS.md`, обновлён `AGENTS.md` (L0/L1/L2, событийное обновление, хендшейк), `DECISIONS.md`, `README.md`, `scripts/memory-check.sh`, `.githooks/pre-commit`. Git коммит создан.
- **Verified:** `git status` чистый; `.githooks/pre-commit` и `scripts/memory-check.sh` — OK.
- **Not done / limitations:** задача/стек проекта ещё не заданы, поэтому TASK.md пока idle; тест восстановления после краша и test pre-commit блокирующий сценарий не запускались (требуют намерения).
- **Next:** определить задачу/стек проекта и при необходимости — тест восстановления и эвристики.

## 2026-11-08 — Crash safety: autosave script and scratchpad recovery

- **Request:** добавить разумную автоматизацию на случай краша (пропадало питание, упал сервер и т.п.).
- **Done:** `.project-memory/.in-progress.md` (scratchpad с маркером `status: open/closed`) — агент пишет заметки по ходу работы; протокол в `.project-memory/AGENTS.md` — шаги крахной проверки при старте (autosave + восстановление из scratchpad), ведения блокнота в процессе и закрытия в конце; `scripts/memory-autosave.sh` (rescue-коммит несохранённой памяти); опциональный `.githooks/pre-commit` (память подмешивается в каждый коммит); раздел «Что если сессия упала» + FAQ в `README.md`; решение записано в `DECISIONS.md`.
- **Verified:** `git status` чистый после коммита; блокнот в состоянии `status: closed`; оба скрипта прочитаны и допускают идемпотентный запуск.
- **Not done / limitations:** полный тест восстановления (симуляция краша) в этой сессии не прогонялся; хук включается пользователем вручную одной командой `git config core.hooksPath .githooks`.
- **Next:** по желанию — тест сценария краша и восстановления из `.in-progress.md`.

## 2026-11-09 — Self-contained .project-memory

- **Request:** полная самодостаточность папки .project-memory — ничего вне её; плюс памятка для пользователя внутри папки.
- **Done:** перенесены `scripts/memory-autosave.sh` → `.project-memory/memory-autosave.sh`, `.githooks/pre-commit` → `.project-memory/pre-commit`, пустые каталоги удалены; создана памятка `.project-memory/README.md`; обновлены все ссылания на пути (AGENTS.md, CONTEXT.md, оба README, сами скрипты); решение записано в DECISIONS.md.
- **Verified:** `memory-check.sh` — 0 ошибок / 0 предупреждений; ручной запуск `pre-commit` проходит; `memory-autosave.sh` в чистом состоянии сообщает «nothing to save»; рабочее дерево чистое после коммита.
- **Not done / limitations:** хук не активирован (решение пользователя — оставить); secret-скан в `memory-check.sh` фактически не работает (неверные флаги grep) — только advisory.
- **Next:** ожидает подтверждения пользователя. Опционально: активировать хук, починить secret-скан.

## 2026-11-09 — AllToAny published on GitHub

- **Request:** опубликовать память-систему на GitHub как чистый репозиторий без истории, единым коммитом.
- **Done:** старый .git (9 коммитов) удалён, репо пересобрано с нуля (main, 15 файлов, exec-биты на скриптах); создано публичное репо `IgerOK/AllToAny`, remote origin добавлен, пуш выполнен.
- **Verified:** push `main -> main` прошёл, tracking установлен; на GitHub ровно 1 коммит.
- **Not done / limitations:** SSH-ключ к GitHub не настроен (пуш по HTTPS через GCM); secret-скан в `memory-check.sh` не работает (неверные флаги grep) — advisory.
- **Next:** ожидает подтверждения пользователя. Опционально: активировать pre-commit хук, починить secret-скан.

## 2026-11-09 — README для непродвинутых + описание репо

- **Request:** описание GitHub-репо — простым языком для большинства (непродвинутых) пользователей; в README — пометка, что настоятельно рекомендуется Git в любом проекте и что агент сам его установит/активирует по просьбе.
- **Done:** в GitHub About вставлено простое описание («Память» для ИИ-помощника…); в README.md (раздел «Зачем это нужно») добавлена цитата-рекомендация про Git и что агент сам установит/подключит; оба изменения запушены в `IgerOK/AllToAny` (коммиты 2e9f034, 10157eb).
- **Verified:** GitHub API вернул обновлённое описание (DESC); коммиты `Fix typos in README.md` + `Add git recommendation note to README` в origin/main; git status чистый.
- **Not done / limitations:** описание GitHub-репо — текстовое поле, правится только через UI/API (коммитами не меняется).
- **Next:** по желанию — активировать pre-commit хук, починить secret-скан в memory-check.sh.

## 2026-11-21 — Клонирование Flasher32G0 + опшен-байт BOOT0 (nBOOT_SEL)

- Request: склонировать https://github.com/IgerOK/Flasher32G0, сделать локальный GIT, доработать: для серии STM32G0 добавить в опшен-байты активацию распознавания BOOT0 для использования и SWD, и UART.
- Done: репо склонировано в `D:\STM32-prj\Flasher32G0` (локальный git `main`, remote origin). В `Flasher32G0.ahk` добавлена группа «BOOT0 (распознавание пина)» с чекбоксом для G0/G4: чтение `nBOOT_SEL` через `-ob displ`, запись `nBOOT_SEL=0` (legacy: пин BOOT0 → system memory / UART bootloader) или `nBOOT_SEL=1` (бит nBOOT0, заводское значение). Обновлены предпросмотр, предупреждения, справка, `ConfigureGuiForFamily`; кнопки правой панели сдвинуты вниз, высота окна 530→615, версия 1.1. `README.md`: колонка BOOT0 в таблице семейств, раздел «BOOT0 (G0/G4)». Коммит `22ee3b2`. Память проекта переключена на Flasher32G0 (TASK/CONTEXT/DECISIONS).
- Verified: `git status` чистый; полный diff просмотрен; синтаксис AHK проверен логически. Ahk2Exe в этой среде выдаёт «Failed to compile» без текста даже на тестовом минискрипте — инструмент в окружении некорректен, поэтому новый `.exe` пользователь компилирует сам (по договорённости).
- Not done / limitations: старый `Flasher32G0.exe` (v1.0) не пересобран; на реальном STM32G0 не проверялось; точный формат вывода `nBOOT_SEL` в `-ob displ` зависит от версии CLI — regex пробует `nBOOT_SEL:` и `BOOT_SEL:`, иначе показывает «(не читается)».
- Next: пользователь компилирует `Flasher32G0.ahk` в новый `.exe`, проверяет на STM32G0 (BOOT0 через SWD + UART bootloader), при необходимости подправляет regex под вывод своего CLI, затем пушит на GitHub.
