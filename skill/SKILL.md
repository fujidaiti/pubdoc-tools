---
name: pubdoc
description: >
  Look up how a Dart/Flutter package works using version-accurate documentation
  generated from the project's actual dependencies. Use this skill whenever you
  need to understand a package API before writing code — don't rely on training
  knowledge, as APIs may have changed. This includes implementing features with
  a third-party package, debugging errors or stack traces involving one, looking
  up method signatures or class behavior, figuring out how to configure or
  integrate a package, or migrating/upgrading to a new version. If you're about
  to call into a package you're not 100% sure about, use this skill first.
---

# pubdoc

Answers questions about Dart/Flutter packages by generating version-accurate
documentation and exploring it. The workflow has two phases:

1. **Generate docs** — a subagent installs the `pubdoc` CLI (if needed), runs it
   against the project's pinned dependency versions, and enriches the output
   with examples and an overview.
2. **Explore docs** — a subagent reads the generated documentation and returns
   findings relevant to your query.

Both phases run in subagents to keep the main context window clean.

## Phase 1: Generate documentation

Spawn a subagent to prepare the docs:

- **Model:** use a fast, low-latency model (e.g., Haiku for Claude)
- **Pass:** the package name(s) and the absolute path to the project root
- **Instructions:** read and follow `agents/doc-generator.md`

Wait for it to return the documentation paths before moving on.

> **Skip condition:** If `.pubdoc/<package>/OVERVIEW.md` already exists for
> every requested package, you can skip this phase — the docs are already
> generated.

## Phase 2: Explore documentation

Spawn a read-only subagent to explore the docs and answer the query:

- **Model:** use a fast, low-latency model
- **Permissions:** read-only (no file writes, no shell commands that modify the
  filesystem)
- **Instructions:** read and follow `agents/doc-explorer.md`
- **Prompt:** a self-contained description of the task including the doc
  path(s).

Here are some examples of the prompt:

```
Read the documentation at /path/to/project/.pubdoc/app_links/ and explain
how to set up deep link handling on Android and iOS.

Read the documentation at /path/to/project/.pubdoc/dio/ and describe the
interceptor API: what parameters it accepts, how to chain multiple
interceptors, and common patterns.
```

Wait for the findings, then use them to proceed with your task.

## Documentation structure

For reference, generated docs live at `.pubdoc/<package>/` in the project root:

```
.pubdoc/<package>/
├── OVERVIEW.md            ← start here: README summary + documentation guide
├── INDEX.md               ← full package overview from dartdoc
├── <library-name>/        ← one directory per public library
│   ├── <ClassName>/
│   │   ├── <ClassName>.md
│   │   └── <ClassName>-methodName.md
│   └── top-level-functions/
├── topics/                ← topic pages, e.g. migration guides (if available)
├── README.md              ← original README for reference (if available)
├── EXAMPLES.md            ← examples overview with snippets (if available)
└── example/               ← raw example .dart files (if available)
```
