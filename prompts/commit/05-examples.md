Here are detailed examples and explanations:

Single Line Commit Message Format:

```
:<Emoji>: <Type>: <Subject>
^----^ ^---^ ^------------^
  |      |         |
  |      |         +-> Summary in present tense.
  |      |
  |      +-------> Type: chore, docs, feat, fix, refactor, style, test, etc.
  |
  +-------> Emoji: :tada: :bookmark: :sparkles: :bug: :books: :wrench: :truck:
```

Examples:

- `feat:` Add a new feature (equivalent to a MINOR in Semantic Versioning)
- `fix:` Fix a bug (equivalent to a PATCH in Semantic Versioning)
- `docs:` Documentation changes (update, delete, create documents)
- `style:` Code style change (formatting, missing semi colons, etc; no production code change)
- `refactor:` Refactor code (refactoring production code, eg. renaming a variable)
- `perf:` Update code performances
- `test:` Add test to an existing feature (adding missing tests, refactoring tests; no production code change)
- `chore:` Update something without impacting the user (updating grunt tasks bump a dependency in package.json. no production code change)

Scope:
The scope could be anything specifying place or category of the commit change. For example:

- $location, $browser, $compile, $rootScope
- ngHref, ngClick, ngView
- feature1, component2, module3

Subject:

- Use the imperative, present tense: "change" not "changed" nor "changes"
- Don't capitalize first letter
- No dot (.) at the end
- Keep it under 72 characters

Message Body:

- Use the imperative, present tense
- Include motivation for the change
- Contrast with previous behavior
- Explain what and why, not how

Message Footer:

- Reference GitHub issues (e.g., "Fixes #1", "Closes #2", "Resolves #3")
- Add notes starting with "NOTE:" if needed
- Include breaking changes if any

Complete Examples:

New Feature:

```
:star: new(graphite): add 'graphiteWidth' option
```

Bug Fix:

```
:bug: fix(graphite): stop graphite breaking when width < 0.1

Closes #28
```

Breaking Change:

```
:boom: breaking(api): remove deprecated API endpoints

BREAKING CHANGE: The following API endpoints have been removed:
- /api/v1/users
- /api/v1/posts

Please use the new v2 endpoints instead.
```

Documentation:

```
:pencil: docs: update API documentation

Add examples for all endpoints
Include authentication requirements
Update rate limiting information

Fixes #42
```
