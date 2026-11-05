---
name: new-session
description: >
  Start a separate Claude Code session for a task in a named project folder, and
  file it under that folder's project in the sidebar (top level, not nested under
  this session). Use when the user invokes /new-session, or asks to "create a new
  session / subsession in <folder>", "spin off a session in <folder> for X", or
  similar.
---

# new-session

Start a new session in the folder the user names. Make it show up under that folder's project in the sidebar, not nested under this session.

## Pick the folder

- The user names a folder loosely ("local setup folder", "the api repo"). Resolve it to a real path:
  - Try `~/workspace/<name>` and `~/workspace/*/` with a fuzzy match (`local setup` → `~/workspace/local-setup`).
  - Fall back to `mcp__ccd_session__list_start_targets` recent folders.
- If more than one folder could match, or none match, ask the user. Never guess between candidates.
- No folder named: use this session's folder.

## Write the brief

The new session sees only the brief, not this conversation. Include:

- The task, in your own words.
- The files or area it should look at, and anything already learned or ruled out here.
- Whether it may edit files or is research only. Default to research only when the user said "look into", "investigate", or "find out".
- What done looks like. For research, ask it to end with a short report: the recommendation, what each part does, caveats, how to verify.

## Start it

1. Load the tools if needed, all in one ToolSearch call: `select:mcp__ccd_session__start_session,mcp__ccd_session__list_start_targets,mcp__ccd_session_mgmt__detach_session`.
2. Write a bold title line and one sentence on what it will do.
3. Call `start_session` with:
   - `initiation: "user_asked"`, `context: "fresh"`
   - `cwd`: the resolved folder (skip if it's this session's folder)
   - `title`, a short `name`, `prompt` (the brief), and `background` (at least 80 chars of context)
4. Call `detach_session` with the new session id right away. Without this, the session nests under this one in the sidebar instead of under its folder's project.

## Reporting back

Once a session is detached, this session no longer gets a note when it finishes. Tell the user in one line that the report will be in the new session, linked as `[title](#local_<id>)`, and that you can pull it in here on request.

When they ask for it, read it with `mcp__ccd_session_mgmt__list_events` on that session id and relay the result. Treat the result as that session's report, not proof. Check claims before calling something done.
