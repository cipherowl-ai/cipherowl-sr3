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

## Generate a skill for your AI coding agent

Give your agent this prompt:

```
cipherowl-sr3 --help
cipherowl-sr3 --agent-info

Create a skill/tool integration from this CLI's capabilities.
```

This works with **Claude Code**, **Codex**, **OpenClaw**, or any agent that can run shell commands.

---

Source code is in the [CipherOwl monorepo](https://github.com/cipherowl-ai/monorepo) (private). This repo hosts release binaries only.
