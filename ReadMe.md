## Installation

1. From application root: `git submodule add https://github.com/lazuscripts/users users`

2. Inside your application: `@include "users/users"`

3. In migrations, do the following:
   ```
   import create_table, types from require "lapis.db.schema"
   create_table "users", {
       {"id", types.serial primary_key: true}
       {"name", types.varchar unique: true}
       {"salt", types.text}
       {"digest", types.text}
   }
   ```

Note: Assumes you have a route named "index" to redirect to when things go
wrong.

## Config

`digest_rounds = 9` must be set. Use a higher or lower number depending on how
long it takes to calculate a digest or how paranoid you want to be. See this bit
about tuning: https://github.com/mikejsavage/lua-bcrypt#tuning

## Access

To get the Users model for use outside of this sub-application:<br>
`Users = require "users.models.Users"`
