; ============================================================================
; Flasher32G0.ahk - STM32 Option Bytes & Flasher
; ============================================================================
; Автор:      https://github.com/IgerOK
; Лицензия:   MIT (2026)
; Версия:     1.1
;
; Описание:   GUI-утилита для прошивки STM32 и настройки Option Bytes
;              через STM32CubeProgrammer CLI.
;
; Поддерживаемые семейства: STM32G0, STM32G4, STM32F4, STM32F1
;
; Особенности:
;   - Автоматическое определение семейства чипа
;   - Настройка BOR, IWDG, RDP, NRST MODE
;   - Программирование только Option Bytes (без перезаписи flash)
;   - Разблокировка чипа (RDP Level 1 -> Level 0)
;   - Сохранение геометрии окна
;   - Предпросмотр изменений перед записью опций
; ============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; 1. Автоматический запрос прав администратора
if not A_IsAdmin {
    try {
        Run('*RunAs "' A_ScriptFullPath '"')
    }
    ExitApp
}

; --- НАСТРОЙКИ ПО УМОЛЧАНИЮ И ДИНАМИЧЕСКИЕ ПЕРЕМЕННЫЕ ---
SplitPath(A_ScriptFullPath, , , , &scriptNameNoExt)
global INI_FILE := A_ScriptDir "\" scriptNameNoExt ".ini"
global DEFAULT_CUBE_PATH := "C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"
global CUBE := ""
global BIN_DIR := ""
global BIN_FILE := ""
global MCU_FAMILY := "UNKNOWN"

; Явное объявление всех элементов GUI глобальными
global edtCube, edtBinDir, btnBrowseCube, btnBrowseBin, ddlBinFiles, txtTitle, btnRefresh, logBox
global gbBOR, ddlBOR, lblCurBOR
global gbIWDG, chkIWDG, lblCurIWDG, gbRDP, chkLockRDP, lblCurRDP
global gbNRST, ddlNRST, lblCurNRST, txtFamilyInfo
global gbBOOT, chkBOOT0, lblCurBOOT0
global btnOptOnly, btnHelp

; Проверяем наличие программатора по умолчанию перед чтением конфига
if FileExist(DEFAULT_CUBE_PATH) {
    CUBE := DEFAULT_CUBE_PATH
} else {
    msgResult := MsgBox("Программатор STM32CubeProgrammer не найден по стандартному пути.`n`nХотите открыть страницу загрузки, чтобы скачать и установить его?", "Программатор не найден", "YesNo")
    if (msgResult == "Yes") {
        Run("https://st.com")
    }
}

; --- СОЗДАНИЕ ИНТЕРФЕЙСА (GUI) ---
myGui := Gui("+Resize +MinSize840x615", "Flasher32G0 v1.1 — запись в STM32 flash по адресу 0x08000000")
myGui.OnEvent("Size", OnGuiSize)
myGui.OnEvent("Close", (*) => (SaveConfig(), ExitApp()))
myGui.SetFont("s10", "Segoe UI")

; Поясняющая строка семейства микросхем
txtFamilyInfo := myGui.Add("Text", "x20 y5 w570 h18 +BackgroundTrans cBlue", "Подключите чип и нажмите ОБНОВИТЬ для определения семейства...")

; Блок программатора
myGui.Add("Text", "x20 y25 w460 h20", "Путь к STM32_Programmer_CLI.exe:")
edtCube := myGui.Add("Edit", "x20 y45 w460 h25 ReadOnly", CUBE)
btnBrowseCube := myGui.Add("Button", "x490 y45 w100 h25", "Обзор...")
btnBrowseCube.OnEvent("Click", OnBrowseCubeClick)

; Блок папки прошивок
myGui.Add("Text", "x20 y85 w460 h20", "Папка с прошивками (.bin, .hex):")
edtBinDir := myGui.Add("Edit", "x20 y110 w460 h25 ReadOnly", BIN_DIR)
btnBrowseBin := myGui.Add("Button", "x490 y110 w100 h25", "Обзор...")
btnBrowseBin.OnEvent("Click", OnBrowseBinClick)

; Выпадающий список файлов прошивки
myGui.Add("Text", "x20 y150 w460 h20", "Файл для программирования:")
ddlBinFiles := myGui.Add("ComboBox", "x20 y170 w570 Choose1", ["Выделите папку..."])

; Блок логов, заголовка и кнопка ОБНОВИТЬ
txtTitle := myGui.Add("Text", "x20 y220 w460 h25 +Center +0x200 Border Background0xEEEEEE", "СТАТУС: Ожидание подключения чипа")
btnRefresh := myGui.Add("Button", "x490 y220 w100 h25", "ОБНОВИТЬ")
btnRefresh.OnEvent("Click", (*) => ReadOptionBytes())
logBox := myGui.Add("Edit", "x20 y255 w570 h230 ReadOnly Multi +HScroll")

; --- ПРАВАЯ ПАНЕЛЬ НАСТРОЕК ---
gbBOR := myGui.Add("GroupBox", "x610 y15 w210 h75", "BOR Level (Сброс по питанию)")
ddlBOR := myGui.Add("DropDownList", "x625 y40 w115 Choose1", ["BOR OFF", "Level 0 (~1.7V)", "Level 1 (~2.1V)", "Level 2 (~2.5V)", "Level 3 (~2.8V)"])
lblCurBOR := myGui.Add("Text", "x740 y43 w70 h20 +Right cGray", "")

