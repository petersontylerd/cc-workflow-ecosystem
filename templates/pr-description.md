# Pull Request Description Template

Use this template when creating pull requests with the `/pr` command.

## Template

```markdown
## Summary
[2-3 sentences describing what this PR does and why]

Closes #[issue-number]

## Changes
- [Group changes by component/area]
- [Use bullet points for clarity]
- [Highlight breaking changes with ⚠️]

## Test Plan
- [ ] [Specific test case with expected result]
- [ ] [Manual verification step]
- [ ] [Edge case tested]

## Screenshots
[If UI changes, include before/after screenshots]

## Checklist
- [ ] Tests pass locally
- [ ] Linter passes
- [ ] Documentation updated (if applicable)
- [ ] No TODO/FIXME left in code
- [ ] Reviewed my own code

## Notes
[Any additional context, migration steps, or deployment considerations]
```

## Example

```markdown
## Summary
Implements OAuth2 authentication with Google and GitHub providers. Users can now log in with their existing accounts, reducing friction and password fatigue.

Closes #42

## Changes
- **OAuth Configuration**
  - Added OAuth2 provider configuration for Google and GitHub
  - Stored client secrets in environment variables
- **Login Flow**
  - Added `/auth/google` and `/auth/github` routes
  - Implemented callback handlers for OAuth flow
  - Created session after successful authentication
- **UI Updates**
  - Added social login buttons to login page
  - Updated registration page with OAuth options

## Test Plan
- [ ] Login with Google creates session
- [ ] Login with GitHub creates session
- [ ] Session persists after browser restart
- [ ] Logout clears session
- [ ] Invalid OAuth callback shows error

## Screenshots
### Before
[Login page with email/password only]

### After
[Login page with social login buttons]

## Checklist
- [x] Tests pass locally (47/47)
- [x] Linter passes (0 errors)
- [x] Documentation updated (added OAuth setup to README)
- [x] No TODO/FIXME left in code
- [x] Reviewed my own code

## Notes
- Requires `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET` environment variables
- OAuth callback URLs need to be configured in provider dashboards
```

## Guidelines

### Summary
- Focus on WHAT and WHY
- Keep to 2-3 sentences
- Include the closing issue reference

### Changes
- Group by component or area
- Use present tense ("Add" not "Added")
- Mark breaking changes clearly

### Test Plan
- Specific, verifiable steps
- Include expected results
- Cover happy path and edge cases

### Screenshots
- Required for UI changes
- Show before/after comparison
- Keep images reasonably sized

### Notes
- Environment requirements
- Migration steps if applicable
- Deployment considerations
- Known limitations
