# Bash Tools for Linux and MacOS
## Steps for installing ez_bash
### 1. Clone this project
```bash
git clone https://github.com/zheng-gao/ez_bash.git ${SOME_DIRECTORY}/ez_bash
```
### 2. Setup environment variable: [__EZ_BASH_HOME__](https://github.com/zheng-gao/ez_bash)
```bash
export EZ_BASH_HOME="${SOME_DIRECTORY}/ez_bash"
```
### 3. To import all the "ez_bash" libraries
```bash
source "${EZ_BASH_HOME}/ez_bash.sh" --all
```
### 4. To import one or more "ez_bash" libraries
```bash
source "${EZ_BASH_HOME}/ez_bash.sh" "lib_1" "lib_2" ...
```
## Argument Artributes
| Short Name | Long Name | Type | Description |
| ---------- | --------- | ---- | ----------- |
| -s | --short | String | Short argument identifier |
| -l | --long | String | Long argument identifier |
| -t | --type | String | Argument type: String, List, Flag, Password |
| -i | --info | String | Argument description |
| -c | --choices | List | Argument value can only be one of the choices |
| -d | --default | List | Default value for an argument |
| -r | --required | Flag | Mark the argument required |
## --required
```bash
function ezb_test_string_arg_required() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-i" --long "--input" --required || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local input && input="$(ezb_arg_get --short "-i" --long "--input" --arguments "${@}")" || return 1
    echo "input = \"${input}\""
}

> ezb_test_string_arg_required --help
[Function Name] "ezb_test_string_arg_required"
[Short]  [Long]   [Type]  [Required]  [Default]  [Choices]  [Description]
-i       --input  String  True        None       None       None

> ezb_test_string_arg_required
[2019-11-27 13:31:08][EZ-Bash][ezb_test_string_arg_required][ezb_arg_get][ERROR] Argument "-i" is required

> ezb_test_string_arg_required -i "hello world"
input = "hello world"
```
## --default
```bash
function ezb_test_string_arg_default() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-i" --long "--input" --default "A default string" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local input && input="$(ezb_arg_get --short "-i" --long "--input" --arguments "${@}")" || return 1
    echo "input = \"${input}\""
}

> ezb_test_string_arg_default --help
[Function Name] "ezb_test_string_arg_default"
[Short]  [Long]   [Type]  [Required]  [Default]         [Choices]  [Description]
-i       --input  String  False       A default string  None       None

> ezb_test_string_arg_default
input = "A default string"

> ezb_test_string_arg_default -i "hello world"
input = "hello world"
```
## --choices
```bash
function ezb_test_string_arg_choices() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-i" --long "--input" --required --choices "Cappuccino" "Espresso" "Latte" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local input && input="$(ezb_arg_get --short "-i" --long "--input" --arguments "${@}")" || return 1
    echo "input = \"${input}\""
}

> ezb_test_string_arg_choices --help
[Function Name] "ezb_test_string_arg_choices"
[Short]  [Long]   [Type]  [Required]  [Default]  [Choices]                    [Description]
-i       --input  String  True        None       Cappuccino, Espresso, Latte  None

> ezb_test_string_arg_choices -i "Americano"
[2019-11-27 13:41:27][EZ-Bash][ezb_test_string_arg_choices][ezb_arg_get][ERROR] Invalid value "Americano" for argument "-i", please choose from [Cappuccino, Espresso, Latte]

> ezb_test_string_arg_choices -i "Latte"
input = "Latte"
```
## --type "Password"
```bash
function ezb_test_password_arg() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-p" --long "--password" --required --type "Password" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local password && password="$(ezb_arg_get --short "-p" --long "--password" --arguments "${@}")" || return 1
    echo "$(ezb_string_repeat --string "*" --count ${#password})"
    echo "password = \"${password}\""
}

> ezb_test_password_arg --help
[Function Name] "ezb_test_password_arg"
[Short]  [Long]      [Type]    [Required]  [Default]  [Choices]  [Description]
-p       --password  Password  True        None       None       None

> ezb_test_password_arg
Password for "-p": *********
password = "my secret"
```
## --type "List"
```bash
function ezb_test_list_arg_default() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-l" --long "--list" --default "Def 1" "Def 2" "Def 3" --type "List" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local list && list="$(ezb_arg_get --short "-l" --long "--list" --arguments "${@}")" || return 1
    ezb_function_get_list "${list}"
}

> ezb_test_list_arg_default --help
[Function Name] "ezb_test_list_arg_default"
[Short]  [Long]  [Type]  [Required]  [Default]            [Choices]  [Description]
-l       --list  List    False       Def 1, Def 2, Def 3  None       None

> ezb_test_list_arg_default
Def 1
Def 2
Def 3

> ezb_test_list_arg_default -l "Item 1" "Item 2" "Item 3"
Item 1
Item 2
Item 3
```
## --type "Flag"
```bash
function ezb_test_flag_arg() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-f" --long "--flag" --type "Flag" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local flag && flag="$(ezb_arg_get --short "-f" --long "--flag" --arguments "${@}")" || return 1
    echo "flag = ${flag}"
}

> ezb_test_flag_arg --help
[Function Name] "ezb_test_flag_arg"
[Short]  [Long]  [Type]  [Required]  [Default]  [Choices]  [Description]
-f       --flag  Flag    False       None       None       None

> ezb_test_flag_arg
flag = False

> ezb_test_flag_arg --flag
flag = True
```
## Example
```bash
function example() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-a1" --long "--argument-1" --required --info "1st argument" || return 1
        ezb_arg_set --short "-a2" --long "--argument-2" --default "2nd Arg Def" || return 1
        ezb_arg_set --short "-a3" --long "--argument-3" --choices "3rd Arg" "Third Arg" || return 1
        ezb_arg_set --short "-l" --long "--arg-list" --type "List" --default "Item 1" "Item 2" || return 1
        ezb_arg_set --short "-d" --long "--dry-run" --type "Flag" --info "Boolean Flag" || return 1
    fi
    ezb_function_usage "${@}" && return
    local arg_1; arg_1="$(ezb_arg_get --short "-a1" --long "--argument-1" --arguments "${@}")" || return 1
    local arg_2; arg_2="$(ezb_arg_get --short "-a2" --long "--argument-2" --arguments "${@}")" || return 1
    local arg_3; arg_3="$(ezb_arg_get --short "-a3" --long "--argument-3" --arguments "${@}")" || return 1
    local arg_l; arg_l="$(ezb_arg_get --short "-l" --long "--arg-list" --arguments "${@}")" || return 1
    local dry_run; dry_run="$(ezb_arg_get -s "-d" -l "--dry-run" --arguments "${@}")" || return 1
    echo "Argument 1: ${arg_1}"
    echo "Argument 2: ${arg_2}"
    echo "Argument 3: ${arg_3}"
    echo "Argument List:"; ezb_function_get_list "${arg_l}"
    echo "Dry Run   : ${dry_run}"
}

> example --help

[Function Name] "example"

[Short]  [Long]        [Type]  [Required]  [Default]       [Choices]           [Description]
-a1      --argument-1  String  True        None            None                1st argument
-a2      --argument-2  String  False       2nd Arg Def     None                None
-a3      --argument-3  String  False       None            3rd Arg, Third Arg  None
-l       --arg-list    List    False       Item 1, Item 2  None                None
-d       --dry-run     Flag    False       None            None                Boolean Flag
```