gbIWDG := myGui.Add("GroupBox", "x610 y100 w210 h65", "IWDG (Сторожевой таймер)")
chkIWDG := myGui.Add("Checkbox", "x625 y118 w170 h20", "Аппаратный HW")
lblCurIWDG := myGui.Add("Text", "x625 y140 w170 h18 cGray", "")

gbRDP := myGui.Add("GroupBox", "x610 y175 w210 h65", "RDP (Защита от чтения)")
chkLockRDP := myGui.Add("Checkbox", "x625 y200 w115 h20", "Включить Lev 1")
lblCurRDP := myGui.Add("Text", "x740 y200 w70 h20 +Right cGray", "")

gbNRST := myGui.Add("GroupBox", "x610 y250 w210 h75", "NRST MODE (Режим сброса)")
ddlNRST := myGui.Add("DropDownList", "x625 y275 w115 Choose1", ["Input/Output", "Reset Input Only"])
lblCurNRST := myGui.Add("Text", "x740 y278 w70 h20 +Right cGray", "")

gbBOOT := myGui.Add("GroupBox", "x610 y335 w210 h80", "BOOT0 (System Bootloader)")
chkBOOT0 := myGui.Add("Checkbox", "x625 y358 w180 h20", "Распознавать пин CLKSWD")
lblCurBOOT0 := myGui.Add("Text", "x625 y380 w180 h20 cGray", "(пин игнорируется)")

; --- НОВЫЕ КНОПКИ (ОПЦИИ и СПРАВКА) ---
btnOptOnly := myGui.Add("Button", "x610 y425 w100 h35", "ОПЦИИ")
btnOptOnly.OnEvent("Click", OnOptOnlyClick)

btnHelp := myGui.Add("Button", "x720 y425 w100 h35", "СПРАВКА")
btnHelp.OnEvent("Click", OnHelpClick)

; --- СУЩЕСТВУЮЩИЕ КНОПКИ ---
btnUnlock := myGui.Add("Button", "x610 y470 w210 h40", "РАЗБЛОКИРОВАТЬ ЧИП")
btnUnlock.OnEvent("Click", OnUnlockClick)

btnFlash := myGui.Add("Button", "x610 y520 w210 h45 Default Disabled", "ПРОГРАММИРОВАТЬ ЧИП")
btnFlash.OnEvent("Click", OnFlashClick)

btnExit := myGui.Add("Button", "x610 y575 w210 h35", "ВЫХОД")
btnExit.OnEvent("Click", (*) => (SaveConfig(), ExitApp()))

; --- ЗАГРУЗКА КОНФИГУРАЦИИ И ЗАПУСК ОКНА ---
winX := "", winY := "", winW := "", winH := ""
LoadConfig(&winX, &winY, &winW, &winH)

if (winX != "" && winY != "" && winW != "" && winH != "") {
    myGui.Show("x" winX " y" winY " w" winW " h" winH)
} else {
    myGui.Show("w840 h615 Center")
}

if (CUBE != "") {
    ReadOptionBytes()
}
return

; ============================================================================
; ОБРАБОТЧИК ИЗМЕНЕНИЯ РАЗМЕРОВ ОКНА (RESPONSIVE GUI)
; ============================================================================
OnGuiSize(thisGui, windowMinMax, width, height) {
    if (windowMinMax = -1) 
        return

    rightX := width - 230           
    leftPanelWidth := rightX - 40   
    btnWidth := 100                 
    editWidth := leftPanelWidth - btnWidth - 10 

    edtCube.Move(, , editWidth)
    btnBrowseCube.Move(20 + editWidth + 10) 
    
    edtBinDir.Move(, , editWidth)
    btnBrowseBin.Move(20 + editWidth + 10)
    
    ddlBinFiles.Move(, , leftPanelWidth)
    
    txtTitle.Move(, , leftPanelWidth - 110) 
    btnRefresh.Move(20 + (leftPanelWidth - 110) + 10) 
    
    newLogHeight := height - 295
    logBox.Move(, , leftPanelWidth, newLogHeight)

    gbBOR.Move(rightX),    ddlBOR.Move(rightX + 15),    lblCurBOR.Move(rightX + 130)
    gbIWDG.Move(rightX),   chkIWDG.Move(rightX + 15),   lblCurIWDG.Move(rightX + 15)
    gbRDP.Move(rightX),    chkLockRDP.Move(rightX + 15), lblCurRDP.Move(rightX + 130)
    gbNRST.Move(rightX),   ddlNRST.Move(rightX + 15),   lblCurNRST.Move(rightX + 130)
    gbBOOT.Move(rightX),   chkBOOT0.Move(rightX + 15),  lblCurBOOT0.Move(rightX + 15)

    btnOptOnly.Move(rightX, 425)
    btnHelp.Move(rightX + 110, 425)

    btnUnlock.Move(rightX, 470)
    btnFlash.Move(rightX, 520)
    btnExit.Move(rightX, 575)

    DllCall("InvalidateRect", "Ptr", thisGui.Hwnd, "Ptr", 0, "Int", true)
    DllCall("UpdateWindow", "Ptr", thisGui.Hwnd)
}

