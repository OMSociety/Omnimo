@echo off

:: Set to pack to use UPX compression
set upx=nopack

:: Set to /x64 to build for 64-bit
set x64=

:: AutoIt3Wrapper directory (detect the OS bitness from the environment; the old
:: WMI command-line tool it used is deprecated and absent on recent Windows 11)
:: On 64-bit Windows this cmd is either native (PROCESSOR_ARCHITECTURE=AMD64/ARM64)
:: or a 32-bit process under WOW64 (PROCESSOR_ARCHITEW6432 set); AutoIt3 then lives
:: under Program Files (x86). Otherwise it is 32-bit Windows, under Program Files.
if defined PROCESSOR_ARCHITEW6432 (
	set "autwrapperdir=%PROGRAMFILES(X86)%\AutoIt3\SciTE\AutoIt3Wrapper"
) else if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	set "autwrapperdir=%PROGRAMFILES(X86)%\AutoIt3\SciTE\AutoIt3Wrapper"
) else if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
	set "autwrapperdir=%PROGRAMFILES(X86)%\AutoIt3\SciTE\AutoIt3Wrapper"
) else (
	set "autwrapperdir=%PROGRAMFILES%\AutoIt3\SciTE\AutoIt3Wrapper"
)

:: Build scripts
echo Building AutoIT extensions...
FOR %%G IN (*.au3) DO "%autwrapperdir%\AutoIt3Wrapper.exe" /in %%G /%upx% %x64%

echo All done!
exit