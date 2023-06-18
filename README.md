# Firstmail Backend

MVP

- cowboy + sqlite
- single domain per-email and from-email
- email dns instructions (email confirmation)
- curl as client
- swoosh adapter
- free for testing (to any domain)
- dedicated server offer

- POST api/mail -d name@domain.com -> emails DNS instructions with ID and first token
  - reposting would generate a new email with same ID, same DNS instructions but a new token
- POST api/mail/ID + token + from|subject|reply|mime|to(s) headers + body
  - send async result to registered email
- DELETE api/mail/ID + token

## Howto

```bash
mix new fmd_backend --module Firstmail --app firstmail --sup
cd fmd_backend
```
