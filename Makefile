all: lint test

lint:
	@echo "Linting..."
	luacheck --no-color .
	@echo

unit:
	@echo "Run unit tests..."
	nvim --headless --noplugin -c 'packadd plenary.nvim' -c "PlenaryBustedDirectory lua/spec"
	@echo

integration:
	@echo "Run integration tests..."
	nvim --headless -c "PlenaryBustedDirectory tests"
	@echo

test: unit integration
