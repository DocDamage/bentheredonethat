# M0 Full Smoke Regression — Manifest Port Handoff

- **Status:** verified automated aggregate regression
- **Run artifact:** `test-artifacts/20260723-124703-6a6a6f3a`
- **Scope:** complete isolated Godot smoke matrix following the manifest port
  lifecycle and HM-01 navigation safety update.

## Command

```powershell
.\tools\run_godot_isolated.ps1 -AllSmoke -TimeoutSeconds 900
```

## Result

The runner exited successfully. Its artifact contains 125 scene logs, with no
`FAILED`, assertion-failure, script-error, or parse-error marker. The isolated
runner's successful exit also confirms that its production-save sentinel was
not changed during the matrix.

The HM-01 authored-room contract now specifies 100 useful cells. This reflects
the deliberate removal of five top-lintel cells that would otherwise let a
click path cross the separate facility-return port while traveling to the HM-02
handoff.

Godot still emits its normal shutdown object/resource warnings. They are
recorded as a baseline runtime teardown condition and were not test failures in
this run.
