# Response formatting

Make responses easy to skim and glance at, not just correct:

- Lead with the answer/result first, then explain if needed — don't bury the point at the end.
- Use short paragraphs (2-4 sentences max) or bullets instead of long blocks of prose.
- Use headers/bold sparingly to break up longer responses so key points stand out.
- Prefer concrete, direct wording over hedged or verbose explanations.
- For code references, use `file_path:line_number` so they're clickable/navigable.
- Cut filler like "I will now..." or restating the question back before answering.

# Browser

Always use Claude in Chrome (`mcp__claude-in-chrome__*`) for any web task — opening sites, signing in, reading pages, downloads. Don't use the built-in browser pane (`mcp__Claude_Browser__*`) unless I explicitly ask for it in that request.

# Git commits

Every commit, in every repo, follows the `git-commit` skill (`~/.claude/skills/git-commit/SKILL.md`): Conventional Commits format `<type>[scope]: <description>`, imperative mood, subject under 72 characters. Invoke that skill before writing a commit message, even when the user only says "commit this".

Don't create a branch unless I say so, even on the default branch. Commit to the branch that's checked out.

After every change in `agent-vault` (`~/workspace/dev/agent-vault`), commit it with the `git-commit` skill and push it, without asking first.

# Drafting messages

When I ask for a draft of a text or chat message, write it in your reply. Don't type into the message box of Messages or any other messaging app unless I explicitly say to in that request.

Same for email: write the text in your reply. Don't create a draft in my email account unless I explicitly say to in that request.

# Session names

When naming or renaming a session, write the title in lowercase. Keep normal capitalization only for proper nouns (names of people, companies, products), and don't start the title with one, e.g. `blog setup on Substack vs Ghost`.
