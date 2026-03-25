# Agent skill for pubdoc

A [Claude Code skill][] that answers questions about Dart/Flutter packages using
version-accurate documentation provided by the [pubdoc][] command.

See [CHAT.log][] for an example conversation with Claude Code demonstrating the
skill in action.

[Claude Code skill]: https://docs.anthropic.com/en/docs/claude-code/skills
[CHAT.log]: example/CHAT.log
[pubdoc]: https://github.com/fujidaiti/pubdoc-tools/tree/main/pubdoc

## Usage

WIP

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

[marketplace]: https://github.com/fujidaiti/claude-plugin-marketplace

### Clone and load locally

Alternatively, you can clone this repository and copy the skill directory to
your `.claude/skills/`:

```shell
git clone https://github.com/fujidaiti/pubdoc-tools.git
cp -r pubdoc-tools/skill/plugin/doc-explorer /path/to/your/.claude/skills/
```

## What content does the skill read/write?

WIP

## Q&As

### My agent doesn't use the skill

Try including this phrase in your prompt (e.g., in CLAUDE.md):

```
**Proactively** use the `pubdoc-skills:doc-explorer` skill.
```
