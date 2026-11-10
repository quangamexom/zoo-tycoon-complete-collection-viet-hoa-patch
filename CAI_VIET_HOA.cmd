@echo off
setlocal
cd /d "%~dp0"
if not exist "zoo.exe" (
    echo Khong tim thay zoo.exe trong thu muc nay.
    echo Hay chep NOI DUNG goi patch vao thu muc game, roi mo lai file nay.
    pause
    exit /b 1
)
if not exist "Install-VietHoa.ps1" (
    echo Thieu Install-VietHoa.ps1. Hay giai nen lai toan bo goi patch.
    pause
    exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-VietHoa.ps1" -GameDir "%~dp0"
set "install_result=%errorlevel%"
if not "%install_result%"=="0" (
    echo.
    echo Cai dat chua hoan tat. Xem loi phia tren.
    echo File game goc duoc giu nguyen neu kiem tra phien ban khong dat.
    pause
    exit /b %install_result%
)
echo.
echo Cai dat hoan tat. Mo "Zoo Tycoon Viet Hoa.cmd" de choi.
pause
exit /b 0
