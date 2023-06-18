# Firstmail Backend

MVP

- cowboy + sqlite
- single domain per-email and from-email
- email dns instructions (email confirmation)
- curl as client
- swoosh adapter
- free for testing (to any domain)
- dedicated server offer

- POST api/user -d name@domain.com -> emails DNS instructions with ID and first token
  - reposting would generate a new email with same ID, same DNS instructions but a new token
- POST api/user/ID + token + from|subject|reply|mime|to(s) headers + body
  - send async result to registered email
- DELETE api/user/ID + token

Errors

- curl -v localhost:31682/api/userX -d user@firstmail.dev
  - 404 not found
  - 500 No on-conflict found (on docker only)
- curl -v localhost:31682/api/user/X -X DELETE
- curl -v localhost:31682/api/user -X POST
  - 400 bad request (failed validation)
  - 500 internal error (on exception)
- curl -v localhost:31682/api/user -X DELETE
  - 500 internal error (on :stop)

```bash
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub
iex -S mix
curl -v localhost:31682/api/user -d user@firstmail.dev
sqlite3 .database/firstmail_dev.db "select * from users"
curl -v localhost:31682/api/user/01H2H215K5A56YBNKVE3E008ST
curl -v localhost:31682/api/user/01H2H215K5A56YBNKVE3E008ST -X PUT -H "Gak-Token: 01H2H215K5JXZ7HFMT8EA96RHY" -d "UPDATED"
curl -v localhost:31682/api/user/01H2H215K5A56YBNKVE3E008ST -X PUT -H "Gak-Token: 01H2H215K5JXZ7HFMT8EA96RHY" -d @$HOME/.ssh/id_ed25519.pub
curl -v localhost:31682/api/user/01H2H215K5A56YBNKVE3E008ST -X DELETE -H "Gak-Token: 01H2H1WV7SMEJR4E19HY7S0J38"

# deploy to firstmail.dev
./firstmail deploy

export FMD_MAILER_ENABLED=false
export FMD_MAILER_ENABLED=true

#run dev locally
iex -S mix
sshuttle -r firstmail.dev 0.0.0.0/0

# run prod release locally
./firstmail local
sshuttle -r firstmail.dev 0.0.0.0/0

# bring production db to dev
./firstmail fetch-backup
```

## Todo

- Cache headers
- Purge cron job

## Howto

```bash
mix new fmd_backend --module Firstmail --app firstmail --sup
cd fmd_backend
mix ecto.gen.repo -r Firstmail.Repo
mix ecto.gen.migration create_users
mix ecto.migrate
sqlite3 .database/firstmail_test.db ".schema users"
sqlite3 .database/firstmail_dev.db ".schema users"
```

## Future

- CI/CD
- CDN
- 2FA
- CLI

## References

- https://github.com/woylie/ecto_ulid
- https://www.davekuhlman.org/cowboy-rest-add-get-update-list.html
- https://ninenines.eu/docs/en/cowboy/2.9/guide/rest_flowcharts/
- https://ninenines.eu/docs/en/gun/2.0/guide/
