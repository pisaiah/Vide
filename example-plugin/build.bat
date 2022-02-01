v -skip-unused -d no_backtrace -o library -shared library.v
REM Compress with upx (~1.4mb to 400kb)
upx library.dll