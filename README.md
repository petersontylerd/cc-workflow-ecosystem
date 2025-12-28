# Workflow Ecosystem

A comprehensive Claude Code plugin for human-agent co-development, providing skills, commands, and agents that enforce disciplined software engineering practices.

## Features

- **Brainstorming**: Explore requirements before implementation
- **Planning**: Create bite-sized, executable implementation plans
- **Subagent Orchestration**: Coordinate implementer, spec-reviewer, and quality-reviewer agents
- **Verification**: Evidence-based completion claims (no "should work" allowed)
- **Git Workflow**: Feature branch enforcement with atomic commits

## Installation

### Local Plugin (Development)

Clone this repository and use the `--plugin-dir` flag:

```bash
git clone https://github.com/<your-user>/workflow-ecosystem.git
cd your-project
claude --plugin-dir /path/to/workflow-ecosystem
```

### Local Plugin (Permanent)

Clone to Claude Code's local plugins directory:

```bash
mkdir -p ~/.claude/plugins/local
git clone https://github.com/<your-user>/workflow-ecosystem.git ~/.claude/plugins/local/workflow-ecosystem
```

## Quick Start

1. Start Claude Code with the plugin installed
2. The SessionStart hook injects the ecosystem introduction
3. Use commands to guide your workflow:

```
/brainstorm    # Explore requirements before implementation
/branch        # Create feature branch with naming enforcement
/plan          # Create bite-sized implementation plan
/implement     # Execute plan with subagent orchestration
/verify        # Run pre-completion verification
/commit        # Create atomic commit with conventional format
/pr            # Generate PR description
```

## Components

### Skills

| Skill | Description |
|-------|-------------|
| `using-ecosystem` | Ecosystem introduction (auto-injected on session start) |
| `brainstorming` | Pre-implementation requirement exploration |
| `writing-plans` | Bite-sized task planning with exact code |
| `orchestrating-subagents` | Multi-agent coordination pattern |
| `verification` | Evidence-based completion discipline |
| `git-workflow` | Branch and commit enforcement |

### Commands

| Command | Purpose |
|---------|---------|
| `/brainstorm` | Explore requirements one question at a time |
| `/branch` | Create/switch to feature branch |
| `/plan` | Generate implementation plan |
| `/implement` | Execute plan with subagent dispatch |
| `/verify` | Run pre-completion checks |
| `/commit` | Create atomic commit |
| `/pr` | Generate PR description |

### Agents

| Agent | Role |
|-------|------|
| `code-implementer` | Executes implementation tasks following TDD |
| `spec-reviewer` | Validates code matches requirements |
| `quality-reviewer` | Assesses code quality and style |

## Core Workflow

```
User Request
    |
    v
/brainstorm  ->  Explore requirements (one question at a time)
    |
    v
/branch      ->  Create feat/<issue>-<slug> branch
    |
    v
/plan        ->  Create bite-sized tasks with exact code
    |
    v
/implement   ->  For each task:
                   1. Dispatch code-implementer
                   2. Dispatch spec-reviewer
                   3. Dispatch quality-reviewer
                   4. Fix issues, mark complete
    |
    v
/verify      ->  Evidence-based completion check
    |
    v
/pr          ->  Generate PR description for your platform
```

## Key Disciplines

### Verification

No completion claims without evidence:
- Run the command, see the output, THEN claim the result
- Never say "should work" or "probably fixed"
- Tests pass means you saw "X passed, 0 failed"

### TDD

Write test first, watch it fail, implement, watch it pass:
- Red-green-refactor cycle is mandatory
- No implementation without a failing test first

### Feature Branches

Never commit to main:
- Pattern: `feat/<issue>-<slug>` or `fix/<issue>-<slug>`
- Atomic commits with conventional format

## Directory Structure

```
workflow-ecosystem/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── hooks/
│   ├── hooks.json           # SessionStart hook config
│   ├── run-hook.cmd         # Cross-platform hook runner
│   └── session-start.sh     # Inject ecosystem context
├── skills/                   # Core competencies
├── commands/                 # User-invokable workflows
├── agents/                   # Specialized subagents
├── docs/                     # Documentation
├── tests/                    # Pressure test scenarios
├── templates/                # Document templates
└── README.md
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

1. Fork this repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Follow the workflow disciplines (brainstorm, plan, implement, verify)
4. Create a pull request

## Acknowledgments

Inspired by patterns from the [superpowers](https://github.com/anthropics/claude-code/tree/main/plugins) Claude Code plugin.
