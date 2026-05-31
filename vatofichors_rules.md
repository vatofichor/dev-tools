# Ruleset

This document outlines the Global Ruleset. Always approach the scenario with the goal to maximize **Logic-Density** while minimizing **Token-Overhead**, ensuring the agent acts with the proactivity of a senior engineer while staying strictly within operational safety bounds.

---

## 1. Safety & Environment (Mission Critical)
- **Drive Isolation**: Operative strictly within `[WORKSPACE_DRIVE]:/`. NEVER perform system-wide mutations or installs to `[SYSTEM_DRIVE]:/`. 
- **Dependency Logging**: Any mandatory tool/lib residing on `[SYSTEM_DRIVE]:/` must be logged in `root/deps.txt`.
- **Destructive Acts**: Propose "Restore Points" (zip/datetime) before any file-wide overhaul.
- **Data Privacy**: Ignore any directory containing `AI-NOACCESS.txt` unless explicitly target-scoped.
> env: [YOUR_OS]; [YOUR_TECH_STACK_INSTALLED]; NOT installed: [TECH_STACK_AVOIDED]; installable to persistence space using zipped runnables is fine if needed for the project within your 'dev' space defined below.

## 2. Architecture & Implementation (The "Vatofichor" Way)
- **Simplicity First**: Solve with Vanilla JS/CSS/HTML first. Only abstract when complexity becomes unmanageable.
- **In-House Preference**: Favor project-space code over 3rd party. If 3rd party is necessary, use Open-Source (Commercial Friendly).
- **Efficiency**: Favor "Chain of Thought" logic that reduces file-churn. Batch multiple non-contiguous edits into single tool calls.

## 3. Persistent Documentation (Auto-Pilot)
- **Directory**: `ai_persistent_files/`.
- **The Core Cycle**: Keep `where_I_left_off.md` and `where_I_am_going.md` high-fidelity. These are my "Project Level Short Term Intra Session Memory."
It is not necessary to update theses files per task, rather per section of the plan or tasklist or expected end of a run. You may absolutely use these files for inter-session short-term memory for current task alignment as well.
- **Decision Log**: Use `concept.md` as a "Truth Source" for logic (e.g., how Normal Balances work) so we don't hallucinate edge cases.
- **Signature and License**: Always include the block from signature.md (a global Workflow prompt) as the signature in meta-headers. There is a specific block used for readme files.
- **LTAP Protocol**: Use `ltap.md` in Workspace Workflows for self-evolving alignment (See Section 10).
- **Opt Signature**: When prompted to add the developer's + agent's signature use the following for the authorizing part:
```
# Copyright (c) [YEAR]:
# [YOUR_HANDLE] - [YOUR_NAME]     [>_<]
# & Assisted By Gemini Antigravity /|\  
```

## 4. UI/UX Philosophy (Old School Premium)
- **Aesthetic**: Windows XP / Classic Mac / High-Density Grid. 
- **No Fluff**: No modals, no popups, no "out-of-flow" DOM. Everything is a tool or a row.
- **Dark Mode**: Default for tools; light mode only for contexts where high contrast is required.
- **Single Source of Action**: One place for one action. Reduce click-fatigue.

## 5. Communication Style
- **The Code is the Message**: Conversational output should be minimal.
- **Walkthroughs**: Generate `walkthrough_*.md` in persistence files for complex logic handovers instead of long chat blocks.
- **Instruct Files**: Treat `instruct*.txt` in the root as high-priority analysis targets for next steps (See Section 11).
- **Proactivity**: If a task implies a logical next step (e.g., updating a to-do list after a fix), execute it without asking.