; ============================================================================
; ПОКАЗ ПАРАМЕТРОВ ПЕРЕД ЗАПИСЬЮ
; ============================================================================
ShowOptionsPreview() {
    global MCU_FAMILY, ddlBOR, chkIWDG, chkLockRDP, ddlNRST, chkBOOT0
    
    previewText := "Будут записаны следующие параметры:`n`n"
    
    previewText .= "  • BOR Level: " ddlBOR.Text "`n"
    
    iwdgText := chkIWDG.Value ? "Активен (HW)" : "Выключен (SW)"
    previewText .= "  • IWDG: " iwdgText "`n"
    
    rdpText := chkLockRDP.Value ? "Level 1 (защита включена)" : "Level 0 (защита выключена)"
    previewText .= "  • RDP: " rdpText "`n"
    
    if (MCU_FAMILY == "G0" || MCU_FAMILY == "G4") {
        previewText .= "  • NRST Mode: " ddlNRST.Text "`n"
        boot0Text := chkBOOT0.Value ? "Пин распознаётся (nBOOT_SEL=0) — выбор: CLKSWD=0 → user code / CLKSWD=1 → bootloader (SWD+UART)" : "Пин игнорируется (nBOOT_SEL=1) — только SWD"
        previewText .= "  • BOOT0: " boot0Text "`n"
    }
    
    warningsText := ""
    if (chkIWDG.Value) {
        warningsText .= "`n[!] ВНИМАНИЕ: Включение аппаратного watchdog (IWDG) `n"
        warningsText .= "    требует обновления watchdog в прошивке, иначе чип будет перезагружаться.`n"
    }
    if (chkLockRDP.Value) {
        warningsText .= "`n[!] ВНИМАНИЕ: Включение RDP Level 1 заблокирует чтение/запись через SWD.`n"
        warningsText .= "    Для разблокировки потребуется кнопка 'РАЗБЛОКИРОВАТЬ ЧИП'.`n"
    }
    if (chkBOOT0.Value && (MCU_FAMILY == "G0" || MCU_FAMILY == "G4")) {
        warningsText .= "`n[!] ВНИМАНИЕ: будет ВКЛЮЧЕНО распознавание пина (nBOOT_SEL=0).`n"
        warningsText .= "    Чекбокс ОТКРЫВАЕТ ВОЗМОЖНОСТЬ прошиться по SWD или по UART.`n"
        warningsText .= "    Уровень пина CLKSWD задаётся ВРУЧНУЮ до подачи питания:`n"
        warningsText .= "    CLKSWD=1 — джампер к VCC (+3.3V) → чип в System Memory`n"
        warningsText .= "    (bootloader: SWD + UART); CLKSWD=0 — джампер снят,`n"
        warningsText .= "    резистор 10к к GND → стартует пользовательский код.`n"
        warningsText .= "    После прошивки: СНЯТЬ ДЖАМПЕР С ПЛЮСА ПИТАНИЯ и`n"
        warningsText .= "    перезагрузить чип — запустится собственный код.`n"
    } else if (!chkBOOT0.Value && (MCU_FAMILY == "G0" || MCU_FAMILY == "G4")) {
        warningsText .= "`n[ℹ] Пин не распознаётся (nBOOT_SEL=1): прошивка только по SWD.`n"
    }
    
    if (warningsText != "") {
        previewText .= "`n────────────────────────────────────`n"
        previewText .= warningsText
        previewText .= "────────────────────────────────────`n"
    }
    
    previewText .= "`nЗаписать указанные параметры в чип?"
    
    result := MsgBox(previewText, "Подтверждение записи Option Bytes", "YesNo")
    return (result = "Yes")
}

