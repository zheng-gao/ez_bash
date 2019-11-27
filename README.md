# Bash Tools for Linux and MacOS
## Setup ez_bash
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
function ezb_test_required_string_arg() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-i" --long "--input" --required || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local input && input="$(ezb_arg_get --short "-i" --long "--input" --arguments "${@}")" || return 1
    echo "input = \"${input}\""
}

> ezb_test_required_string_arg --help
[Function Name] "ezb_test_required_string_arg"
[Short]  [Long]   [Type]  [Required]  [Default]  [Choices]  [Description]
-i       --input  String  True        None       None       None

> ezb_test_required_string_arg
[2019-11-27 13:31:08][EZ-Bash][ezb_test_required_string_arg][ezb_arg_get][ERROR] Argument "-i" is required

> ezb_test_required_string_arg -i "hello world"
input = "hello world"
```
## --default
```bash
function ezb_test_default_string_arg() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-i" --long "--input" --default "A default string" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local input && input="$(ezb_arg_get --short "-i" --long "--input" --arguments "${@}")" || return 1
    echo "input = \"${input}\""
}

> ezb_test_default_string_arg --help
[Function Name] "ezb_test_default_string_arg"
[Short]  [Long]   [Type]  [Required]  [Default]         [Choices]  [Description]
-i       --input  String  False       A default string  None       None

> ezb_test_default_string_arg
input = "A default string"
> ezb_test_default_string_arg -i "hello world"
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
[2019-11-27 13:41:27][EZ-Bash][ezb_test_string_arg_choices][ezb_arg_get][ERROR] Invalide value "Americano" for argument "-i", please choose from [Cappuccino, Espresso, Latte]

> ezb_test_string_arg_choices -i "Latte"
input = "Latte"
```


Run with --helper
```
$ foo --help

[Function Name]   "foo"
[Function Info]   This is a test function foo
-a1|--argument-1  The 1st argument
-a2|--argument-2  The 2nd argument

```
Give the correct arguments
```
$ foo -a1 "First Arg" --argument-2 "2nd Arg"
Argument 1: First Arg
Argument 2: 2nd Arg
```
Give the wrong argument
```
$ foo --wrong-arg "First Arg"
[2019-11-21 14:26:57][EZ-Bash][foo][ERROR] Unknown argument identifier "--wrong-arg"
[2019-11-21 14:26:57][EZ-Bash][foo][ERROR] Run "foo --help" for more info
```
## Example 2
The new helper supports keywords "--default", "--required", "--choices", "--type", "--info"</br>
And the type of the argument could be "String", "List", "Flag" or "Password" (prompt for password if not given and no default provided)
```bash
function bar() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-a1" --long "--argument-1" --required --info "1st argument" &&
        ezb_arg_set --short "-a2" --long "--argument-2" --default "2nd Arg Def" &&
        ezb_arg_set --short "-a3" --long "--argument-3" --choices "3rd Arg" "Third Arg" &&
        ezb_arg_set --short "-l" --long "--arg-list" --type "List" --default "Item 1" "Item 2" &&
        ezb_arg_set --short "-d" --long "--dry-run" --type "Flag" --info "Boolean Flag" || return 1
    fi
    ezb_function_usage "${@}" && return
    local arg_1 && arg_1="$(ezb_arg_get --short "-a1" --long "--argument-1" --arguments "${@}")" &&
    local arg_2 && arg_2="$(ezb_arg_get --short "-a2" --long "--argument-2" --arguments "${@}")" &&
    local arg_3 && arg_3="$(ezb_arg_get --short "-a3" --long "--argument-3" --arguments "${@}")" &&
    local arg_l && arg_l="$(ezb_arg_get --short "-l" --long "--arg-list" --arguments "${@}")" &&
    local dry_run && dry_run="$(ezb_arg_get -s "-d" -l "--dry-run" --arguments "${@}")" || return 1
    echo "Argument 1: ${arg_1}"
    echo "Argument 2: ${arg_2}"
    echo "Argument 3: ${arg_3}"
    echo "Argument List:"; ezb_split "${EZB_CHAR_NON_SPACE_DELIMITER}" "${arg_l}"
    echo "Dry Run   : ${dry_run}"
}
```
Run with --helper
```
$ bar --help

[Function Name] "bar"

[Short]  [Long]        [Type]  [Required]  [Default]       [Choices]           [Description]
-a1      --argument-1  String  True        None            None                1st argument
-a2      --argument-2  String  False       2nd Arg Def     None                None
-a3      --argument-3  String  False       None            3rd Arg, Third Arg  None
-l       --arg-list    List    False       Item 1, Item 2  None                None
-d       --dry-run     Flag    False       None            None                Boolean Flag

```
Give the correct arguments
```
$ bar -a1 "First Arg" -a2 "Second Arg" -a3 "Third Arg" -l "data1" "data2" "data3"
Argument 1: First Arg
Argument 2: Second Arg
Argument 3: Third Arg
Argument List:
data1
data2
data3
Dry Run   : False
```
The first argument is required, if we ignore it
```
$ bar -a2 "Second Arg" -a3 "Third Arg"
[2019-11-21 14:29:57][EZ-Bash][bar][ezb_arg_get][ERROR] Argument "-a1" is required
```
The second argument and the list argument have default, if we ignore it, will use the default. Flag argument by default use "False"
```
$ bar -a1 "First Arg" -a3 "Third Arg"
Argument 1: First Arg
Argument 2: 2nd Arg Def
Argument 3: Third Arg
Argument List:
Item 1
Item 2
Dry Run   : False
```
The third argument has choices, we could not use other value
```
$ bar -a1 "First Arg" -a3 "Arg 3"
[2019-11-21 13:50:42][EZ-Bash][bar][ezb_arg_get][ERROR] Invalide value "Arg 3" for argument "-a3", please choose from [3rd Arg, Third Arg]
```
If we give the dry run flag, it become "True"
```
$ bar -a1 "First Arg" --dry-run -a3 "3rd Arg"
Argument 1: First Arg
Argument 2: 2nd Arg Def
Argument 3: 3rd Arg
Argument List:
Item 1
Item 2
Dry Run   : True
```