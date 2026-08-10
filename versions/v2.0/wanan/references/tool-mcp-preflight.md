# Tool and MCP preflight

Use this reference before the first specialized or external capability in a task. Re-run it only when the capability or target system changes.

## Source order

1. Current user instruction and supplied artifacts
2. Applicable repository instructions and specs
3. Installed skill `SKILL.md` plus every mandatory linked prerequisite
4. Callable MCP/app schema and connector-provided resources
5. Primary official documentation for current APIs, limits, and behavior
6. General web sources only when primary sources are unavailable

Do not infer current API behavior, pricing, permissions, or schemas from model memory when verification is cheap.

## Capability routing

| Capability | Preflight |
|---|---|
| Local code, files, search, patches, and tests | Use local tools directly. Search for an MCP only if a specialized external capability is actually involved. |
| GitHub, GitLab, issues, PRs, or remote repository state | Read the matching repository/Git skill, then prefer its purpose-built connector for remote state. Use local Git for local worktree inspection and scoped commits. |
| Email, calendar, cloud documents, storage, chat, or work tracking | Search for the installed app/MCP connector before browser automation. Preserve drafts and ask before sending, deleting, or changing external records unless explicitly authorized. |
| Browser work | Load the matching browser-control skill. Prefer the in-app browser for isolated work and the user's Chrome only when existing login/profile/extension state is required or requested. |
| Figma or Product Design | Load the router/prerequisite skill before the focused tool. Do not call the underlying design tool before its mandatory skill is read. |
| DOCX, PDF, spreadsheets, presentations, CAD, or other specialized formats | Load the format skill and its required runtime/dependencies before using generic scripts. Preserve render/layout validation requirements. |
| Hosting, deployment, cloud infrastructure, or databases | Load the platform skill and inspect the project configuration before mutation. Prefer the platform connector/CLI selected by that skill. Separate local checks from production evidence. |
| Current SDK, API, model, provider, or standard | Read primary official documentation and inspect the callable schema before implementation or requests. |

Treat this table as routing guidance. Current installed skills and tool schemas override examples.

## Discover the connector

1. Search by the capability and target system, not by a guessed tool name. In Codex, use `tool_search` to discover deferred MCP/app tools.
2. Inspect the returned tool description and input schema before constructing arguments.
3. Prefer connector resources over web search when they expose the required authoritative data.
4. For installed Apps in Codex, use app/tool discovery and do not call raw MCP resource listing or template listing as a substitute.
5. Do not invoke a similarly named connector until its provenance and target match the user's system.

## Missing capability

1. Confirm that discovery was attempted.
2. Search the supported plugin/app catalog for the exact missing capability.
3. Suggest only relevant install/connect options and continue independent local work when possible.
4. Wait for explicit user action when connection, authentication, or installation is required.
5. If the user declines or no connector exists, name the fallback and its limitations before proceeding.

Do not install unrelated plugins or claim that a nonblocking suggestion succeeded.

## Mutation boundary

| Action | Default |
|---|---|
| Read-only discovery inside the stated scope | Proceed. |
| Reversible local implementation step | Proceed and verify. |
| External write explicitly requested by the user | Proceed within the named target and scope. |
| Send, publish, deploy, charge, delete, overwrite, migrate, or change protected/production state | Confirm target and authority unless the current request explicitly and unambiguously authorizes that exact action. |
| Fallback that lowers fidelity, bypasses a purpose-built connector, or increases risk/cost | Explain and ask first. |

Start with the smallest read-only probe that proves authentication and target identity when doing so is safe and free. A successful schema lookup is not proof that the actual mutation path works.

## Handoff record

For a material capability, record:

- sources and skill read;
- connector/MCP selected;
- authentication or target identity verified;
- actions performed;
- fallback and limitations;
- external mutations and production/paid checks not run.
