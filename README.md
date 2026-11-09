# Lakonicode

**A lean, repeatable OpenCode setup that favors the smallest complete solution.**

Lakonicode brings together a focused coding skill, dedicated Research and
Documentation agents, and commands for reviewing code without changing it. A
small installer makes them available across projects and keeps them current
after a Git pull, while protecting local edits and leaving the rest of your
OpenCode configuration alone. No plugin or `opencode.jsonc` changes are needed.

## Install or update

From this repository:

```bash
./install.sh
```

After a Git pull, run the same command again. To install without cloning:

```bash
curl -fsSL https://raw.githubusercontent.com/kamilomelo/lakonicode/main/bootstrap.sh | bash
```

The remote command downloads the repository archive to a temporary directory,
runs `install.sh`, then removes the temporary files. It fetches `main` by
default. To install assets from a specific tag or commit, set `LAKONICODE_REF`
for **Bash** (replace `main` below with your tag or commit):

```bash
curl -fsSL https://raw.githubusercontent.com/kamilomelo/lakonicode/main/bootstrap.sh | LAKONICODE_REF=main bash
```

The bootstrap script itself still comes from `main` in that example. Piping a
script into Bash executes remote code immediately: use only a source you trust,
or download and inspect `bootstrap.sh` before running it.

## What gets installed

Files go to `${XDG_CONFIG_HOME:-$HOME/.config}/opencode/`:

| File | Purpose |
| --- | --- |
| `AGENTS.md` | Ask agents to use Lakonic by default for coding tasks. |
| `agents/research.md` | Primary agent for technical investigation. |
| `agents/document.md` | Primary agent for documentation. |
| `skills/lakonic/SKILL.md` | Smallest complete change, without unnecessary dependencies or behavior changes. |
| `commands/lakonic.md` | `/lakonic on` or `/lakonic off` in the current conversation. |
| `commands/lakonic-review.md` | `/lakonic-review` checks current changes for safe simplifications. |
| `commands/lakonic-audit.md` | `/lakonic-audit` looks for worthwhile simplifications across a repository. |

The on/off command is a **conversation instruction**, not a persistent OpenCode
setting. The review and audit commands report findings; they do not edit files.

## Preview and conflict handling

```bash
./install.sh --dry-run         # preview without writing files
./install.sh --apply           # explicit form of the default ./install.sh
./install.sh --apply --replace # back up and replace conflicting files
```

The installer records managed file hashes in
`~/.config/opencode/.lakonicode-manifest.tsv` (or the equivalent XDG config
directory). Identical existing files are adopted without being overwritten.
When the repo version changes and the installed file still matches the last
installation, a normal run backs up the old file and updates it.

If a target is unowned and different, or you edited a managed target locally,
a normal run reports a conflict and makes **no changes**. Inspect it before
choosing `--apply --replace`. Symlink and non-file targets are refused even
with `--replace`.

Backups are placed beside replaced files with a `.bak.*` suffix. The installer
never removes files and leaves unrelated OpenCode settings, plugins, and
`opencode.jsonc` alone. It only installs the paths listed in `install.sh`;
adding a new file to the repo does not automatically add it to the installer.

The local installer needs Bash, `sha256sum` (GNU coreutils), `curl`, and network
access. It downloads and executes its terminal-output template from an external
repository on each run, including previews. The remote bootstrap also needs
`tar`.

## Licenses

Lakonicode is MIT-licensed; see [LICENSE](LICENSE).
