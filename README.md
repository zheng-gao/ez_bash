# Bash Tools for Linux and MacOS
## Steps for installing ez_bash
#### 1. Clone this project
```bash
git clone https://github.com/zheng-gao/ez_bash.git ${SOME_DIRECTORY}/ez_bash
```
#### 2. Setup environment variable: [__EZ_BASH_HOME__](https://github.com/zheng-gao/ez_bash)
```bash
export EZ_BASH_HOME="${SOME_DIRECTORY}/ez_bash"
```
#### 3. To import all the "ez_bash" libraries
```bash
source "${EZ_BASH_HOME}/ez_bash.sh" --all
```
#### 4. To import one or more "ez_bash" libraries
```bash
source "${EZ_BASH_HOME}/ez_bash.sh" "lib_1" "lib_2" ...
```
## Examples
### Argument Artributes
| Short Name | Long Name | Type | Description |
| ---------- | --------- | ---- | ----------- |
| -s | --short | String | Short argument identifier |
| -l | --long | String | Long argument identifier |
| -t | --type | String | "String" by default, other types are "List", "Flag" and "Password" |
| -i | --info | String | Argument description |
| -e | --exclude | String | Mutually exclusive group ID |
| -c | --choices | List | Argument value can only be one of the choices |
| -d | --default | List | Default value for an argument |
| -r | --required | Flag | Mark the argument required |
### --required
```bash
function ezb_test_string_arg_required() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-i" --long "--input" --required || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local input; input=$(ezb_arg_get --short "-i" --long "--input" --arguments "${@}") || return 1
    echo "input = \"${input}\""
}

> ezb_test_string_arg_required --help
[Function Name] "ezb_test_string_arg_required"
[Short]  [Long]   [Type]  [Required]  [Exclude]  [Default]  [Choices]  [Description]
-i       --input  String  True        None       None       None       None

> ezb_test_string_arg_required
[2019-11-27 13:31:08][EZ-Bash][ezb_test_string_arg_required][ezb_arg_get][ERROR] Argument "-i" is required

> ezb_test_string_arg_required -i "hello world"
input = "hello world"
```
### --default
```bash
function ezb_test_string_arg_default() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-i" --long "--input" --default "A default string" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local input; input=$(ezb_arg_get --short "-i" --long "--input" --arguments "${@}") || return 1
    echo "input = \"${input}\""
}

> ezb_test_string_arg_default --help
[Function Name] "ezb_test_string_arg_default"
[Short]  [Long]   [Type]  [Required]  [Exclude]  [Default]         [Choices]  [Description]
-i       --input  String  False       None       A default string  None       None

> ezb_test_string_arg_default
input = "A default string"

> ezb_test_string_arg_default -i "hello world"
input = "hello world"
```
### --exclude
```bash
function ezb_test_string_arg_exclude() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-m" --long "--male" --exclude "1" || return 1
        ezb_arg_set --short "-f" --long "--female" --exclude "1" || return 1
        ezb_arg_set --short "-l" --long "--lock" --exclude "2" || return 1
        ezb_arg_set --short "-u" --long "--unlock" --exclude "2" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local male; male=$(ezb_arg_get --short "-m" --long "--male" --arguments "${@}") || return 1
    local female; female=$(ezb_arg_get --short "-f" --long "--female" --arguments "${@}") || return 1
    local lock; lock=$(ezb_arg_get --short "-l" --long "--lock" --arguments "${@}") || return 1
    local unlock; unlock=$(ezb_arg_get --short "-u" --long "--unlock" --arguments "${@}") || return 1
    [[ -n "${male}" ]] && echo "male = \"${male}\""
    [[ -n "${female}" ]] && echo "female = \"${female}\""
    [[ -n "${lock}" ]] && echo "lock = \"${lock}\""
    [[ -n "${unlock}" ]] && echo "unlock = \"${unlock}\""
}

> ezb_test_string_arg_exclude --help
[Function Name] "ezb_test_string_arg_exclude"
[Short]  [Long]    [Type]  [Required]  [Exclude]  [Default]  [Choices]  [Description]
-m       --male    String  False       1          None       None       None
-f       --female  String  False       1          None       None       None
-l       --lock    String  False       2          None       None       None
-u       --unlock  String  False       2          None       None       None

> ezb_test_string_arg_exclude -m "Test" -l "Test"
male = "Test"
lock = "Test"

> ezb_test_string_arg_exclude -m "Test" -f "Test"
[2019-11-28 17:32:34][EZ-Bash][ezb_test_string_arg_exclude][ezb_arg_get][ERROR] "-m" and "-f" are mutually exclusive

> ezb_test_string_arg_exclude -l "Test" --unlock "Test"
[2019-11-28 17:32:51][EZ-Bash][ezb_test_string_arg_exclude][ezb_arg_get][ERROR] "-l" and "--unlock" are mutually exclusive
```
### --choices
```bash
function ezb_test_string_arg_choices() {
    if ezb_function_unregistered; then
        ezb_arg_set -s "-i" -l "--input" -r --choices "Cappuccino" "Espresso" "Latte" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local input; input=$(ezb_arg_get -s "-i" -l "--input" -a "${@}") || return 1
    echo "input = \"${input}\""
}

> ezb_test_string_arg_choices --help
[Function Name] "ezb_test_string_arg_choices"
[Short]  [Long]   [Type]  [Required]  [Exclude]  [Default]  [Choices]                    [Description]
-i       --input  String  True        None       None       Cappuccino, Espresso, Latte  None

> ezb_test_string_arg_choices -i "Americano"
[2019-11-27 16:32:07][EZ-Bash][ezb_test_string_arg_choices][ezb_arg_get][ERROR] Invalid value "Americano" for argument "-i"
[2019-11-27 16:32:07][EZ-Bash][ezb_test_string_arg_choices][ezb_arg_get][ERROR] Please choose from [Cappuccino, Espresso, Latte] for argument "-i"

> ezb_test_string_arg_choices -i "Latte"
input = "Latte"
```
### --type "Password"
```bash
function ezb_test_password_arg() {
    if ezb_function_unregistered; then
        ezb_arg_set -s "-p" -l "--password" -r -t "Password" -i "Admin password" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local password; password=$(ezb_arg_get -s "-p" -l "--password" -a "${@}") || return 1
    echo "$(ezb_string_repeat --string "*" --count ${#password})"
    echo "password = \"${password}\""
}

> ezb_test_password_arg --help
[Function Name] "ezb_test_password_arg"
[Short]  [Long]      [Type]    [Required]  [Exclude]  [Default]  [Choices]  [Description]
-p       --password  Password  True        None       None       None       Admin password

> ezb_test_password_arg
Admin password "--password": *********
password = "my secret"
```
### --type "List"
```bash
function ezb_test_list_arg_default() {
    if ezb_function_unregistered; then
        ezb_arg_set -s "-l" -l "--list" -d "Def 1" "Def 2" "Def 3" -t "List" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local list; list=$(ezb_arg_get -s "-l" -l "--list" -a "${@}") || return 1
    ezb_function_get_list "${list}"
}

> ezb_test_list_arg_default --help
[Function Name] "ezb_test_list_arg_default"
[Short]  [Long]  [Type]  [Required]  [Exclude]  [Default]            [Choices]  [Description]
-l       --list  List    False       None       Def 1, Def 2, Def 3  None       None

> ezb_test_list_arg_default
Def 1
Def 2
Def 3

> ezb_test_list_arg_default -l "Item 1" "Item 2" "Item 3"
Item 1
Item 2
Item 3
```
### --type "Flag"
```bash
function ezb_test_flag_arg() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-f" --long "--flag" --type "Flag" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local flag; flag=$(ezb_arg_get --short "-f" --long "--flag" --arguments "${@}") || return 1
    echo "flag = ${flag}"
}

> ezb_test_flag_arg --help
[Function Name] "ezb_test_flag_arg"
[Short]  [Long]  [Type]  [Required]  [Exclude]  [Default]  [Choices]  [Description]
-f       --flag  Flag    False       None       None       None       None

> ezb_test_flag_arg
flag = False

> ezb_test_flag_arg --flag
flag = True
```