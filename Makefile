all: lint test

lint:
	@echo "Linting..."
	luacheck --no-color .
	@echo

test:
	@echo "Run tests..."
	busted -m "./lua/?.lua;./lua/?/?.lua;./lua/?/init.lua" lua
	@echo
