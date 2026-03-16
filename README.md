# cipherowl-sr3

Public CLI for CipherOwl blockchain address screening, risk analysis, and compliance tooling.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/cipherowl-ai/cipherowl-sr3/main/scripts/install-sr3.sh | sh
```

Installs to `~/.local/bin/` and adds it to your PATH automatically.

## Quick Start

```bash
cipherowl-sr3 login                    # authenticate via browser
cipherowl-sr3 doctor                   # verify connectivity
cipherowl-sr3 screen <address>         # screen an address for risk
cipherowl-sr3 reason breakdown <addr>  # risk breakdown by type
cipherowl-sr3 metadata labels <addr>   # address labels/tags
cipherowl-sr3 detect <address>         # detect chain (no auth needed)
cipherowl-sr3 --help                   # see all commands
```

## What it does

| Category | Commands | Description |
|----------|----------|-------------|
| **Screening** | `screen`, `batch-screen` | Check addresses against sanctions/risk profiles |
| **Risk Analysis** | `reason risk/detail/breakdown/exposures` | Structured risk data for agent decisions |
| **Metadata** | `metadata labels/entities`, `batch-labels/batch-entities` | Address enrichment (labels, entities) |
| **Reports** | `report risk-assessment/graph/sar` | Human-readable compliance reports |
| **AI** | `explain-tx`, `label`, `label-source` | LLM-powered transaction explanations, evidence classification |
| **Discovery** | `detect`, `capabilities` | Chain detection, supported chains |

Supports 12 chains: EVM, Tron, Bitcoin, Litecoin, Bitcoin Cash, Dash, Dogecoin, XRP, Solana, TON, Zcash.

## Agent Integration

The CLI is designed for AI agent consumption: JSON output by default, structured error codes, `--agent-info` for full machine-readable documentation.

```bash
cipherowl-sr3 --agent-info    # full guide with schemas, examples, and expected output
```

### Generate a skill for your AI coding agent

Give your agent this prompt:

```
cipherowl-sr3 --help
cipherowl-sr3 --agent-info

Create a skill/tool integration from this CLI's capabilities.
```

Works with **Claude Code**, **Codex**, **OpenClaw**, or any agent that can run shell commands.

## Authentication

Three modes (checked in order):

1. **Login session** — `cipherowl-sr3 login` (recommended for interactive use)
2. **Static token** — `CO_TOKEN=<jwt>` (for scripting/CI)
3. **OAuth2 M2M** — `CIPHEROWL_CLIENT_ID` + `CIPHEROWL_CLIENT_SECRET`

---

Source code is in the [CipherOwl monorepo](https://github.com/cipherowl-ai/monorepo) (private). This repo hosts release binaries only.
