.PHONY: all run push
all: 	run
run:
	@echo "run ..."
	@docsify serve docs


push:
	@echo "push ..."
	@git add .
	@git commit -m "修改"
	@git push
