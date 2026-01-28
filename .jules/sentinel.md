## 2026-01-28 - Command Injection in Parallel Agent Script
**Vulnerability:** Found command injection in `parallel_agent.sh` where user inputs (via environment variables or arguments) were interpolated directly into `bash -c` strings.
**Learning:** Bash scripts using `bash -c` must never interpolate variables directly. This codebase relies heavily on bash orchestration, making it susceptible to this pattern.
**Prevention:** Use the `bash -c 'command "$1"' -- "$arg"` pattern to pass arguments safely.
