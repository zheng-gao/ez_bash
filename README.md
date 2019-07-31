# ez_bash
Bash Tools for Linux and MacOS<br/>
Setup Environment Variable "EZ_BASH_HOME"
```
source "${EZ_BASH_HOME}/ez_bash.sh"
```
# Example 1
```
function foo() {
    local usage=$(ez_build_usage -o "init" -d "This is a test function foo")
    usage+=$(ez_build_usage -o "add" -a "-a1|--argument-1" -d "The 1st argument")
    usage+=$(ez_build_usage -o "add" -a "-a2|--argument-2" -d "The 2nd argument")
    if [ -z "${1}" ] || [ "${1}" = "-h" ] || [ "${1}" = "--help" ]; then ez_print_usage "${usage}"; return 1; fi
    local arg_1=""
    local arg_2=""
    while [ -n "${1}" ]; do
        case "${1-}" in
            "-a1" | "--argument-1") shift; arg_1="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-a2" | "--argument-2") shift; arg_2="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            *) ez_print_log -l ERROR -m "Unknown argument \"$1\""; ez_print_usage "${usage}"; return 1 ;;
        esac
    done
    echo "Argument 1: ${arg_1}"
    echo "Argument 2: ${arg_2}"
}
```
Run with --helper
```
$ foo --help                        
[Function Name]    "foo"
[Function Info]    This is a test function foo
-a1|--argument-1    The 1st argument
-a2|--argument-2    The 2nd argument
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
[EZ-BASH][2019-07-30 21:02:36][foo][ERROR] Unknown argument "--wrong-arg"
```
# Example 2
The new helper support keywords "--default", "--required", "--choices", "--flag" and type "List"<br/>
You need to source 2 files to get the new feature
```
source "${EZ_BASH_HOME}/ez_bash_core/ez_bash_core.sh"
source "${EZ_BASH_HOME}/ez_bash_core/ez_bash_function.sh"
```
```
function bar() {
    ez_set_argument --short "-a1" --long "--argument-1" --required --info "The 1st argument" &&
    ez_set_argument --short "-a2" --long "--argument-2" --default "2nd Arg Def" --info "The 2nd argument" &&
    ez_set_argument --short "-a3" --long "--argument-3" --choices "3rd Arg" "Third Arg" --info "The 3rd argument" &&
    ez_set_argument --short "-l" --long "--arg-list" --type "List" --default "Item 1" "Item 2" --info "The list argument" &&
    ez_set_argument --short "-d" --long "--dry-run" --type "Flag" --info "The flag argument" || return 1
    ez_ask_for_help "${@}" && ez_function_help && return
    local arg_1; arg_1="$(ez_get_argument --short "-a1" --long "--argument-1" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local arg_2; arg_2="$(ez_get_argument --short "-a2" --long "--argument-2" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local arg_3; arg_3="$(ez_get_argument --short "-a3" --long "--argument-3" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local arg_l; arg_l="$(ez_get_argument --short "-l" --long "--arg-list" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local dry_run; dry_run="$(ez_get_argument --short '-d' --long "--dry-run" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    echo "Argument 1: ${arg_1}"
    echo "Argument 2: ${arg_2}"
    echo "Argument 3: ${arg_3}"
    echo "Argument List:"; tr "${EZ_BASH_NON_SPACE_LIST_DELIMITER}" "\n" <<< "${arg_l}"
    echo "Dry Run   : ${dry_run}"
}
```
Run with --helper
```
$ bar --help
[Function Name] "bar"
[Arg Short]  [Arg Long]    [Arg Type]  [Arg Required]  [Arg Default]   [Arg Choices]       [Arg Description]
-a1          --argument-1  String      True            NONE            NONE                The 1st argument
-a2          --argument-2  String      False           2nd Arg Def     NONE                The 2nd argument
-a3          --argument-3  String      False           NONE            3rd Arg, Third Arg  The 3rd argument
-l           --arg-list    List        False           Item 1, Item 2  NONE                The list argument
-d           --dry-run     Flag        False           NONE            NONE                The flag argument
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
[2019-07-30 21:35:23][EZ-BASH][bar][ez_get_argument][ERROR] Argument "-a1" is required
[2019-07-30 21:35:23][EZ-BASH][bar][ez_get_argument][ERROR] Argument "--argument-1" is required
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
[2019-07-30 21:37:02][EZ-BASH][bar][ez_get_argument][ERROR] Invalide value "Arg 3" for argument "-a3", please choose from [3rd Arg, Third Arg]
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