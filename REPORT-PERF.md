# Performance Notes

- Trace overlap calculation now runs on a background task using a shared `CIContext`.
- Snapshot rendering and template generation honor screen scale.
- Persistence writes remain debounced and atomic with error logging.
- Notification scheduling is idempotent and logs failures.
