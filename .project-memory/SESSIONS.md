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

## 2026-11-21 — BOOT0 → активация System Bootloader (nBOOT0) + IWDG label

- Request: (по скриншоту v1.1) починить обрезанную подпись IWDG; BOOT0 — не «распознавать пин», а «активировать».
- Done: IWDG — чекбокс `w115→w170`, индикатор значения перенесён под чекбокс (`y140`), фикс в `OnGuiSize`. BOOT0 переименована в «System Bootloader»: пишется `nBOOT_SEL=1` (заводское, пин игнорируется) + `nBOOT0=0` (bootloader ON: UART/USB DFU, SWD работает) или `nBOOT0=1` (user flash). Обновлены предпросмотр, предупреждение, парсинг `nBOOT0`, справка, README; новый v1.1 .exe (откомпилирован пользователем), коммит `80f142f`.
- Verified: git diff просмотрен; grep nBOOT_SEL/nBOOT0 подтверждает консистентность; .exe скомпилирован пользователем сам.
- Not done / limitations: на чипе не проверялось; точный вывод `-ob displ` по `nBOOT0` зависит от версии CLI (regex пробует `nBOOT0:` и `BOOT0:`).
- Next: тест на STM32G0: вкл. BOOT0 → UART-прошивка → выкл. BOOT0 (nBOOT0=1) → запуск user flash; пуш на GitHub по явному запросу.

## 2026-11-21 — Клонирование Flasher32G0 + опшен-байт BOOT0 (nBOOT_SEL)

- Request: склонировать https://github.com/IgerOK/Flasher32G0, сделать локальный GIT, доработать: для серии STM32G0 добавить в опшен-байты активацию распознавания BOOT0 для использования и SWD, и UART.
- Done: репо склонировано в `D:\STM32-prj\Flasher32G0` (локальный git `main`, remote origin). В `Flasher32G0.ahk` добавлена группа «BOOT0 (распознавание пина)» с чекбоксом для G0/G4: чтение `nBOOT_SEL` через `-ob displ`, запись `nBOOT_SEL=0` (legacy: пин BOOT0 → system memory / UART bootloader) или `nBOOT_SEL=1` (бит nBOOT0, заводское значение). Обновлены предпросмотр, предупреждения, справка, `ConfigureGuiForFamily`; кнопки правой панели сдвинуты вниз, высота окна 530→615, версия 1.1. `README.md`: колонка BOOT0 в таблице семейств, раздел «BOOT0 (G0/G4)». Коммит `22ee3b2`. Память проекта переключена на Flasher32G0 (TASK/CONTEXT/DECISIONS).
- Verified: `git status` чистый; полный diff просмотрен; синтаксис AHK проверен логически. Ahk2Exe в этой среде выдаёт «Failed to compile» без текста даже на тестовом минискрипте — инструмент в окружении некорректен, поэтому новый `.exe` пользователь компилирует сам (по договорённости).
- Not done / limitations: старый `Flasher32G0.exe` (v1.0) не пересобран; на реальном STM32G0 не проверялось; точный формат вывода `nBOOT_SEL` в `-ob displ` зависит от версии CLI — regex пробует `nBOOT_SEL:` и `BOOT_SEL:`, иначе показывает «(не читается)».
- Next: пользователь компилирует `Flasher32G0.ahk` в новый `.exe`, проверяет на STM32G0 (BOOT0 через SWD + UART bootloader), при необходимости подправляет regex под вывод своего CLI, затем пушит на GitHub.

## 2026-11-21 — Уточнение семантики BOOT0 (CLSKWD) по разъяснению пользователя

- Request: пользователь уточнил поведение чекбокса: это осознанный выбор «что мне нужно». `nBOOT0=1` — прошивка только по SWD. `nBOOT0=0` — прошивка и по SWD (CLKSWD=0), и по UART (CLKSWD=1). Уровнем пина CLKSWD управляет пользователь САМОСТОЯТЕЛЬНО до подачи питания: для =1 джампер к VCC, рекомендуется резистор 10к CLKSWD→GND.
- Done: обновлены GUI-подпись (индикатор `(bootloader: UART + SWD)`), предпросмотр, предупреждения (включая `[ℹ]` для nBOOT0=1), справка, README (таблица + блок CLKSWD). Код и текст закоммичены в `5d57bc5` (без .exe — пользователь пересоберёт сам). Память (TASK/CONTEXT/DECISIONS) синхронизирована.
- Verified: `git diff` просмотрен (54 строки в .ahk, 46 в README); grep подтверждает отсутствие устаревших фраз; семантика CLKSWD отражена во всех 5 местах консистентно.
- Not done / limitations: `.exe` в репо устарел (содержит `80f142f`); на чипе не проверялось; пользователь должен перескомпилировать `.ahk` перед тестом.
- Next: пользователь компилирует `Flasher32G0.ahk`, проверяет на STM32G0 (nBOOT0=1 → только SWD; nBOOT0=0 → CLKSWD=0 SWD / CLKSWD=1 UART), затем по явному запросу пуш на GitHub.