; ============================================================================
; ЧТЕНИЕ OPTION BYTES И ОПРЕДЕЛЕНИЕ СЕМЕЙСТВА
; ============================================================================
ReadOptionBytes() {
    global MCU_FAMILY
    if (CUBE == "" || !FileExist(CUBE)) {
        txtTitle.Value := "СТАТУС: Ошибка конфигурации"
        logBox.Value := "Укажите корректный путь к STM32_Programmer_CLI.exe"
        return
    }
    
    txtTitle.Value := "СТАТУС: Чтение Option Bytes..."
    logBox.Value := "====== [1/2] ЧТЕНИЕ OPTION BYTES ======`r`n"
    lblCurBOR.Value := "", lblCurIWDG.Value := "", lblCurRDP.Value := "", lblCurNRST.Value := "", lblCurBOOT0.Value := ""
    
    cmd := '"' CUBE '" -c port=SWD mode=UR reset=HWrst -ob displ'
    logText := RunCMD(cmd)
    
    if InStr(logText, "OPTION BYTES BANK") {
        MCU_FAMILY := "UNKNOWN"
        mcuListStr := "Поддерживаемые чипы в текущем семействе: "
        
        if InStr(logText, "Device ID: 0x466") || InStr(logText, "STM32G0") {
            MCU_FAMILY := "G0"
            txtFamilyInfo.Value := mcuListStr "STM32G030, G031, G041, G070, G071, G081, G0B0, G0B1, G0C1"
        } else if InStr(logText, "Device ID: 0x468") || InStr(logText, "STM32G4") {
            MCU_FAMILY := "G4"
            txtFamilyInfo.Value := mcuListStr "STM32G431, G441, G471, G473, G474, G483, G484, G491, G4A1"
        } else if InStr(logText, "Device ID: 0x413") || InStr(logText, "Device ID: 0x419") || InStr(logText, "STM32F4") {
            MCU_FAMILY := "F4"
            txtFamilyInfo.Value := mcuListStr "STM32F401, F405, F407, F411, F412, F413, F427, F429, F446, F469"
        } else if InStr(logText, "Device ID: 0x410") || InStr(logText, "STM32F1") {
            MCU_FAMILY := "F1"
            txtFamilyInfo.Value := mcuListStr "STM32F100, F101, F102, F103, F105, F107 (Option Bytes ограничены)"
        } else {
            txtFamilyInfo.Value := "Семейство чипа определено как универсальное. Доступны базовые функции."
        }
        
        txtTitle.Value := "СТАТУС: Чип " (MCU_FAMILY != "UNKNOWN" ? MCU_FAMILY : "") " успешно прочитан"
        btnFlash.Enabled := true
        ConfigureGuiForFamily(MCU_FAMILY)
        
        if RegExMatch(logText, "i)RDP\s*:\s*(0x[0-9A-Fa-f]+)", &matchRDP) {
            rdpValue := matchRDP[1]
            if (rdpValue = "0xAA" || rdpValue = "0x55AA") { 
                logBox.Value .= "Чип РАЗБЛОКИРОВАН (RDP = " rdpValue ").`r`n"
                chkLockRDP.Value := 0
                btnUnlock.Enabled := false
                lblCurRDP.Value := "(Level 0)"
            } else {
                logBox.Value .= "Чип ЗАБЛОКИРОВАН (RDP = " rdpValue ").`r`n"
                chkLockRDP.Value := 1
                btnUnlock.Enabled := true
                lblCurRDP.Value := "(Level 1)"
            }
        }
        
        if (MCU_FAMILY == "G0" || MCU_FAMILY == "G4") {
            borEn := 0
            if RegExMatch(logText, "i)BOR_EN\s*:\s*(0x[0-9A-Fa-f]+)", &matchBOR) {
                try borEn := Integer(matchBOR[1])
            }
            if (borEn == 0) {
                lblCurBOR.Value := "(OFF)", ddlBOR.Text := "BOR OFF"
            } else {
                borLev := 0
                if RegExMatch(logText, "i)BORF_LEV\s*:\s*(0x[0-9A-Fa-f]+)", &matchLev) {
                    try borLev := Integer(matchLev[1])
                }
                lblCurBOR.Value := "(Lev " borLev ")"
                switch borLev {
                    case 0:  try ddlBOR.Text := "Level 0 (~1.7V)"
                    case 1:  try ddlBOR.Text := "Level 1 (~2.1V)"
                    case 2:  try ddlBOR.Text := "Level 2 (~2.5V)"
                    case 3:  try ddlBOR.Text := "Level 3 (~2.8V)"
                    default: try ddlBOR.Text := "BOR OFF"
                }
            }
        } else if (MCU_FAMILY == "F4") {
            borLev := 0
            if RegExMatch(logText, "i)BOR_LEV\s*:\s*(0x[0-9A-Fa-f]+)", &matchLevF4) {
                try borLev := Integer(matchLevF4[1])
                if (borLev == 3) {
                    lblCurBOR.Value := "(OFF)", ddlBOR.Text := "BOR OFF"
                } else {
                    lblCurBOR.Value := "(Lev " (3 - borLev) ")"
                    switch borLev {
                        case 2:  try ddlBOR.Text := "Level 1 (~2.1V)"
                        case 1:  try ddlBOR.Text := "Level 2 (~2.5V)"
                        case 0:  try ddlBOR.Text := "Level 3 (~2.8V)"
                        default: try ddlBOR.Text := "BOR OFF"
                    }
                }
            }
        }
        
        iwdgSw := 1
        if RegExMatch(logText, "i)IWDG_SW\s*:\s*(0x[0-9A-Fa-f]+)", &matchIWDG) {
            try iwdgSw := Integer(matchIWDG[1]) 
            if (iwdgSw == 0) {
                chkIWDG.Value := 1, lblCurIWDG.Value := "(активен)"
            } else {
                chkIWDG.Value := 0, lblCurIWDG.Value := "(выкл)"
            }
        }
        
        if (MCU_FAMILY == "G0" || MCU_FAMILY == "G4") {
            nrstMode := 3
            if RegExMatch(logText, "i)NRST_MODE\s*:\s*(0x[0-9A-Fa-f]+)", &matchNRST) {
                try nrstMode := Integer(matchNRST[1])
                if (nrstMode == 3) {
                    lblCurNRST.Value := "(In/Out)", ddlNRST.Text := "Input/Output"
                } else if (nrstMode == 1) {
                    lblCurNRST.Value := "(Reset In)", ddlNRST.Text := "Reset Input Only"
                }
            }

            ; nBOOT_SEL: 0 = legacy mode (распознавать пин CLKSWD), 1 = пин игнорируется (boot по nBOOT0)
            bootSel := -1
            if RegExMatch(logText, "i)nBOOT_SEL\s*:\s*(0x[0-9A-Fa-f]+)", &matchBOOTSEL) || RegExMatch(logText, "i)BOOT_SEL\s*:\s*(0x[0-9A-Fa-f]+)", &matchBOOTSEL) {
                try bootSel := Integer(matchBOOTSEL[1])
                if (bootSel == 0) {
                    chkBOOT0.Value := 1, lblCurBOOT0.Value := "(пин распознаётся)"
                } else {
                    chkBOOT0.Value := 0, lblCurBOOT0.Value := "(пин игнорируется)"
                }
            } else {
                lblCurBOOT0.Value := "(не читается)"
            }
        }
        logBox.Value .= logText
    } else {
        txtTitle.Value := "СТАТУС: Ошибка связи"
        logBox.Value .= "`r`n[ОШИБКА] Не удалось связаться с чипом! Проверьте программатор.`r`n" . logText
        btnFlash.Enabled := false, btnUnlock.Enabled := false
        txtFamilyInfo.Value := "Не удалось определить семейство. Элементы заблокированы."
        ConfigureGuiForFamily("UNKNOWN")
    }
    DllCall("InvalidateRect", "Ptr", myGui.Hwnd, "Ptr", 0, "Int", true)
}

