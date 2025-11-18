# PowerShell 脚本：在指定 Python 环境中尝试修复 numpy 权限并安装 TensorFlow + requirements
# 使用前请先保存工作并关闭 VSCode/Jupyter 等会占用 Python 的程序。
# 运行方式（建议以管理员身份运行）：
#   cd D:\PROGRAMMING\Multimedia
#   .\setup_env_using_base.ps1

$python = 'D:\PROGRAMMING\.conda\python.exe'
$requirements = 'd:\PROGRAMMING\Multimedia\a5-ImageCaptioningwithLSTM\requirements.txt'

Write-Host "Using Python: $python"
Write-Host "Stopping common Python processes (if running)..."
Get-Process -Name python,jupyter,ipykernel -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2

Write-Host "Uninstalling numpy (if present)..."
& $python -m pip uninstall -y numpy 2>&1 | ForEach-Object { Write-Host $_ }

Write-Host "Detecting site-packages path from Python..."
try {
    $raw = & $python -c 'import site,sys; print(site.getsitepackages()[0])' 2>&1
    if ($raw) { $site = ($raw -join '') -replace "\r|\n", '' } else { $site = $null }
} catch {
    $site = $null
}
if (-not $site) { $site = 'D:\PROGRAMMING\.conda\Lib\site-packages' }
Write-Host "site-packages: $site"

Write-Host "Removing suspicious temporary/invalid distributions (patterns: ~umpy, ~linker)..."
Get-ChildItem -Path $site -Filter "*~umpy*" -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "Removing: $($_.FullName)"; Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue }
Get-ChildItem -Path $site -Filter "*~linker*" -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "Removing: $($_.FullName)"; Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 1

Write-Host "Reinstalling numpy 1.23.5 (force-reinstall)..."
& $python -m pip install --no-cache-dir --upgrade --force-reinstall numpy==1.23.5 2>&1 | ForEach-Object { Write-Host $_ }

Write-Host "Installing TensorFlow CPU 2.15.0 (this may take several minutes)..."
& $python -m pip install --no-cache-dir tensorflow-cpu==2.15.0 2>&1 | ForEach-Object { Write-Host $_ }

Write-Host "Installing remaining requirements (if file exists): $requirements"
if (Test-Path $requirements) {
    & $python -m pip install --no-cache-dir -r $requirements 2>&1 | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "Requirements file not found: $requirements"
}

Write-Host "Done. Verify installation by running:"
Write-Host "  $python -c 'import tensorflow as tf; print(\"tensorflow\", tf.__version__)'"
Write-Host "If you still see WinError 5 (Access denied):"
Write-Host "  - Try running this script as Administrator, or"
Write-Host "  - Reboot the machine to release any locked .pyd files, then rerun the script."

Write-Host "Script finished."
