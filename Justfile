set quiet

alias br := build-release

# build and run executable
[group("debug")]
[default]
run: build-debug
    ./mint

# build debug binary with vet flag
[group("debug")]
build-debug:
    odin build . -build-mode:exe -vet -warnings-as-errors -o:size

# build release binary
[group("release")]
build-release:
    odin build . -build-mode:exe -o:aggressive