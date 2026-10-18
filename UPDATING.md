# UPDATING.md — Auditing a plugin against `template.nvim`

`template.nvim` is a **model of the ideal plugin**: its layout, tooling, and
conventions are the standard to meet. Expect your plugin to differ in name, structure,
and scope — your job is to determine _how_ it differs from the model, decide
which differences are gaps worth closing, and close them.

- **the model** — this repo (`elanmed/template.nvim`).
- **your plugin** — the repo this file has been copied into.

## 1. Get the model for reference (read-only)

```sh
git clone --depth 1 https://github.com/elanmed/template.nvim /tmp/template.nvim
```

Read from it; never merge from it. There is no shared history and no shared
naming, so `git diff`/`git merge` against the model are meaningless.

## 2. Determine how your plugin differs

Work through the model component by component. For each row, find your
plugin's counterpart (or note that it has none):

| Model component                         | What it provides                                           | Where to look in your plugin     |
| --------------------------------------- | ---------------------------------------------------------- | -------------------------------- |
| `lua/template/init.lua`                 | Module entrypoint with `setup()`                           | `lua/<name>/init.lua`            |
| `plugin/template.lua`                   | Eager-load entry that calls `setup()`                      | `plugin/<name>.lua`              |
| `tests/test_e2e.lua`                    | mini.test suite driving a child Neovim                     | `tests/`                         |
| `scripts/minimal_init.lua`              | Deterministic test init (rtp + mini.test)                  | wherever tests bootstrap         |
| `Makefile`                              | `test`, `lint`, `format`, `docs`, `dev`, `clean`, `deploy` | Makefile / task runner           |
| `stylua.toml`, `.styluaignore`          | Formatting config                                          | repo root                        |
| `scripts/pre-push` + `install_hooks.sh` | Runs all checks on push of master                          | hooks / CI config                |
| `deps/*` (git submodules)               | Pinned dev-only deps: mini.test, ts-vimdoc.nvim            | deps/, CI, plugin manager config |
| `make docs` → `doc/template.txt`        | Help docs generated from `README.md` via ts-vimdoc         | doc generation                   |
| `PRINCIPLES.md`                         | Written-down design conventions                            | any equivalent doc               |
| `.gitignore` (`tags`, `!doc/tags`)      | Generated files kept out, help tags kept in                | `.gitignore`                     |

For each component, classify the difference as one of:

1. **Equivalent** — same job done, differently named. Nothing to do.
2. **Divergent** — your plugin does the job, but worse or inconsistently.
   Usually adopt the model's approach.
3. **Missing** — your plugin has no counterpart. Usually adopt.
4. **Essentially different** — divergence is a deliberate design decision of
   your plugin. Keep it, and record the reason in your plugin's equivalent of
   `PRINCIPLES.md`.

When judging divergence, compare against the _principle_, not the mechanism.
The model's principles are:

- Expose window/buffer handles to users via `User` autocmd events with `data`.
- Configuration via global `vim.g.<prefix>.*` variables; function-only options
  stay in function arguments.
- Module-local state lives in locals at the top scope.

A different mechanism can still satisfy a principle — keep it and say why.

## 3. What typically needs updating

- **Quality gates**: a `deploy`-style target that runs test + lint + format +
  docs, enforced on push (hook or CI). This is the model's backbone.
- **Testing**: mini.test with a child Neovim process, a deterministic
  `minimal_init`, tests under `tests/`.
- **Format config**: `stylua.toml` with `.styluaignore` covering deps.
- **Docs pipeline**: help file generated from `README.md` (ts-vimdoc), with
  generated `tags` ignored but `doc/tags` committed.
- **Dependency hygiene**: dev-only deps as pinned git submodules, never mixed
  into runtime files.
- **Conventions doc**: a `PRINCIPLES.md` capturing your plugin's decisions.

Skip from the model: the stub feature code (`setup()` is intentionally empty),
the `template` naming, `LICENSE`, and README prose. The model demonstrates
_shape_, not features.

Remove from your plugin: stale `.editorconfig` and `.luarc.json` files at the
repo root — plugins frequently carry them, but neither should be necessary
(`stylua.toml` handles formatting; keep the lint gate configured without
a checked-in `.luarc.json`). Delete them (leave vendored `deps/` untouched).

## 4. How to update

1. Create a branch, e.g. `align-with-template`.
2. For each adopted component, port the **pattern**, not the file: copy the
   model's file, then rename/trim to your plugin's name and layout. Typical
   rename points: module paths, the `pack/dev/start/<name>.nvim` stow target in
   `make dev`, the `doc/<name>.txt` output and help tag in `make docs`, and
   `require("<name>").setup()` in tests and `plugin/<name>.lua`.
3. Wire everything into the single `deploy` target so nothing is optional.
4. Regenerate artifacts and run the full gate:
   ```sh
   make test lint format docs
   ```
5. Record every class-4 decision (kept divergence) in your plugin's
   `PRINCIPLES.md` so the next audit doesn't relitigate it.
6. Commit. If your plugin uses the pre-push hook pattern, install it
   (`scripts/install_hooks.sh` equivalent) and let it enforce the gate.

## 5. Verification checklist

- [ ] `make deploy` (or your plugin's single gate) passes
- [ ] Every row of the section-2 table has an explicit classification with a
      one-sentence justification
- [ ] No `.editorconfig` or `.luarc.json` at the repo root
- [ ] Help docs generate under your plugin's name and `:h <name>` resolves
- [ ] Lint and format run clean with zero manual formatting
- [ ] Tests run in a child Neovim from a clean clone
- [ ] Kept divergences are documented in your plugin's principles doc
