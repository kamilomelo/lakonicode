# lakonicode

OpenCode agents, the Lakonic skill, and slash commands for the global user configuration.

```bash
./install.sh                   # install or update safely
./install.sh --dry-run         # preview; changes nothing
./install.sh --apply           # explicit form of the default
./install.sh --apply --replace # back up and replace conflicting files too
```

After publishing this repository to `github.com/kamilomelo/lakonicode`, you
can install without cloning it:

```bash
curl -fsSL https://raw.githubusercontent.com/kamilomelo/lakonicode/main/bootstrap.sh | bash
```

The bootstrap downloads the full repo archive (including the bundled kartouche
template) to a temporary directory, runs `install.sh`, and cleans up. It
defaults to `main`; set `LAKONICODE_REF` to a tag or commit for a specific
version. To preview instead, pass `--dry-run` with `bash -s`:

```bash
curl -fsSL https://raw.githubusercontent.com/kamilomelo/lakonicode/main/bootstrap.sh | bash -s -- --dry-run
```

Piping a downloaded script into Bash executes code from that URL immediately.
Only use this with a repository you trust; for an auditable install, download
and review `bootstrap.sh` before running it.

The installer targets `${XDG_CONFIG_HOME:-$HOME/.config}/opencode`. It manages only the
files in this repository's `AGENTS.md`, `agents/`, `skills/lakonic/`, and
`commands/`. It does not remove files or edit `opencode.jsonc`. It records
installed content in `.lakonicode-manifest.tsv` in the target directory. If a
managed file was edited locally, a normal install stops before making any
changes. Updates and explicit replacements create a `.bak.*` copy first.

The bundled `kartouche.sh` is a copy of
[kartouche](https://github.com/kamilomelo/kartouche) for offline installer
output; its license is in `KARTOUCHE-LICENSE`.

Lakonicode is licensed under the MIT License; see `LICENSE`.