; ============================================================================
; НАСТРОЙКА ДОСТУПНОСТИ ЭЛЕМЕНТОВ В ЗАВИСИМОСТИ ОТ СЕМЕЙСТВА
; ============================================================================
ConfigureGuiForFamily(family) {
    if (family == "G0" || family == "G4") {
        ddlBOR.Enabled := true, ddlNRST.Enabled := true
        chkIWDG.Enabled := true, chkLockRDP.Enabled := true
        chkBOOT0.Enabled := true
    } else if (family == "F4") {
        ddlBOR.Enabled := true, ddlNRST.Enabled := false 
        chkIWDG.Enabled := true, chkLockRDP.Enabled := true
        chkBOOT0.Enabled := false, chkBOOT0.Value := 0
        lblCurNRST.Value := "(зашито)"
        lblCurBOOT0.Value := "(N/A)"
    } else if (family == "F1" || family == "UNKNOWN") {
        ddlBOR.Enabled := false, ddlNRST.Enabled := false
        chkIWDG.Enabled := false, chkLockRDP.Enabled := true
        chkBOOT0.Enabled := false, chkBOOT0.Value := 0
        lblCurBOR.Value := "(N/A)", lblCurNRST.Value := "(N/A)", lblCurIWDG.Value := "(N/A)"
        lblCurBOOT0.Value := "(N/A)"
    }
}

; ============================================================================
; ПРОГРАММИРОВАНИЕ ТОЛЬКО OPTION BYTES
; ============================================================================
OnOptOnlyClick(*) {
    global MCU_FAMILY, chkBOOT0
    
    if !ShowOptionsPreview() {
        logBox.Value := "Операция отменена пользователем.`r`n"
        return
    }
    
    txtTitle.Value := "СТАТУС: Проверка связи..."
    cmdCheck := '"' CUBE '" -c port=SWD mode=UR reset=HWrst -ob displ'
    if !InStr(RunCMD(cmdCheck), "OPTION BYTES BANK") {
        MsgBox("Не удалось связаться с чипом!", "Ошибка", "iconx")
        return
    }
    
    borArgs := "", iwdgArgs := "", rdpArgs := "", nrstArgs := "", bootSelArgs := ""
    
    if (MCU_FAMILY == "G0" || MCU_FAMILY == "G4") {
        if (ddlBOR.Value == 1) {
            borArgs := "BOR_EN=0"
        } else {
            lev := ddlBOR.Value - 2
            borArgs := "BOR_EN=1 BORF_LEV=" lev " BORR_LEV=" lev
        }
        iwdgArgs := "IWDG_SW=" (chkIWDG.Value ? "0" : "1")
        nrstArgs := "NRST_MODE=" (ddlNRST.Value == 1 ? "3" : "1")
        ; nBOOT_SEL: 0 = распознавать пин CLKSWD (legacy: CLKSWD=1 → system memory/bootloader,
        ;             CLKSWD=0 → user flash); 1 = пин игнорируется (boot по nBOOT0)
        bootSelArgs := "nBOOT_SEL=" (chkBOOT0.Value ? "0" : "1")
    } else if (MCU_FAMILY == "F4") {
        if (ddlBOR.Value == 1) {
            borArgs := "BOR_LEV=3"
        } else {
            lev := 3 - (ddlBOR.Value - 2)
            borArgs := "BOR_LEV=" lev
        }
        iwdgArgs := "IWDG_SW=" (chkIWDG.Value ? "0" : "1")
    }
    
    rdpArgs := (MCU_FAMILY == "F1") ? "RDP=" (chkLockRDP.Value ? "0x00" : "0xA5") : "RDP=" (chkLockRDP.Value ? "0xBB" : "0xAA")
    
    optionBytesString := Trim(borArgs " " iwdgArgs " " rdpArgs " " nrstArgs " " bootSelArgs)
    
    txtTitle.Value := "СТАТУС: Программирование Option Bytes..."
    logBox.Value := "====== ПРОГРАММИРОВАНИЕ OPTION BYTES ======`r`n"
    logBox.Value .= "Параметры: " optionBytesString "`r`n"
    
    cmd := '"' CUBE '" -c port=SWD mode=UR reset=HWrst -ob ' optionBytesString
    res := RunCMD(cmd)
    logBox.Value .= res
    
    if InStr(res, "Error") or InStr(res, "FAILED") {
        txtTitle.Value := "СТАТУС: ОШИБКА записи опций"
        MsgBox("Ошибка при записи Option Bytes!", "Ошибка", "iconx")
    } else {
        txtTitle.Value := "СТАТУС: Опции успешно записаны"
        MsgBox("Option Bytes успешно записаны!", "Успех", "iconi")
        if !chkLockRDP.Value
            ReadOptionBytes()
    }
}

