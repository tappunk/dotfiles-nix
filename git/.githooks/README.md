# Global Git Hooks

This directory is configured as your global hooks path via dotfiles:

```bash
git config --global core.hooksPath ~/.githooks
```

## commit-msg

`commit-msg` enforces Conventional Commit subject format for non-merge commits:

- format: `type(scope)?: subject`
- allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
- subject starts lowercase and is max 72 chars
- subject must not end with `.`
- allows `!` for breaking changes, e.g. `feat(api)!: change response schema`

Exemptions:

- merge commits
- `Revert ...`
- `fixup! ...`
- `squash! ...`

If needed, bypass once with:

```bash
git commit --no-verify
```
