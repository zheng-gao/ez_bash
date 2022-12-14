### ezb_ssh_local_function
```shell
$ function local_func { local a; for a in "${@}"; do echo "${FUNCNAME}: ${a}"; done; }
$ ezb_ssh_local_function --hosts lca1-app38708.corp lca1-app40197.corp --function local_func --arguments "--arg1 a" "--arg2 b"
[lca1-app38708.corp]
local_func: --arg1 a
local_func: --arg2 b

[lca1-app40197.corp]
local_func: --arg1 a
local_func: --arg2 b

```