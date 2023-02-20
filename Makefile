all: editor.w
	cweave editor
	luatex editor
	ctangle editor
	clang -std=c17 -Os editor.c -o editor

see: all
	open editor.pdf

third: build/third.c
	clang -std=c17 -Os build/third.c -o build/third
