# Decision Record Template

Use this template when documenting significant technical or architectural decisions.

## Template

```markdown
# ADR-[NUMBER]: [TITLE]

**Date:** YYYY-MM-DD
**Status:** [Proposed | Accepted | Deprecated | Superseded by ADR-XXX]
**Decision Makers:** [Names/roles involved]

## Context

[Describe the situation that requires a decision. What problem are we solving? What constraints exist? What forces are at play?]

## Decision

[State the decision clearly and concisely. Use active voice: "We will..." not "It was decided..."]

## Consequences

### Positive
- [Benefit 1]
- [Benefit 2]

### Negative
- [Tradeoff 1]
- [Tradeoff 2]

### Neutral
- [Side effect that's neither good nor bad]

## Alternatives Considered

### Alternative 1: [Name]
- **Description:** [Brief explanation]
- **Pros:** [Why it might work]
- **Cons:** [Why we didn't choose it]

### Alternative 2: [Name]
- **Description:** [Brief explanation]
- **Pros:** [Why it might work]
- **Cons:** [Why we didn't choose it]

## References

- [Link to relevant documentation]
- [Link to discussion thread]
- [Related ADRs]
```

## Example

```markdown
# ADR-001: Use PostgreSQL for Primary Database

**Date:** 2024-01-15
**Status:** Accepted
**Decision Makers:** Engineering Team

## Context

We need to select a primary database for the application. Requirements include:
- ACID compliance for financial transactions
- JSON support for flexible schema portions
- Strong ecosystem and tooling
- Team familiarity

## Decision

We will use PostgreSQL 15+ as our primary database.

## Consequences

### Positive
- ACID compliance ensures transaction integrity
- JSONB columns allow flexible schema where needed
- Excellent tooling (pg_dump, pgAdmin, etc.)
- Team has 5+ years collective experience

### Negative
- Requires more operational expertise than managed NoSQL
- Horizontal scaling more complex than some alternatives
- Need to manage connection pooling (PgBouncer)

### Neutral
- Will use standard ORM (SQLAlchemy) for abstraction
- Migrations managed via Alembic

## Alternatives Considered

### Alternative 1: MongoDB
- **Description:** Document-oriented NoSQL database
- **Pros:** Flexible schema, easy horizontal scaling
- **Cons:** No ACID transactions across documents, team less familiar

### Alternative 2: MySQL
- **Description:** Popular open-source RDBMS
- **Pros:** Wide adoption, good performance
- **Cons:** Less robust JSON support, PostgreSQL has richer feature set

## References

- [PostgreSQL 15 Release Notes](https://www.postgresql.org/docs/15/release-15.html)
- Team discussion in #architecture channel (2024-01-10)
```

## Guidelines

### When to Create an ADR
- Choosing between technologies or frameworks
- Architectural pattern decisions (monolith vs microservices)
- API design choices with long-term implications
- Security approach decisions
- Data model design choices
- Breaking changes to existing systems

### When NOT to Create an ADR
- Implementation details that can easily change
- Bug fixes
- Minor refactoring
- Obvious choices with no real alternatives

### Naming Convention
- Store in `docs/decisions/` directory
- Name: `ADR-NNN-short-title.md`
- Number sequentially (001, 002, 003...)

### Status Lifecycle
1. **Proposed** - Under discussion, not yet decided
2. **Accepted** - Decision made, implementation can proceed
3. **Deprecated** - No longer relevant (context changed)
4. **Superseded** - Replaced by a newer ADR (link to it)

### Best Practices
- Write ADRs BEFORE implementation, not after
- Keep them concise - one decision per ADR
- Include the "why" - context matters for future readers
- Update status when decisions change
- Link related ADRs together
