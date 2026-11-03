@echo off
rem ============================================================
rem  Central de Automacoes CR2
rem
rem  Dois cliques aqui abre a janela.
rem
rem  A janela nova e em Qt (src\app_qt.py, precisa do PySide6).
rem  Sem o PySide6, este arquivo o instala UMA vez (uns 200 MB) e
rem  abre a janela nova. Se nao der (sem internet, pip quebrado),
rem  abre a janela em Tkinter (src\app.py), que faz exatamente o
rem  mesmo - a Central nunca deixa de abrir por falta de
rem  biblioteca - e deixa uma marca para nao tentar de novo a cada
rem  abertura: %LOCALAPPDATA%\CR2\central\pyside6-falhou.txt. A
rem  marca vale um dia; apagada, ou no dia seguinte, tenta de novo.
rem  O INSTALAR.bat tambem instala o PySide6.
rem
rem  Nao usamos o dist\Central CR2.exe aqui de proposito: o .exe e
rem  uma copia congelada, e o "Atualizar a Central" atualiza o
rem  codigo do git, nao o .exe - ele continuaria na versao velha.
rem
rem  Este arquivo precisa ficar em ASCII com quebra CRLF:
rem  o cmd.exe nao le .bat com quebra de linha LF.
rem ============================================================
title Central CR2
cd /d "%~dp0"

rem O lancador `py` acha a instalacao real do Python. Um `python`
rem solto no PATH pode ser o embutido de outro programa (o do
rem LibreOffice, por exemplo, nao tem Tkinter e a janela nao abre).
set "PY="
where py >nul 2>&1 && set "PY=py -3"
if not defined PY (
    where python >nul 2>&1 && set "PY=python"
)
if not defined PY goto :sem_python

rem `pyw` abre sem o console preto atras da janela
set "PYW=%PY%"
where pyw >nul 2>&1 && set "PYW=pyw -3"

%PY% -c "import PySide6" >nul 2>&1
if not errorlevel 1 goto :abrir_qt

set "MARCA=%LOCALAPPDATA%\CR2\central\pyside6-falhou.txt"
rem `forfiles /d 0` acha a marca so se ela e de hoje: de ontem para
rem tras, tenta de novo
if exist "%MARCA%" forfiles /p "%LOCALAPPDATA%\CR2\central" /m pyside6-falhou.txt /d 0 >nul 2>&1 && goto :abrir_tk
echo.
echo   Instalando a janela nova da Central (PySide6), so desta vez.
echo   Sao uns 200 MB: leva alguns minutos. Nao feche esta janela.
echo.
%PY% -m pip install --disable-pip-version-check --quiet "PySide6>=6.8"
%PY% -c "import PySide6" >nul 2>&1
if not errorlevel 1 (
    if exist "%MARCA%" del "%MARCA%" >nul 2>&1
    goto :abrir_qt
)
if not exist "%LOCALAPPDATA%\CR2\central" md "%LOCALAPPDATA%\CR2\central"
>"%MARCA%" echo pip install PySide6 falhou em %DATE% %TIME%
echo.
echo   Nao deu para instalar agora. Abrindo a janela antiga; amanha
echo   a Central tenta de novo.
timeout /t 4 >nul
goto :abrir_tk

:abrir_qt
start "" %PYW% "src\app_qt.py" %*
exit /b 0

:abrir_tk

%PY% -c "import tkinter" >nul 2>&1
if errorlevel 1 goto :sem_tk
start "" %PYW% "src\app.py" %*
exit /b 0

:sem_python
echo.
echo   Python nao encontrado.
echo   Instale em https://www.python.org/downloads/ marcando
echo   "Add python.exe to PATH" e rode este arquivo de novo.
echo.
pause
exit /b 1

:sem_tk
echo.
echo   Este Python nao tem Tkinter, entao a janela nao abre.
echo   Reinstale o Python marcando "tcl/tk and IDLE".
echo.
pause
exit /b 1
