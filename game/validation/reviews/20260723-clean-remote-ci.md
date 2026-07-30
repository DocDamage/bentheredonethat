# CI-REMOTE-01 — First clean-checkout remote pass

- State: Verified remote automation; release acceptance pending
- Milestone: Phase 0 / 5.3 — Authoritative CI evidence
- Tested commit SHA: `396571dba587f4176b04d62c80d738e26c2aadf4`
- Draft pull request: `#1` (`codex/ffvi-alignment-foundation`)
- Workflow run: `30003047658`
- Workflow URL: `https://github.com/DocDamage/bentheredonethat/actions/runs/30003047658`
- Implementer: Codex

## Result

The first clean GitHub Actions workflow pass completed on July 23, 2026.

- Browser checks: `npm run check` passed all 16 tests.
- Clean-checkout asset contract: `npm run validate:runtime-assets` passed.
- Godot: all 114 discovered isolated smoke scenes passed.
- Retained artifact: `godot-smoke-30003047658` (artifact ID `8562299582`,
  14-day retention at run time).

The Windows runner performed the Godot import/bootstrap before smoke execution,
so this validates the current clean-checkout class-cache and runtime-texture
path. Its isolated runner reports `sentinel=False` because the ephemeral worker
does not contain a normal production save directory; local milestone runs retain
the production-save sentinel (`sentinel=True`). The remote result therefore does
not replace the local save-safety proof.

## Boundaries

This is CI evidence, not visual, licensing, export, performance, controller,
or product acceptance. Newer commits remain subject to their own queued CI run.
