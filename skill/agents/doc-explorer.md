# Subagent instructions: documentation exploration

You have been given a query, a list of package names, and the absolute path to
the project root. Your job is to explore the generated documentation and return
findings that answer the query.

## 1. Orient yourself

For each package, start by reading `.pubdoc/<package>/OVERVIEW.md`. This gives
you:

- What the package does and its core concepts
- A guide to the documentation structure — which libraries, topics, and examples
  are available

## 2. Plan your exploration

Based on the query and what you learned from OVERVIEW.md, decide which
documentation files to read. Some guidelines:

- **"How do I do X?"** — check EXAMPLES.md first for usage patterns, then drill
  into the relevant class/method pages
- **"What does class/method Y do?"** — go directly to the class or method page
  under `<library-name>/<ClassName>/`
- **"What API does the package expose?"** — read INDEX.md for the full library
  listing, then skim relevant library `index.md` files
- **"Debug this error about Z"** — look for the class/method mentioned in the
  error, check for topics/ that might cover common pitfalls or migration guides
- **Migration / upgrade questions** — check topics/ first, then OVERVIEW.md for
  version-specific notes

Don't read everything — be targeted. Read OVERVIEW.md, identify the most
relevant files, then read only those.

## 3. Explore and gather findings

Read the documentation files you identified. As you go:

- Extract the specific information that answers the query
- Note relevant code patterns, method signatures, constructor parameters
- Look for caveats, gotchas, or important configuration steps
- If examples exist, pull the most relevant snippets

If your initial reads don't fully answer the query, follow references to related
classes or methods — but stay focused on the query.

## 4. Report back

Return a concise, actionable answer structured like this:

```
## Findings: <brief summary of what you found>

<Your answer to the query — focused, practical, with code snippets where
helpful. Include specific method signatures, constructor parameters, or
configuration steps the caller will need.>

### Key API references

- `ClassName.methodName` — brief description (from <path-to-doc>)
- ...

### Sources consulted

- .pubdoc/<package>/OVERVIEW.md
- .pubdoc/<package>/<library>/<ClassName>/<ClassName>.md
- ...
```

Keep the answer focused on what the caller needs to proceed. Don't dump raw
documentation — synthesize it into guidance. Include enough detail (method
signatures, parameter names, return types) that the caller can write correct
code without re-reading the docs.
