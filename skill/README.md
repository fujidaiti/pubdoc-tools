# Agent skill for pubdoc

The [doc-explorer] is a [Claude Code skill][] that answers questions about
Dart/Flutter packages using version-accurate documentation provided by the
[pubdoc][] command.

See [CHAT.log][] for an example conversation with Claude Code demonstrating the
skill in action.

[doc-explorer]: skill/plugin/doc-explorer
[Claude Code skill]: https://docs.anthropic.com/en/docs/claude-code/skills
[CHAT.log]: example/CHAT.log
[pubdoc]: https://github.com/fujidaiti/pubdoc-tools/tree/main/pubdoc

## Usage

Typically you don't need to be aware of the skill; your agent automatically uses
it when relevant. So just ask questions about Dart/Flutter packages or delegate
implementation tasks to the agent as you normally would. For example:

```
Help me migrate the app's navigation logic to use go_router
```

Then the agent will decide to use the skill and execute a plan like this:

```
...

⏺ Now let me design the migration plan.

⏺ Plan(Design go_router migration plan)
  ⎿  Done (13 tool uses · 43.9k tokens · 1m 40s)
  (ctrl+o to expand)

⏺ Let me read the critical files and check the go_router API before finalizing.

⏺ Read 3 files (ctrl+o to expand)

⏺ Now let me check the go_router API documentation.

⏺ Skill(pubdoc-skills:doc-explorer)
  ⎿  Successfully loaded skill

...
```

## Requirements

Under the hood, the skill uses pubdoc command to generate and manage the
documentation for Dart/Flutter packages. Make sure that the command is installed
globally. If not, you can install it via [dart install][] (requires Dart SDK
3.10 or later):

```shell
dart install pubdoc
```

Make sure the command is available in your PATH:

```shell
pubdoc --version
```

[dart install]: https://dart.dev/tools/dart-install

## Installation

### Add from marketplace

This option installs the skill as a plugin from this [marketplace][]. Launch
Claude Code and add the marketplace first:

```
/plugin marketplace add fujidaiti/claude-plugin-marketplace
```

Then, install the plugin:

```
/plugin install pubdoc-skills@norelease-dev-plugins
```

Now you should see the `doc-explorer` skill in your skill list:

```
/skills

─────────────────────────────────────────────────────────────────────
  Skills
  1 skill

  Plugin skills (plugin)
  doc-explorer · pubdoc-skills · ~158 description tokens
```

[marketplace]: https://github.com/fujidaiti/claude-plugin-marketplace

### Clone and load locally

Alternatively, you can clone this repository and copy the skill directory to
your `.claude/skills/`:

```shell
git clone https://github.com/fujidaiti/pubdoc-tools.git
cp -r pubdoc-tools/skill/plugin/doc-explorer /path/to/your/.claude/skills/
```

## What content does the skill read/write?

- create a doc directory in the cache (write)
- read the doc directory to answer questions (read)
- may add packages to project's pubspec.yaml (write)
- create summary files in the doc directory (write, experimental)
  - install the experimental plugin instead of the stable one

## Q&As

### My agent doesn't use the skill

Try including this phrase in your prompt (e.g., in CLAUDE.md):

```markdown
**Proactively** use the `pubdoc-skills:doc-explorer` skill.
```