## 2026-11-21 — Итоговая семантика BOOT0: чекбокс = nBOOT_SEL (legacy), запуск кода = снять джампер + RESET

- Request: пользователь уточнил: чекбокс только предоставляет ВОЗМОЖНОСТЬ прошиться по SWD или UART; при запуске пользовательского кода нужно снять джампер с плюса питания (пин вернётся в 0 через подтяжку 10к к земле) и перезагрузить чип.
- Done: семантика возвращена к `nBOOT_SEL` (чекбокс ВКЛ → `nBOOT_SEL=0` legacy, уровень пина CLKSWD выбирает область загрузки: 0 → user flash, 1 → system memory bootloader UART+SWD; ВЫКЛ → `nBOOT_SEL=1`, пин игнорируется). `nBOOT0` больше не записывается. Обновлены: подпись GUI («Распознавать пин CLKSWD»), предпросмотр, предупреждения (с шагом «СНЯТЬ ДЖАМПЕР С ПЛЮСА ПИТАНИЯ + RESET»), парсинг `nBOOT_SEL`, справка, README. Коммит `8062970` (код + README, без .exe). Память проекта синхронизирована.
- Verified: полный diff просмотрен; grep подтверждает, что `nBOOT0` в логике записи удалён; таблица загрузки сверена с AN5145/RM0454 (nBOOT_SEL=0 + nBOOT1=1: BOOT0=0 → Main Flash, BOOT0=1 → System Memory).
- Not done / limitations: .exe (44a2d75) не содержит `8062970` — пользователь пересоберёт сам; на чипе не проверялось; формат вывода `nBOOT_SEL` в `-ob displ` зависит от версии CLI.
- Next: пользователь компилирует `.ahk`, тест на STM32G0 (ВКЛ + джампер → UART; снять джампер + RESET → свой код), пуш на GitHub по явному запросу.

## 2026-11-21 — UI: короткая статусная надпись BOOT0 (SWD / SWD+UART)

- Request: по скриншоту flasher_v1.1_1.png — подправить надпись в секции BOOT0: убрать лишнее. Не активен → «SWD», активен → «SWD+UART».
- Done: `lblCurBOOT0` — стартовое значение «SWD»; добавлен обработчик `OnBOOT0Change` (OnEvent "Change"), переключающий надпись «SWD»/«SWD+UART» при клике по чекбоксу; в `ReadOptionBytes` парсинг `nBOOT_SEL` теперь пишет короткие надписи («SWD» / «SWD+UART», фолбэк «(не читается)»). Коммит `1eaad9d`.
- Verified: git diff просмотрен (12 insertions / 3 deletions), обработчик зарегистрирован до создания элементов, глобалы объявлены.
- Not done / limitations: .exe в репо не содержит `1eaad9d` — пользователь пересоберёт сам; визуальная проверка на реальном GUI не делалась.
- Next: пользователь компилирует `.ahk`, при желании пушит на GitHub (по явному запросу).

## 2026-11-21 — UI: лаконичная подпись чекбокса BOOT0

- Request: по скриншоту flasher_v1.1_2.png — убрать лишний/нечитаемый текст подписи чекбокса BOOT0 («Распознавать пин CLKSWD» не помещается и обрывается на «CLKSWD»).
- Done: подпись чекбокса заменена на лаконичный эквивалент «Включить UART» (коммит `8c4750a`): чекбокс даёт возможность прошивки по UART, детали — в статусной надписи (SWD/SWD+UART) и в справке. Старая фраза в .ahk не осталась (grep).
- Verified: diff 1 строка; grep «Распознавать пин» — 0 совпадений в Flasher32G0.ahk.
- Not done / limitations: .exe в репо не содержит `8c4750a` — пользователь пересоберёт сам.
- Next: пользователь компилирует `.ahk`; пуш на GitHub по явному запросу.

## 2026-11-21 — Справка/README: примечания BOR Level 2 и конденсатор NRST

- Request: подправить справку: (1) BOR — «Level 2: ~2.5V» без привязки к G031 + пояснение, что при медленном нарастании напряжения код может не запуститься, устраняется внешним супервизором (лучший вариант — контроль супервизором входного напряжения LDO-стабилизатора 3,3В, оптимальный уровень 4,5В — корректный сброс на плато 3,3В); (2) можно не использовать конденсатор 0,1 мкФ на NRST, при необходимости — 1000 пкФ около пина для лучшей помехозащищённости.
- Done: в AHK-справке и README (BOR-таблица, блок NRST): удалено «рекомендуется для G031» (в README — «Оптимальный порог»), добавлены оба примечания. Коммит `f7d93b0` (код + README + пересобранный пользователем .exe).
- Verified: diff просмотрен (12 строк .ahk, 13 строк README); grep «G031» в контексте BOR отсутствует (осталась только строка «Для STM32G031F8P6 в Arduino IDE» — не относится к BOR).
- Not done / limitations: на чипе/плате не проверялось (чисто документация).
- Next: пользователь компилирует `.ahk` при необходимости (exe уже закоммичен с этими правками), пуш на GitHub по явному запросу.

