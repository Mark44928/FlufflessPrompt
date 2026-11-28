#!/data/data/com.termux/files/usr/bin/env python3
"""Fluffless Prompt preview — render a sample of the prompt.

Shows what the prompt looks like (directory, Git state, exit code, clock).
No dependencies.

Usage:
    python3 preview.py            # sample prompt
    python3 preview.py --no-color # plain text
"""

import os
import sys

GREEN = "\033[92m"
BLUE = "\033[94m"
DIM = "\033[2m"
RED = "\033[91m"
RESET = "\033[0m"


def c(text, code, use_color):
    return code + text + RESET if use_color else text


def main(argv):
    use_color = "--no-color" not in argv and sys.stdout.isatty()
    cwd = os.path.basename(os.getcwd()) or "~"
    branch = "main"
    clock = "09:41"
    line1 = c(cwd, GREEN, use_color) + c(f"  {branch}", DIM, use_color)
    line2 = c("❯", GREEN, use_color) + " "
    rclock = c(clock, DIM, use_color)
    print(line1)
    print(line2 + rclock)


if __name__ == "__main__":
    main(sys.argv[1:])