; ============================================================================
; ПОЛНОЕ ПРОГРАММИРОВАНИЕ (FLASH + OPTION BYTES)
; ============================================================================
OnFlashClick(*) {
    global BIN_FILE, BIN_DIR, MCU_FAMILY, chkBOOT0
    if (BIN_DIR == "") {
        MsgBox("Укажите папку с прошивками перед запуском!", "Ошибка", 48)
        return
    }
    selectedFileName := ddlBinFiles.Text
    if (selectedFileName == "" || selectedFileName == "Папка не выбрана или не существует" || selectedFileName == "В папке нет файлов прошивки (.bin, .hex)") {
        MsgBox("Пожалуйста, выберите корректный файл прошивки из списка!", "Ошибка", 48)
        return
    }
    
    if (chkIWDG.Value) {
        iwdgConfirm := MsgBox("ВНИМАНИЕ: Аппаратный сторожевой таймер (IWDG HW) будет активирован после перезагрузки.`n`n"
            . "Если в вашей прошивке нет обновления watchdog'а, чип будет перезагружаться каждые ~28 секунд.`n`n"
            . "Продолжить?", "Предупреждение IWDG", "YesNo")
        if (iwdgConfirm != "Yes")
            return
    }
    
    BIN_FILE := BIN_DIR "\" selectedFileName
    btnFlash.Enabled := false
    txtTitle.Value := "СТАТУС: Программирование..."
    logBox.Value := "====== [2/2] ЗАПИСЬ ПРОШИВКИ И НАСТРОЙКА ПАРАМЕТРОВ ======`r`n"
    logBox.Value .= "Выбран файл прошивки: " selectedFileName "`r`n"
    
    borArgs := "", iwdgArgs := "", rdpArgs := "", nrstArgs := "", bootSelArgs := ""
    if (MCU_FAMILY == "G0" || MCU_FAMILY == "G4") {
        if (ddlBOR.Value == 1) {
            borArgs := "BOR_EN=0"
        } else {
            lev := ddlBOR.Value - 2
            borArgs := "BOR_EN=1 BORF_LEV=" lev " BORR_LEV=" lev
        }
        iwdgArgs := "IWDG_SW=" (chkIWDG.Value ? "0" : "1")
        nrstArgs := "NRST_MODE=" (ddlNRST.Value == 1 ? "3" : "1")
        ; nBOOT_SEL: 0 = распознавать пин CLKSWD (legacy: CLKSWD=1 → system memory/bootloader,
        ;             CLKSWD=0 → user flash); 1 = пин игнорируется (boot по nBOOT0)
        bootSelArgs := "nBOOT_SEL=" (chkBOOT0.Value ? "0" : "1")
    } else if (MCU_FAMILY == "F4") {
        if (ddlBOR.Value == 1) {
            borArgs := "BOR_LEV=3" 
        } else {
            lev := 3 - (ddlBOR.Value - 2) 
            borArgs := "BOR_LEV=" lev
        }
        iwdgArgs := "IWDG_SW=" (chkIWDG.Value ? "0" : "1")
    }
    
    rdpArgs := (MCU_FAMILY == "F1") ? "RDP=" (chkLockRDP.Value ? "0x00" : "0xA5") : "RDP=" (chkLockRDP.Value ? "0xBB" : "0xAA")
    
    optionBytesString := Trim(borArgs " " iwdgArgs " " rdpArgs " " nrstArgs " " bootSelArgs)
    logBox.Value .= "Сгенерированные параметры битов: " optionBytesString "`r`n"
    
    cmd := '"' CUBE '" -c port=SWD mode=UR reset=HWrst -ob ' optionBytesString ' -w "' BIN_FILE '" 0x08000000 -v -rst'
    res := RunCMD(cmd)
    logBox.Value .= res
    SaveConfig()
    
    if InStr(res, "Download verified successfully") or InStr(res, "Verification OK") {
        if (chkLockRDP.Value) {
            btnFlash.Enabled := true, btnUnlock.Enabled := false
            txtTitle.Value := "СТАТУС: Чип заблокирован (RDP1)"
        } else {
            ReadOptionBytes()
        }
        MsgBox("Процесс прошивки и верификации успешно завершен!", "Успех", "iconi")
    } else {
        btnFlash.Enabled := true, txtTitle.Value := "СТАТУС: Ошибка записи"
        MsgBox("Ошибка при прошивке чипа! Изучите консольный вывод.", "Ошибка прошивки", "iconx")
    }
}

; ============================================================================
; РАЗБЛОКИРОВКА ЧИПА (RDP LEVEL 1 -> LEVEL 0)
; ============================================================================
OnUnlockClick(*) {
    global MCU_FAMILY
    txtTitle.Value := "СТАТУС: Разблокировка..."
    logBox.Value := "====== СБРОС ЗАЩИТЫ ЧИПА (RDP Level 0) ======`r`n"
    rdpResetVal := (MCU_FAMILY == "F1") ? "0xA5" : "0xAA"
    cmd := '"' CUBE '" -c port=SWD mode=UR reset=HWrst -ob RDP=' rdpResetVal
    logBox.Value .= RunCMD(cmd)
    ReadOptionBytes()
}

; ============================================================================
; ВЫБОР ПУТИ К STM32_Programmer_CLI.exe
; ============================================================================
OnBrowseCubeClick(*) {
    global CUBE
    file := FileSelect(3, , "Выберите STM32_Programmer_CLI.exe", "Исполняемые файлы (*_CLI.exe)")
    if file {
        CUBE := file, edtCube.Value := CUBE
        SaveConfig(), ReadOptionBytes()
    }
}

; ============================================================================
; ВЫБОР ПАПКИ С ПРОШИВКАМИ
; ============================================================================
OnBrowseBinClick(*) {
    global BIN_DIR
    dir := DirSelect(, 3, "Выберите папку с прошивками")
    if dir {
        BIN_DIR := dir, edtBinDir.Value := BIN_DIR
        UpdateBinFilesList(), SaveConfig()
    }
}

