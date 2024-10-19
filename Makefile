C3_FILES := arctan.c3 ray.c3 lighting.c3
OUTPUT := lighting
C3C_FLAGS := -D PLATFORM_WEB --reloc=none --target wasm32 -O5 -g0 --link-libc=no --no-entry -z --export-table

build:
	c3c compile $(C3C_FLAGS) -o $(OUTPUT) $(C3_FILES)

dev:
	serve . & find . -name '*.c3' | entr -r make build

.PHONY: build dev
