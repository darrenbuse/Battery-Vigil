This is a battery monitoring app.

When running the `cp` or `mv` commands always run with a `-f` flag

## Debugging Guidelines

When debugging issues:

1. **Analyze before acting**: Always read relevant code and understand the issue thoroughly before making changes. Use tools like Grep and Read to explore the codebase, not jump to conclusions.

2. **Do the work, don't delegate**: Handle all the work myself - installing dependencies, running setup, testing, etc. Never ask the user to install things or run commands that I can execute.

3. **Stay methodical**: Work through issues step-by-step. Create a todo list for complex debugging. Don't jump between different areas of the code without completing current investigation.

4. **Track progress**: Use TodoWrite to manage debugging tasks. Keep todos updated as work progresses and mark items complete as they're finished.

5. **Communicate clearly**: Keep the user informed of what I'm investigating and findings, but avoid overwhelming them with control or excessive output. Summarize results clearly.

6. **Test thoroughly**: Verify fixes work before considering them complete. Test the actual issue the user reported, not just the code change in isolation.

## Known Issues and Solutions

### Notification System
- **Issue**: Notifications from LaunchAgent were unreliable and required complex permission setup.
- **Solution**: Switched to cron-based scheduling for simplicity and reliability. Uses `terminal-notifier` which is more straightforward to test and debug.
- **If reinstalling**: Run `install.sh` to set up cron jobs (no LaunchAgent complexity).
- **Testing**: Use `battery-vigil test` to trigger notifications without state tracking - useful for testing without waiting for actual battery changes.
