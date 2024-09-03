cd rusty
cargo clean
set mode=%1
if /I '%mode%'=='release' goto :release
cargo build
goto :exit

:release
cargo build --release

:exit
cd ..