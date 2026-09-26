@echo off
REM PUDUU one-click runner - double-click file ini, atau jalankan via Git Bash: ./RUN.bat
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo [PUDUU] flutter tidak ketemu di PATH.
  echo [PUDUU] Install Flutter SDK dulu: https://docs.flutter.dev/get-started/install/windows
  echo [PUDUU] Lalu tambahkan folder flutter\bin ke PATH, tutup-buka terminal, coba lagi.
  pause
  exit /b 1
)
if not exist .env (
  echo [PUDUU] .env tidak ada - app jalan LOCAL-ONLY tanpa cloud sync (tetap full fungsi).
  echo [PUDUU] Mau sync antar-HP? Copy .env.example jadi .env lalu isi 2 kunci Supabase.
  echo.
)
flutter pub get
if errorlevel 1 (
  echo [PUDUU] flutter pub get gagal. Cek koneksi internet lalu coba lagi.
  pause
  exit /b 1
)
flutter run
pause
