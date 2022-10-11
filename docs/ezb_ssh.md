### ezb_mssh_local_function
```shell
$ function local_func() { local a; for a in "${@}"; do echo "${FUNCNAME}: ${a}"; done; }
$ ezb_mssh_local_function --hosts 10.32.113.143 10.32.113.145 --function local_func --arguments "--arg1 a" "--arg2 b"
[10.32.113.143]
local_func: --arg1 a
local_func: --arg2 b

[10.32.113.145]
local_func: --arg1 a
local_func: --arg2 b

```