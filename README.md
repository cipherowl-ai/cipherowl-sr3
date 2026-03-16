# cipherowl-sr3

Public CLI for CipherOwl blockchain address screening, risk analysis, and compliance tooling.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/cipherowl-ai/cipherowl-sr3/main/scripts/install-sr3.sh | sh
```

Installs to `~/.local/bin/` and adds it to your PATH automatically.

## Usage

```bash
cipherowl-sr3 login              # authenticate via browser
cipherowl-sr3 screen <address>   # screen an address for risk
cipherowl-sr3 --help             # see all commands
```

## Generate a skill for Claude Code

```bash
claude -p "$($HOME/.local/bin/cipherowl-sr3 --agent-info)

/skill-creator create a skill from this --agent-info output"
```

---

Source code is in the [CipherOwl monorepo](https://github.com/cipherowl-ai/monorepo) (private). This repo hosts release binaries only.
