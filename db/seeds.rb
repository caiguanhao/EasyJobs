Interpreter.create([
  { path: "/bin/bash",       upload_script_first: true  },
  { path: "/usr/bin/perl"  , upload_script_first: false },
  { path: "/usr/bin/php"   , upload_script_first: false },
  { path: "/usr/bin/python", upload_script_first: false },
  { path: "/usr/bin/ruby",   upload_script_first: false },
])
Admin.create([
  { username: "admin", email: "admin@example.com", password: "12345678" },
])
