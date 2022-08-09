all: lint test

lint:
	@echo "Linting..."
	luacheck --no-color .
	@echo

unit:
	@echo "Run unit tests..."
	nvim --headless --noplugin -c 'packadd plenary.nvim' -c "PlenaryBustedDirectory lua/spec"
	@echo

gh-integration:
	@echo "Run integration tests..."
	nvim --headless --noplugin -u tests/minimal_init.vim  -c "PlenaryBustedDirectory tests  { minimal_init = './tests/minimal_init.vim' }"
	@echo

integration:
	@echo "Run integration tests..."
	nvim --headless --noplugin -c 'packadd plenary.nvim' -c "PlenaryBustedDirectory tests"
	@echo

test: unit integration