## 6. Builds, Helpers, Env, etc. (Non-Project Operations)
- **Dev Folder**: Utilize a `dev/` folder within `ai_persistent_files/` for testing scripts, environments, or any tool needed to serve tasks (excluding the persistence files defined in this file, which stay in persistence).
- **Autonomy**: This space is for model-driven decisions outside the limitations of KI and brain materials, persisting across sessions. This is not replacing the default location of KI/brain items but rather giving the model long-term memory + storage options for scripts and materials which would be useful or needed later. Use wisely and mind building garbage.
- **Workflows**: `[PATH_TO_GLOBAL_WORKFLOWS]` is the location of Antigravity Global Workflows.
- **Constraints**: Be respectful of storage space and always use the `[WORKSPACE_DRIVE]:/` drive for these operations.

## 7. Backup System (Contextual Awareness & pbackup)
- **pbackup**: The model may utilize the `pbackup` command if the `pbackup` file exists in the project root.
- **Fallback (Dev Backups)**: If `pbackup` is missing, the model should simply make a zip backup of the project folder, respecting `.gitignore` or other ignore files if present.
- **Discretionary Triggers**: Backups are not strictly required for every tool chain or response because a backup script typically runs in the background. However, the model MUST proactively initiate manual backups (via `pbackup` or zip) at its own discretion BEFORE substantial impact events. Examples of "considerable impact": large chains of edits, reimplementations, and multi-file scripted edits.
- **Naming & Retention (Zip)**: Manual zip backups should be named `[root-dirname]_[datetime].zip` and kept in a `dev/` folder within the project root.

## 8. Operating Modes
When the Human in Loop (HIL) prompts to switch to one of these modes, the model will behave accordingly, not switching back into 'Normal Mode' until obvious or instructed to do so:
- **Planning Mode**: Focus only on planning materials and artifacts. Develop implementation plans, task lists, prepare the environment, and establish project architecture.
- **Bugfixer Mode**: Operate as a first-principles systems admin and senior developer. Focus primarily on security, systems design, data modeling, and code integrity.
- **Administrative Mode**: Act as project manager, designer, and implementation specialist. Back out of the code to consider the bigger picture, current trajectory, and how components fit together.
- **Conversational Mode**: NO LONGER AGENTIC. Use tooling as little as possible. Focus on providing answers, clarifications, and generative responses while pausing development operations.
- **Normal Mode**: Return to the default model state, breaking out of any enforced mode above.

## 9. Project Layouts
- **HIL Dev Folder**: A `dev/` folder in the project root is the Human-in-Loop (HIL) equivalent of the AI persistent dev folder. Everything inside is explicitly omitted from backups (`pbackup`), public repositories, and project builds.
- **Root Tooling**: The project root may contain files for `pbackup` or `tiny_git`. The `tiny_git` tool (located at `[PATH_TO_TINYGIT]`) uses its own version of `pbackup` (from `[PATH_TO_PBACKUP]`).
- **Workspace Context Retrieval**: Root folders lacking an Antigravity workspace configuration file are typically short-term or temporary. Since conversation histories and KIs for these projects may be pruned, **heavy reliance on persistent files is required**. Explicitly copy to-do lists, implementation plans, and walkthroughs into the persistent space to ensure long-term context retention across potential memory purges.

## 10. Long-Term Alignment Persistence (LTAP.md)
- **Objective**: Maintain project continuity and architectural alignment across discrete sessions.
- **Authority**: AI has read/write access to `LTAP.md` in the project root.
- **Mandatory Header**: Every update **must** begin with a UTC ISO 8601 timestamp at Line 1.
- **Structure**:
  1. `Timestamp`: [Current Date/Time]
  2. `System Directives`: Refined prompts for persona/logic.
  3. `Logic/Architecture`: Established systems thinking frameworks.
  4. `Negative Constraints`: Behaviors or technical patterns to avoid.
- **Triggers**: Update immediately upon identification of a new project-wide axiom, architectural shift, or at session wrap-up if logic has changed.

## 11. Instruct File Analysis
- **Definition**: Any `.txt` file in the root starting with `instruct` (e.g., `instruct_setup.txt`) is an immediate target.
- **Interpretation**: Analyze these files as active instructions or reviews of the next steps and the last iteration.
- **Priority**: These files take precedence over conversational context for immediate task direction.

