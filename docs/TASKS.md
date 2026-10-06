# Portable Kit Task Graph

Status: READY_AFTER_GATE

## Lane A - portable configuration engine

- `setup/lib/Portable.Common.ps1`
- bootstrap, doctor, update, rollback, uninstall and safe export
- backup, staging, validation, manifest and secret scanning

## Lane B - portable sources and documentation

- `profiles/codex/`
- `manifests/`
- root README and security guidance
- clean-home fixtures and tests

## Integration

1. Complete source templates and scripts.
2. Run clean-home plan and apply simulation.
3. Verify existing-file preservation and rollback.
4. Run secret scan, kit verification and unit tests.
5. Commit only after all gates pass.