; ============================================================================
; ОБНОВЛЕНИЕ СПИСКА ФАЙЛОВ .bin И .hex
; ============================================================================
UpdateBinFilesList() {
    ddlBinFiles.Delete()
    fileList := []
    Loop Files, BIN_DIR "\*.*" {
        if (A_LoopFileExt = "bin" || A_LoopFileExt = "hex")
            fileList.Push(A_LoopFileName)
    }
    if (fileList.Length == 0) {
        ddlBinFiles.Add(["В папке нет файлов прошивки (.bin, .hex)"]), ddlBinFiles.Choose(1)
    } else {
        ddlBinFiles.Add(fileList), ddlBinFiles.Choose(1)
    }
}

; ============================================================================
; СПРАВКА (ОКНО С ВОЗМОЖНОСТЬЮ КОПИРОВАНИЯ ТЕКСТА)
; ============================================================================
OnHelpClick(*) {
    helpText := "
    (
    ═══════════════════════════════════════════════════════════════════════════
              ПОМОЩЬ ПО ПРОГРАММЕ Flasher32G0
              https://github.com/IgerOK   |   Лицензия: MIT (2026)
    ═══════════════════════════════════════════════════════════════════════════

    🔹 ПОДДЕРЖИВАЕМЫЕ СЕМЕЙСТВА:
       ✔️ STM32G0, STM32G4 — полная поддержка (BOR, IWDG, RDP, NRST, BOOT0)
       ⚠️ STM32F4 — частичная (NRST Mode недоступен)
       ⚠️ STM32F1 — минимальная (только RDP, остальные опции не читаются)

    🔹 СТАРТОВЫЙ АДРЕС ЗАПИСИ:
       0x08000000 (начало flash-памяти STM32)

    🔌 ПОДКЛЮЧЕНИЕ:
       • ST-LINK → плата: GND, SWDIO, SWCLK, 3.3V
       • При проблемах проверьте контакты и питание платы

    ⚙️ ОПЦИИ (OPTION BYTES):
       BOR (Brown-Out Reset) - сброс при падении питания
         Level 0: ~1.7V    Level 2: ~2.5V (рекомендуется для G031)
         Level 1: ~2.1V    Level 3: ~2.8V

       IWDG (Watchdog) - аппаратный сторожевой таймер
         Включение требует обновления watchdog в коде, иначе чип сбросится

       RDP (Read Protection) - защита от чтения
         Level 0: нет защиты
         Level 1: чтение/запись через SWD запрещены (снимается массовым
                  стиранием через кнопку РАЗБЛОКИРОВАТЬ ЧИП)
         Level 2: НЕИСПРАВИМО! Чип навсегда заблокирован для программиро-
                  вания! НИКОГДА не устанавливайте Level 2!

       NRST MODE - режим работы ноги сброса
         Input/Output (рекомендуется) или Reset Input Only

       BOOT0 (System Bootloader, nBOOT_SEL, G0/G4)

       Чекбокс — осознанный выбор пользователя: ОТКРЫВАЕТ ВОЗМОЖНОСТЬ
       прошиться либо по SWD, либо по UART (не управляет пинами).

       [НЕ АКТИВИРОВАН] (nBOOT_SEL=1, по умолчанию):
          Пин CLKSWD игнорируется. Прошивка и отладка только по SWD.
          Обычный режим, bootloader отключён.

       [АКТИВИРОВАН] (nBOOT_SEL=0, legacy mode):
          Пин CLKSWD распознаётся, и ЕГО УРОВЕНЬ определяет, куда
          загрузится чип (выбор делает пользователь вручную):
            CLKSWD=0 - старт из Main Flash (свой код), SWD доступен
            CLKSWD=1 - старт в System Memory (bootloader): прошивка
                       по UART (COM-порт) ИЛИ по SWD (ST-LINK)
          УРОВЕНЬ ПИНА CLKSWD УСТАНАВЛИВАЕТ ПОЛЬЗОВАТЕЛЬ САМОСТОЯТЕЛЬНО
          ДО ПОДАЧИ ПИТАНИЯ (программа только пишет опшен-байты):
            Для CLKSWD=1 - подтянуть пин джампером к VCC (+3.3V).
            Рекомендуется постоянный резистор 10к из CLKSWD в GND
            (подтяжка на землю, чтобы по умолчанию CLKSWD=0).

          ЗАПУСК СВОЕГО КОДА ПОСЛЕ ПРОШИВКИ:
            1) СНИМАЕМ ДЖАМПЕР С ПЛЮСА ПИТАНИЯ (VCC) - пин CLKSWD
               вернётся в состояние 0 (через резистор 10к к земле).
            2) ПЕРЕЗАГРУЖАЕМ чип (RESET / перекл. питания).
            3) Стартует пользовательский код.

       ВАЖНО: при активированном чекбоксе (nBOOT_SEL=0) и
       CLKSWD=1 чип загружается в bootloader, а не в вашу прошивку.
       Для запуска своего кода - СНЯТЬ джампер (CLKSWD=0) и
       перезагрузить. По желанию затем можно полностью отключить
       распознавание пина (снять чекбокс, nBOOT_SEL=1).

    📁 ПРОШИВКА:
       1. Скомпилируйте проект в Arduino IDE
       2. Файлы .bin или .hex появятся в папке _build_hex_bin
       3. Выберите папку с прошивками через кнопку ОБЗОР
       4. Выберите нужный файл из выпадающего списка
       5. Нажмите ПРОГРАММИРОВАТЬ ЧИП

    🔧 ОТДЕЛЬНЫЕ ФУНКЦИИ:
       • ОБНОВИТЬ   - прочитать текущие Option Bytes с чипа
       • ОПЦИИ      - записать только Option Bytes (без перезаписи flash)
       • РАЗБЛОКИРОВАТЬ ЧИП - снять защиту RDP Level 1 (массовое стирание)

    ⚠️ ВАЖНО:
       • Для STM32G031F8P6 в Arduino IDE: если не используете USART, можно
         отключить USART Support (экономит память и освобождает пины PA9/PA10)
       • RDP Level 2 НИКОГДА не устанавливайте! Это необратимо.
       • Перед программированием убедитесь, что чип не заблокирован RDP Level 1

    🔗 Ссылки:
       • STM32CubeProgrammer: https://www.st.com/en/development-tools/stm32cubeprog.html

    ═══════════════════════════════════════════════════════════════════════════
    )"
    
    helpGui := Gui("+Owner" myGui.Hwnd, "СПРАВКА")
    helpGui.SetFont("s9", "Consolas")
    
    editCtrl := helpGui.Add("Edit", "x10 y10 w580 h400 ReadOnly Multi HScroll VScroll", helpText)
    
    btnClose := helpGui.Add("Button", "w100 h30", "Закрыть")
    btnClose.OnEvent("Click", (*) => helpGui.Destroy())
    
    helpGui.Show("w600 h450")
}

