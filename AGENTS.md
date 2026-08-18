# Yeknom UI Kit project rules

## Required workflow after code changes

After every code change in this repository—including Dart, Flutter, macOS,
configuration, test, and shell-script changes—the agent must complete the
following workflow before handing the task back:

1. Inspect `git status --short`, then review the complete working-tree diff,
   including untracked files, while preserving unrelated, user-owned changes.
2. Perform a code review of the changed behavior. Check correctness,
   regressions, public API compatibility, accessibility, responsive behavior,
   test coverage, and script safety as applicable. Use an independent reviewer
   or sub-agent when one is available.
3. Fix every actionable finding, then return to step 1 and review the resulting
   diff again. Repeat until no actionable findings remain.
4. Run all of these checks from the repository root and fix any failures:

   ```bash
   dart format --output=none --set-exit-if-changed lib test example/lib example/test
   flutter test
   (cd example && flutter test)
   flutter analyze
   (cd example && flutter analyze)
   bash -n install_macos.sh
   if command -v shellcheck >/dev/null 2>&1; then shellcheck install_macos.sh; fi
   git diff --check
   ```

   If a check requires a code fix, return to step 1 and rerun the complete
   review and validation suite.

5. Only after review and the complete validation suite are clean, run:

   ```bash
   ./install_macos.sh
   ```

6. Verify that `/Applications/Yeknom UI Kit Catalog.app` exists and that the
   installed executable is running. Report the review result, validation
   result, installation path, and launch verification.

If macOS, Flutter, permissions, or another external dependency prevents the
installation step, report the exact blocker instead of silently skipping it.
Do not commit or push unless the user explicitly requests it.
