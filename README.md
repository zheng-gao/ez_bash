# ez_bash
Bash Tools for Linux and MacOS
### Clone this project
```bash
git clone https://github.com/zheng-gao/ez_bash.git ${SOME_DIRECTORY}/ez_bash
```
### Setup environment variable: [__EZ_BASH_HOME__](https://github.com/zheng-gao/ez_bash)
```bash
export EZ_BASH_HOME="${SOME_DIRECTORY}/ez_bash"
```
### Import all the "ez_bash" libraries
```bash
source "${EZ_BASH_HOME}/ez_bash.sh"
```
## Example 1
```bash
function foo() {
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        local usage=$(ezb_build_usage -o "init" -d "This is a test function foo")
        usage+=$(ezb_build_usage -o "add" -a "-a1|--argument-1" -d "The 1st argument")
        usage+=$(ezb_build_usage -o "add" -a "-a2|--argument-2" -d "The 2nd argument")
        ezb_print_usage "${usage}" && return 0
    fi
    local arg_1; local arg_2
    while [[ -n "${1}" ]]; do
        case "${1-}" in
            "-a1" | "--argument-1") shift; arg_1="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-a2" | "--argument-2") shift; arg_2="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            *) ezb_log_error "Unknown argument identifier \"${1}\""
               ezb_log_error "Run \"${FUNCNAME[0]} --help\" for more info" 
               return 1 ;;
        esac
    done
    echo "Argument 1: ${arg_1}"
    echo "Argument 2: ${arg_2}"
}
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
The new helper supports keywords "--default", "--required", "--choices", "--type", "--info"
And the type of the argument could be "String", "List" and "Flag"
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