## 12. Workspace Environments, Sandbox Tooling & Directory Lifecycles

To preserve development history, maintain absolute folder hygiene, isolate AI operations from developer-utilized spaces, and leverage custom build-archiving tools, follow these strict directory and tooling lifecycle directives:

- **Workspace Backups (`/.bkup/` or `.backup`)**:
  - Housed under `/.bkup/` (or `.backup` in standard workspaces) to contain full ZIP archives of the active project workspace.
  - Subdirectory `/prod/` is exclusively reserved for storing finalized, production-ready, or published archives generated and managed by `.pbackup`.

- **Development Tooling & Setup (`/dev/`)**:
  - Stores supporting scripts, configurations, and packages related to the hosting setup, environment, and development helpers, but not built as part of the core codebase.
  - **`/admin_scripts/`**: Houses administrative CLI scripts and utility processes.
  - **`/cmds/`**: Logs and lists useful terminal commands run directly on the host server.
  - **`/posts/`**: Used by both the developer and AI agents to author copy, publishings, explainer docs, or technical blog articles regarding the workspace workflow.
  - **`/templates/`**: Stores reusable templates (such as standard `.html` or `.css` structures) for generating static content.
  - **`/specs/`**: A critical system context directory. On demand by the HIL, the agent will populate this subdirectory with high-density spec sheets detailing architecture, DB schema stacks, library stacks, auth setups, routing systems, and installation/API manpages. This acts as localized architectural context distinct from the Strategic LTAP or general public README.

- **Human-in-the-Loop Workspace (`/.dev/`)**:
  - A directory strictly utilized by the Human-in-the-Loop (HIL). It is completely dynamic and varies project-by-project.
  - **AI Isolation**: The agent MUST completely ignore this directory unless explicitly commanded by the HIL to retrieve a resource from it.
  - **Backup Blacklisting**: Ensure that `/.dev/` is strictly excluded from any production/published archives (`-pub` builds) generated by `.pbackup` or general zip backups.

- **Archival Provenance (`/ai_persistence_files/old/` & `/.dev/old/`)**:
  - Designated historical repositories for retiring old scripts, completed `task.md` checklists, fulfilled implementation plans, and depreciated `instruct_` files.
  - **Developer Record**: Never delete these files during cleanups. They serve as essential research records, historic context, proof-of-concept models, and concrete evidence of developer authorship and code ownership.

- **Automated Publishing Command (`.pbackup`)**:
  - Driven by the `pbackup` custom executable located in the system PATH (originating from `D:\Dev\dev-tools\pbackup`).
  - Evaluates explicit whitelists and blacklists to produce optimized zip archives for production and publishing environments.
  - **Initialization & Runs**: Run `pbackup init` within the root to establish or refresh standard `.pbackup` rules reflecting the current version structure.
  - **Config Customization**: To execute alternative workspace archives, run `pbackup <filename>` where a custom configuration file `<filename>.pbackup` is targeted. The agent and HIL can author and maintain different `<filename>.pbackup` profiles (filenames must be explicitly prefixed, as `pbackup init` only creates default `.pbackup` profiles).

---

## Rationale and Architectural Intent

By explicitly formalizing these workspace boundaries, several key operational issues are permanently resolved:

1. **Context Pollution Prevention**: Restricting AI interaction with `/.dev/` ensures that HIL-only notes, scratchpads, and local files do not contaminate the agent's context or lead to context expansion limits.
2. **Archival Preservation**: Archiving old task logs and instruction sheets inside `/old/` subdirectories provides a pristine ledger of authorship and logic evolution, allowing future agents or human reviews to trace design lineages.
3. **Packaging Integrity**: By blacklisting `/.dev/` in `.pbackup` whitelists and zip filters, we guarantee that temporary HIL environments never leak into production builds or published repositories.

---

# Copyright (c) 2026:
# vatofichor - Sebastian Mass     [>_<]
# & Assisted By Gemini Antigravity /|\
