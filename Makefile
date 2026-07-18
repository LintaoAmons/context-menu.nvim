.PHONY: test fmt

test:
	nvim --headless -l tests/run.lua

fmt:
	stylua lua/ plugin/ tests/
