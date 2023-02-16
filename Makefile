all: editor.c
	clang -std=c17 -Os editor.c -o editor
