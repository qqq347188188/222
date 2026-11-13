# 一键上传到 GitHub
# 用法：先把下面 $REPO_URL 改成你的空仓库地址，然后右键本文件 →「使用 PowerShell 运行」
$REPO_URL = "https://github.com/你的用户名/你的仓库.git"

Set-Location -LiteralPath $PSScriptRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "未检测到 git，请先安装：https://git-scm.com/download/win" -ForegroundColor Red
    Read-Host "按回车退出"
    exit 1
}
if ($REPO_URL -like "*你的用户名*") {
    Write-Host "请先用记事本打开本脚本，把 `$REPO_URL 改成你的仓库地址" -ForegroundColor Yellow
    Read-Host "按回车退出"
    exit 1
}

Write-Host "==> 初始化并提交"
if (-not (Test-Path ".git")) { git init }
git add -A
git commit -m "GMInject dylib" 2>$null
git branch -M main

Write-Host "==> 设置远程仓库"
git remote remove origin 2>$null
git remote add origin $REPO_URL

Write-Host "==> 推送（首次会要求登录 GitHub）"
git push -u origin main

Write-Host "完成！去 GitHub → Actions → build-dylib → Run workflow（runner 选 macos-13）" -ForegroundColor Green
Read-Host "按回车退出"
