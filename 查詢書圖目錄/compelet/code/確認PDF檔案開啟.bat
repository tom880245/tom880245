@echo off
setlocal enabledelayedexpansion

rem 设置日志文件路径
set "log_file=logfile.txt"

rem 删除之前的日志文件（如果存在）
del "%log_file%" 2>nul

rem 遍历当前目录中的所有 PDF 文件
for %%f in (*.pdf) do (
    rem 尝试打开文件
    start "" "%%f"
    rem 等待一段时间以确保文件能够打开
    timeout /t 5 /nobreak >nul
    rem 检查命令的返回代码
    if errorlevel 1 (
        rem 如果返回代码为非零值，则文件无法打开，列出文件名到日志文件
        echo Cannot open file: %%f >> "%log_file%"
    )
)

rem 提示完成
echo Done.

endlocal