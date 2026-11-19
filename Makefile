.PHONY: check test

check:
	python3 ./tests/check_theme.py

test: check
