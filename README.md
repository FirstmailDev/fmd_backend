# Firstmail Backend

- POST api/mail -d name@domain.com -> emails DNS instructions with ID and first token
  - reposting would generate a new email with same ID, same DNS instructions but a new token
- GET api/mail/ID -> shows setup instructions and upgrade options
- POST api/mail/ID + token + from|subject|reply|mime|to(s) headers + body
- PUT api/mail/ID -d free|pro1|pro2|pro3 -> stripe
- DELETE api/mail/ID + token
