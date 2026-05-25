# The Vatofichor Agentic Development Lifecycle
**Author**: vatofichor (Sebastian Mass)

## Overview
This document outlines the systematic development lifecycle and coding style implemented by the developer to effectively harness the Gemini IDE (and agentic AI tooling in general). It breaks away from unstructured "vibe coding" by establishing rigorous control systems, persistent state management, and clearly defined operational boundaries. This architecture forces the AI to operate as a disciplined extension of the developer rather than a chaotic code generator.

## Index
1.  **Global Constraints (`rules.md` & Blacklisting)**
2.  **Architectural & Concept Persistence (`LTAP.md` & `concept.md`)**
3.  **The Persistent Memory Space**
4.  **Phase-Level Breakout Planning**
5.  **Operating Modes & "Hats"**
6.  **The `.dev` Sandbox**

---

## 1. Global Constraints (`rules.md` & Blacklisting)
The foundation of the developer's workflow is the absolute restriction of the AI's operating parameters. The developer does not rely on the IDE's default behaviors; instead, they inject a rigorous global ruleset (e.g., `rules.md` or a global system prompt payload).

*   **Behavioral Overrides**: The rules mandate logic density over token bloat, dictate communication styles ("The code is the message"), and enforce backup protocols before destructive acts.
*   **Storage Blacklisting**: The AI is explicitly blacklisted from mutating global system drives (e.g., `C:/`). It is hard-locked to the project-specific workspace.
*   **Privacy Boundaries**: The developer utilizes `AI-NOACCESS.txt` files to explicitly quarantine sensitive directories, ensuring the AI agent blindly skips proprietary client data or restricted environment variables during project-wide searches.

## 2. Architectural & Concept Persistence (`LTAP.md` & `concept.md`)
Because AI context windows are ephemeral and frequently purged across sessions or IDE restarts, the developer grounds the agent using static "Truth Source" documents located at the project root.

*   **`LTAP.md` (Long-Term Alignment Persistence)**: This is the operational manifesto of the project. It explicitly lists the tech stack, security protocols, directory layouts, and absolute negative constraints. The agent is trained to read this file to continuously re-align itself with the developer's overarching vision.
*   **`concept.md`**: The definitive source of truth for complex business logic. When the AI needs to understand *why* a system behaves a certain way, it reads the concept file rather than hallucinating edge cases, drastically reducing logic drift.

## 3. The Persistent Memory Space
By default, Agentic IDEs write implementation plans, task lists, and scratchpads to hidden, volatile directories (like `.brain` or `.ai`). When the IDE updates or the session ends, this memory is wiped, destroying the project's operational continuity.

The developer intercepts this default behavior by explicitly forcing the AI to write all state-tracking documents directly into a visible, version-controlled workspace (e.g., `ai_persistent_files/`):
*   **Intra-Session Memory**: Files like `where_I_left_off.md` and `where_I_am_going.md` allow the AI to serialize its current train of thought.
*   **Task Lists & Walkthroughs**: By forcing the agent to output its `task.md` checklists and `walkthrough_*.md` handovers into the persistent space, the developer ensures that progress is saved permanently, surviving any IDE memory purge.

## 4. Phase-Level Breakout Planning
Default AI behavior attempts to plan the *entire application* at once, leading to massive, convoluted implementation plans that become outdated immediately upon encountering the first bug.

The developer circumvents this by enforcing **Module/Phase-Level Implementation Plans**. 
*   When executing complicated steps, the developer commands the AI to create targeted, scoped documents.
*   This creates a "breakout session" where the AI focuses entirely on a micro-objective (e.g., a specific module's routing engine).
*   Once a phase is completed, the plan is prefixed with `DONE_`. This preserves the historical record of *how* and *why* a module was built without cluttering the active execution space.

## 5. Operating Modes & "Hats"
To prevent the AI from blindly modifying files when the developer only wants to brainstorm, the workflow establishes strict "Operating Modes." The developer switches the AI's "Hat" using explicit activation phrases, actively steering the context of the session:

*   **Normal Mode**: The default state. Standard agentic execution, file modification, and IDE tooling usage.
*   **Planning Mode**: The AI is forbidden from touching code. It exclusively reads, researches, and drafts execution artifacts. It awaits explicit Human-in-the-Loop (HIL) sign-off before executing.
*   **Admin / Doc Mode**: The AI backs out of the codebase to act as a Project Manager. It audits storage systems, writes specification sheets, and updates the `LTAP.md`.
*   **Systems / Bugfixer Mode**: The AI assumes the role of a SecOps Senior Engineer. It aggressively hunts for logic leaks and edge-case exploits, prioritizing security and code integrity over new feature generation.
*   **Conversational Mode**: Tooling is strictly disabled. The AI acts as a sounding board, answering architectural or logic questions to save compute tokens and prevent accidental file mutation.

## 6. The `.dev` Sandbox
To prevent the agent from cluttering the production environment or making dangerous assumptions about package management, the developer provides a strict sandbox.

*   **The `.dev/` Folder**: This is a dedicated staging ground where the AI is explicitly permitted to download dependencies, write testing scripts, build temporary data parsers, and store zip backups. 
*   **Isolation**: By giving the agent a designated space to play, download, and test, the developer isolates garbage generation and experimental scripts away from the production modules, ensuring a clean and auditable main codebase.