; ============================================================================
; ЗАГРУЗКА КОНФИГУРАЦИИ ИЗ INI-ФАЙЛА
; ============================================================================
LoadConfig(&wX := "", &wY := "", &wW := "", &wH := "") {
    global CUBE, BIN_DIR
    if FileExist(INI_FILE) {
        CUBE := IniRead(INI_FILE, "Settings", "CubePath", CUBE)
        BIN_DIR := IniRead(INI_FILE, "Settings", "BinDir", "")
        edtCube.Value := CUBE
        edtBinDir.Value := BIN_DIR
        if (BIN_DIR != "" && DirExist(BIN_DIR))
            UpdateBinFilesList()
        
        wX := IniRead(INI_FILE, "Window", "X", "")
        wY := IniRead(INI_FILE, "Window", "Y", "")
        wW := IniRead(INI_FILE, "Window", "Width", "")
        wH := IniRead(INI_FILE, "Window", "Height", "")
    }
}

; ============================================================================
; СОХРАНЕНИЕ КОНФИГУРАЦИИ В INI-ФАЙЛ
; ============================================================================
SaveConfig() {
    try {
        IniWrite(CUBE, INI_FILE, "Settings", "CubePath")
        IniWrite(BIN_DIR, INI_FILE, "Settings", "BinDir")
        
        myGui.GetPos(&outX, &outY, &outW, &outH)
        
        if (outW > 200 && outH > 200) {
            IniWrite(outX, INI_FILE, "Window", "X")
            IniWrite(outY, INI_FILE, "Window", "Y")
            IniWrite(outW, INI_FILE, "Window", "Width")
            IniWrite(outH, INI_FILE, "Window", "Height")
        }
    } catch Error as err {
        logBox.Value .= "`r`n[ПРЕДУПРЕЖДЕНИЕ] Ошибка INI: " err.Message "`r`n"
    }
}

; ============================================================================
; ВЫПОЛНЕНИЕ КОМАНДЫ И ЗАХВАТ ВЫВОДА
; ============================================================================
RunCMD(CmdLine, WorkingDir := "") {
    Static P8 := (A_PtrSize=8)
    DllCall("CreatePipe", "Ptr*", &hPipeR:=0, "Ptr*", &hPipeW:=0, "Ptr", 0, "UInt", 0)
    DllCall("SetHandleInformation", "Ptr", hPipeW, "UInt", 1, "UInt", 1)
    PI := Buffer(P8 ? 24 : 16, 0), SI := Buffer(P8 ? 104 : 68, 0)
    NumPut("UInt", P8 ? 104 : 68, SI, 0), NumPut("UInt", 0x100, SI, P8 ? 60 : 44)
    NumPut("Ptr", hPipeW, SI, P8 ? 88 : 60), NumPut("Ptr", hPipeW, SI, P8 ? 96 : 64)
    if !DllCall("CreateProcess", "Ptr", 0, "Str", CmdLine, "Ptr", 0, "Ptr", 0, "Int", true, "UInt", 0x08000000, "Ptr", 0, "Ptr", WorkingDir ? StrPtr(WorkingDir) : 0, "Ptr", SI, "Ptr", PI)
        return (DllCall("CloseHandle", "Ptr", hPipeW), DllCall("CloseHandle", "Ptr", hPipeR), "")
    DllCall("CloseHandle", "Ptr", hPipeW), Text := "", B := Buffer(4096, 0)
    while DllCall("ReadFile", "Ptr", hPipeR, "Ptr", B, "UInt", 4096, "UInt*", &R:=0, "Ptr", 0)
        Text .= StrGet(B, R, "CP866")
    DllCall("CloseHandle", "Ptr", NumGet(PI, 0, "Ptr")), DllCall("CloseHandle", "Ptr", NumGet(PI, A_PtrSize, "Ptr")), DllCall("CloseHandle", "Ptr", hPipeR)
    return Text
}