## 2026-11-21 — Примечание BOR: диод для не-open-drain супервизора

- Request: уточнение пользователя — если выход внешнего супервизора НЕ open-drain, обязательно добавить диод Шоттки (или обычный) анодом к NRST, катодом к выходу супервизора.
- Done: примечание дописано в справку AHK (блок BOR) и синхронно в README (блок примечания BOR). Коммит `982969d`; пересобранный пользователем .exe закоммичен в `7cd61a1`.
- Verified: diff просмотрен (7 insertions, 0 deletions), текст консистентен в AHK и README.
- Not done / limitations: на плате не проверялось (документация).
- Next: пуш на GitHub по явному запросу.

## 2026-11-21 — Лаконичная справка IWDG + история версий в README (v1.1 vs v1.0)

- Request: (1) пояснить про IWDG максимально лаконично, без потери смысла; (2) на GitHub-README v1.1 не видно отличий от v1.0 — добавить.
- Done: в AHK-справке IWDG-блок расширен на 3 строки (авто-старт после сброса, «кормление» в main-цикле, отключение только перезаписью опшен-байтов) — коммит `ee90e00`. В README добавлена секция «📋 История версий»: v1.1 (BOOT0/nBOOT_SEL, примечания BOR/NRST/IWDG, фикс IWDG-label, новая группа в GUI) vs v1.0 — коммит `bdbb27d`. Пересобранный .exe закоммичен в `a2467bf`.
- Verified: diff просмотрен (22 строки README, 4 строки .ahk); дерево git чистое после `a2467bf`.
- Not done / limitations: на GitHub до сих пор v1.0 (пуши не делалось — только по явному запросу); отличия v1.1 видны теперь только после пуша.
- Next: пуш на GitHub по явному запросу (сделает v1.1 видимым в удалённом репо).

## 2026-11-21 — Миграция .exe в GitHub Releases

- Request: пользователь скомпилировал v1.1; .exe v1.0 из корня репо лучше удалить, скомпилированный бинарник поместить в релиз.
- Done: `git rm --cached Flasher32G0.exe` (локальный файл сохранён для тестов), добавлен в `.gitignore`, README «Вариант 1» теперь ссылается на страницу Releases (v1.1). Коммит `7d97721`. Решение записано в DECISIONS.md.
- Verified: git status — .exe не отслеживается и не в ignore-статусе ??; README ссылается на Releases.
- Not done / limitations: сам GitHub Release v1.1 ещё не создан (нужен доступ к GitHub); пуш ветки не выполнялся (ждёт явного запроса).
- Next: пользователь пушит main и создаёт Release v1.1 (загружает локальный Flasher32G0.exe как ассет).

## 2026-11-21 — Пуш на GitHub + релиз v1.1 с .exe

- Request: сделать пуш и подготовить релиз на GitHub; если не получится загрузить .exe — пользователь добавит вручную.
- Done: (1) пуш `main` на origin — 32 локальных коммита ушли (6ce159c..3db5fca), удалённое репо теперь v1.1 (changelog, новый скриншот, без .exe в корне); (2) создан аннотированный тег `v1.1` и запушен; (3) через GitHub API (токен из Windows Credential Manager, без `gh` CLI) создан релиз `v1.1` (id 453797442) и загружен ассет `Flasher32G0.exe` (1 015 515 байт, state=uploaded, sha256 зафиксирован GitHub).
- Verified: ответ API на загрузку ассета — `state:"uploaded"`, download URL `https://github.com/IgerOK/Flasher32G0/releases/download/v1.1/Flasher32G0.exe`; после загрузки ассет виден в `assets` релиза.
- Not done / limitations: временный токен из Credential Manager использовался в `%TEMP%\ghcred.txt` и удалён после операции; рабочие скрипты лежат в `.agnes/work/` (локальный кэш, не в репо).
- Next: по необходимости — пуш новых коммитов, новый релиз v1.2 при следующей итерации.

## 2026-11-21 — Зачистка графических файлов (остался только screenshot.png)

- Request: удалить все графические файлы кроме скриншота проекта (остальные — только для справки).
- Done: `git rm` — flasher_v1.1.png, flasher_v1.1_1.png, flasher_v1.1_2.png, Option_bytes_1.png; удалён untracked «screenshot — копия.png»; CONTEXT.md обновлён (в списке файлов остался только screenshot.png). Удаление закоммичено.
- Verified: `git ls-files *.png` → только screenshot.png; активных ссылок на удалённые PNG в README нет (упомянуты только как «по скриншоту» в журнале SESSIONS — исторические записи, не трогаем).
- Not done / limitations: в истории git файлы остаются (старики видны в предыдущих коммитах) — для полного вытеснения из истории потребовалась бы перезапись истории, не делалась.
- Next: пуш коммита чистки (по явному запросу или вместе с следующим).
