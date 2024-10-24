#NoEnv
#SingleInstance, Force
#Persistent
#InstallKeybdHook
#UseHook
#KeyHistory, 0
CoordMode, Pixel, Screen, RGB
CoordMode, Mouse, Screen
#NoTrayIcon


; PID do processo atual
PID := DllCall("GetCurrentProcessId")
Process, Priority, %PID%, High

#include Lib\AutoHotInterception.ahk
global AHI := new AutoHotInterception

; Caminho do arquivo config.ini
configFilePath := "C:\Users\User\Desktop\n3sk\config.ini"

; Função para criar o arquivo config.ini com valores padrão se ele não existir
CreateConfigFile() {
    global configFilePath
    if !FileExist(configFilePath) {
        FileAppend, [Settings]nEmCol=0xd721cdnSmooth=0.5nCfovX=100nCfovY=100nColVn=50nScreenWidth=0nScreenHeight=0n, %configFilePath%
    }
}

; Função para carregar a configuração do arquivo
LoadConfig() {
    global Smooth, CfovX, CfovY, ColVn, ScreenWidth, ScreenHeight, configFilePath
    CreateConfigFile()  ; Garante que o arquivo existe

    ; Carrega os valores das configurações
    IniRead, Smooth, %configFilePath%, Settings, Smooth, 0.0
    IniRead, CfovX, %configFilePath%, Settings, CfovX, 0
    IniRead, CfovY, %configFilePath%, Settings, CfovY, 0
    IniRead, ColVn, %configFilePath%, Settings, ColVn, 0
    IniRead, ScreenWidth, %configFilePath%, Settings, ScreenWidth, A_ScreenWidth
    IniRead, ScreenHeight, %configFilePath%, Settings, ScreenHeight, A_ScreenHeight
}

; Função para salvar a configuração no arquivo
SaveConfig() {
    global Smooth, CfovX, CfovY, ColVn, ScreenWidth, ScreenHeight, configFilePath
    IniWrite, %Smooth%, %configFilePath%, Settings, Smooth
    IniWrite, %CfovX%, %configFilePath%, Settings, CfovX
    IniWrite, %CfovY%, %configFilePath%, Settings, CfovY
    IniWrite, %ColVn%, %configFilePath%, Settings, ColVn
    IniWrite, %ScreenWidth%, %configFilePath%, Settings, ScreenWidth
    IniWrite, %ScreenHeight%, %configFilePath%, Settings, ScreenHeight
}

; Carrega as configurações
LoadConfig()

; Atualiza as variáveis com base nas configurações
EMCol := 0xd721cd
ZeroX := ScreenWidth / 2  ; Centro da tela
ZeroY := ScreenHeight / 2.20  ; Mira no peito
ScanL := ZeroX - CfovX
ScanT := ZeroY - CfovY
ScanR := ZeroX + CfovX
ScanB := ZeroY + CfovY

targetX := 0
targetY := 0
ForceValue := 0.5 ; Ajuste o valor da força para calibrar o movimento do mouse

paused := false ; 

Loop
{
    if paused
    {
        Sleep, 100
        continue
    }

    targetFound := False

    if GetKeyState("LButton", "P") or GetKeyState("RButton", "P") {
        ; Busca por pixel-alvo em uma região menor ao redor da última posição conhecida
        PixelSearch, AimPixelX, AimPixelY, targetX-20, targetY-20, targetX+20, targetY+20, EMCol, ColVn, Fast RGB
        if (!ErrorLevel) {
            targetX := AimPixelX
            targetY := AimPixelY
            targetFound := True
        } else {
            PixelSearch, AimPixelX, AimPixelY, ScanL, ScanT, ScanR, ScanB, EMCol, ColVn, Fast RGB
            if (!ErrorLevel) {
                targetX := AimPixelX
                targetY := AimPixelY
                targetFound := True
            }
        }

        if (targetFound) {
            AimX := targetX - ZeroX
            AimY := 0 ; Pode ser ajustado para movimentos verticais
            
            ; Usa a Interception para mover o mouse
            if (Abs(AimX) > 1) { ; Evita movimentos muito pequenos
                AHI.SendMouseMove(11, Round(AimX * Smooth), AimY)
                AHI.SendMouseMove(12, Round(AimX * Smooth), AimY)
                AHI.SendMouseMove(13, Round(AimX * Smooth), AimY)
                AHI.SendMouseMove(14, Round(AimX * Smooth), AimY)
                AHI.SendMouseMove(15, Round(AimX * Smooth), AimY)
                AHI.SendMouseMove(16, Round(AimX * Smooth), AimY)
                AHI.SendMouseMove(17, Round(AimX * Smooth), AimY)
                AHI.SendMouseMove(18, Round(AimX * Smooth), AimY)
                AHI.SendMouseMove(19, Round(AimX * Smooth), AimY)
                AHI.SendMouseMove(20, Round(AimX * Smooth), AimY)
            }
        }
    }
    Sleep, 10
}

scrollClicked := false

~LButton::
    if (GetKeyState("RButton")) {
        Click, Middle  ; Clica no scroll do mouse
        scrollClicked := true
    }
    return

~LButton Up::
    if (scrollClicked) {
        ; Se o scroll foi clicado anteriormente, marque-o como falso agora
        scrollClicked := false
    }
    return

; Definindo a ação quando a tecla Z é pressionada
Z:: 
    SendInput, m  ; Envia a letra M
    Sleep, 150 ; Aguarda 150 milissegundos
    MouseMove, % ScreenWidth // 2, % ScreenHeight // 2  ; Move o mouse para o centro da tela
    Click right  ; Clica com o botão direito do mouse
    Sleep, 50  ; Aguarda 50 milissegundos
    Send, {Esc}  ; Envia a tecla Esc
Return

Insert::
    paused := !paused
Return

OnExit:
    SaveConfig()  ; Salva as configurações ao sair
    ExitApp
Return
