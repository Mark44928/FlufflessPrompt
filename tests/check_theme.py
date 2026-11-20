#!/data/data/com.termux/files/usr/bin/env python3
"""Smoke checks for fluffless.zsh-theme."""
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
THEME = ROOT / "fluffless.zsh-theme"


def zsh(code: str, cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["zsh", "-df", "-c", code],
        cwd=cwd or ROOT,
        env=os.environ | {"TERM": "xterm-256color"},
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    )


def main() -> int:
    zsh(f"zsh -n {THEME}")

    with tempfile.TemporaryDirectory() as tmp:
        repo = Path(tmp) / "repo"
        repo.mkdir()
        zsh("git init -b main >/dev/null 2>&1", cwd=repo)
        zsh("git config user.email test@example.com && git config user.name Test", cwd=repo)
        (repo / "tracked").write_text("clean\n")
        zsh("git add tracked && git commit -m init >/dev/null", cwd=repo)

        out = zsh(
            f'source "{THEME}"; _fluffless_prompt_precmd; print -P -- "${{(%%)PROMPT}}\\n${{(%%)RPROMPT}}"',
            cwd=repo,
        ).stdout

        assert "main" in out, out
        assert "❯" in out, out
        assert __import__("re").search(r"\d{2}:\d{2}", out), out
        assert "repo" in out, out

        quiet = zsh(
            f'FLUFFLESS_SHOW_CLOCK=0; FLUFFLESS_SHOW_GIT=0; source "{THEME}"; '
            '_fluffless_prompt_precmd; print -P -- "${(%)PROMPT}\\n${(%)RPROMPT}"',
            cwd=repo,
        ).stdout
        assert "❯" in quiet, quiet
        assert "main" not in quiet, quiet
        assert not __import__("re").search(r"\d{2}:\d{2}", quiet), quiet

    print("fluffless theme check OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
