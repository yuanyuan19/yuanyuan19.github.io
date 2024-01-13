.DEFAULT_GOAL := all
.PHONY: all
all: 	run

.PHONY: run
run:
	@docsify serve docs

.PHONY: push
push:
	@echo "push ..."
	@git add .
	@git commit -m "update"
	@git push
