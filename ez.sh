###################################################################################################
# ------------------------------------------- EZ-Bash ------------------------------------------- #
###################################################################################################
# Setup Environment Variable "EZ_BASH_HOME"
# > export EZ_BASH_HOME=".../ez_bash"
# To import all ez_bash libraries 
# > source "${EZ_BASH_HOME}/ez.sh" --all
# To import some ez_bash libraries
# > source "${EZ_BASH_HOME}/ez.sh" "lib1" "lib2" ...

###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZ_LOGO="EZ-Bash"
EZ_VERSION="2.0.1"
EZ_REQUIRED_MIN_BASH_VERSION=5

###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
EZ_DEFAULT_DEPENDENCIES=(
    "alias"
    "basename"
    "bash"
    "column"
    "date"
    "declare"
    "dirname"
    "echo"
    "false"
    "grep"
    "ls"
    "mkdir"
    "mv"
    "popd"
    "printf"
    "pushd"
    "pwd"
    "read"
    "rm"
    "sed"
    "set"
    "shift"
    "shopt"
    "sort"
    "source"
    "test"
    "tr"
    "true"
    "uname"
    "unset"
)

unset EZ_DEPENDENCY_SET
declare -g -A EZ_DEPENDENCY_SET
function ez_dependency_check {
    local cmd; for cmd in "${@}"; do
        if [[ -z "${EZ_DEPENDENCY_SET[${cmd}]}" ]]; then
            which "${cmd}" > "/dev/null" || return 1
            EZ_DEPENDENCY_SET["${cmd}"]="${EZ_TRUE}"
        fi
    done
}

function ez_show_checked_dependencies {
    local dependency; for dependency in "${!EZ_DEPENDENCY_SET[@]}"; do echo "${dependency}"; done
}

ez_dependency_check "${EZ_DEFAULT_DEPENDENCIES[@]}"

###################################################################################################
# ------------------------------------------ Utilities ------------------------------------------ #
###################################################################################################
function ez_self_installation {
    local ez_bash_home="${1}" uninstall="${2}"
    local bash_profile="${HOME}/.bash_profile" bashrc="${HOME}/.bashrc"
    if [[ -n "${uninstall}" ]]; then  # Uninstall
        if [[ -f "${bash_profile}" ]]; then
            if grep "ez.sh" "${bash_profile}" > "/dev/null"; then
                grep -v "ez.sh" < "${bash_profile}" > "${bash_profile}.new"
                mv "${bash_profile}.new" "${bash_profile}"
            else
                echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] ${EZ_LOGO} not found!" && return 1
            fi
        elif [[ -f "${bashrc}" ]]; then
            if grep "ez.sh" "${bashrc}" > "/dev/null"; then
                grep -v "ez.sh" < "${bashrc}" > "${bashrc}.new"
                mv "${bashrc}.new" "${bashrc}"
            else
                echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] ${EZ_LOGO} not found!" && return 1
            fi
        fi
        echo "[${EZ_LOGO}][INFO] Uninstallation Complete!"
        echo "[${EZ_LOGO}][INFO] Please restart all the existing terminals."
    else  # Install
        if [[ -f "${bash_profile}" ]]; then
            if grep "ez.sh" "${bash_profile}" > "/dev/null"; then
                echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] ${EZ_LOGO} was previously installed!" && return 1
            else
                echo -e "source ${ez_bash_home}/ez.sh --all\n" >> "${bash_profile}"
                source "${bash_profile}"
            fi
        elif [[ -f "${bashrc}" ]]; then
            if grep "ez.sh" "${bashrc}" > "/dev/null"; then
                echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] ${EZ_LOGO} was previously installed!" && return 1
            else
                echo -e "source ${ez_bash_home}/ez.sh --all\n" >> "${bashrc}"
                source "${bashrc}"
            fi
        fi
        echo "[${EZ_LOGO}][INFO] Installation Complete!"
        echo "[${EZ_LOGO}][INFO] Please restart all the other terminals."
    fi
}

function ez_self_version {
    echo
    echo "[${EZ_LOGO}]"
    echo "    Author : Zheng Gao"
    echo "    Version: ${EZ_VERSION}"
    echo "    Require: Bash v${EZ_DEFAULT_BASH_VERSION}"
    echo
}

function ez_self_unit_test {
    local tests_dir="${1}" test_files=("${@:2}") test_file test_result test_summary has_error test_error
    local spliter="--------------------------------------------------------------------------------"
    [[ -z "${test_files}" ]] && test_files=($(ls -1 ${tests_dir} | grep -v 'utils.sh'))
    for test_file in "${test_files[@]}"; do
        if test_result=$("${tests_dir}/${test_file}"); then
            test_summary+="[✓] ${test_file}\n"
        else
            has_error="True"
            test_summary+="[\e[31m☓\e[0m] ${test_file}\n"
            test_error+="${spliter}\nError in ${test_file}\n${spliter}\n${test_result}"
        fi
    done
    echo -e "${spliter}\n[Test Summary]\n${spliter}\n${test_summary}"
    [[ -n "${has_error}" ]] && echo -e "${test_error}\n"
}

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
function ez_self_source_option {
    local all_flag="" quiet_flag="" import_libs=() skip_libs=()
    local args=("-a" "--all" "-q" "--quiet" "-i" "--import" "-s" "--skip")
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-h" | "--help")
                {
                    echo "  ARGUMENTS#DESCRIPTION"
                    echo "  -a|--all#Import all libraries"
                    echo "  -s|--skip#Skip some libraries"
                } | column -s "#" -t
                echo; return
                ;;
            "-a" | "--all") shift; all_flag="${EZ_TRUE}" ;;
            "-q" | "--quiet") shift; quiet_flag="${EZ_TRUE}" ;;
            "-i" | "--import") shift;
                while [[ -n "${1}" ]]; do ez_includes "${1}" "${args[@]}" && break; import_libs+=("${1}"); shift; done ;;
            "-s" | "--skip") shift;
                while [[ -n "${1}" ]]; do ez_includes "${1}" "${args[@]}" && break; skip_libs+=("${1}"); shift; done ;;
            *) log_error "Unknown argument identifier \"${1}\""; return 1 ;;
        esac
    done
    # Source Other Libs, echo to stderr (>&2) to unblock rsync.
    if [[ -n "${all_flag}" ]]; then
        ez_source_dir --path "${EZ_BASH_HOME}/src/libs" || return 1
        [[ -z "${quiet_flag}" ]] && >&2 echo -e "[${EZ_LOGO}][INFO] Imported $(ez_string_format 'ForegroundYellow' 'ALL') ${EZ_LOGO} libraries!"
    elif [[ -n "${skip_libs}" ]]; then
        ez_source_dir --path "${EZ_BASH_HOME}/src/libs" --exclude "${skip_libs[@]}" || return 1
        [[ -z "${quiet_flag}" ]] && >&2 echo -e "[${EZ_LOGO}][INFO] Imported ${EZ_LOGO}, skipping libraries $(ez_string_format 'ForegroundYellow' $(ez_join ', ' ${skip_libs[@]}))"
    elif [[ -n "${import_libs}" ]]; then
        # Source the designated libraries
        local ez_library; for ez_library in "${import_libs[@]}"; do ez_source_dir --path "${EZ_BASH_HOME}/src/libs/${ez_library}" || return 1; done
        [[ -z "${quiet_flag}" ]] && >&2 echo "[${EZ_LOGO}][INFO] Imported ${EZ_LOGO} libraries: ${@}"
    else
        [[ -z "${quiet_flag}" ]] && >&2 echo "[${EZ_LOGO}][INFO] Imported ${EZ_LOGO} core"
    fi
}

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    # The script is being executed
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        echo
        echo "[${EZ_LOGO}]"
        echo "    -i|--install                        Install ${EZ_LOGO}"
        echo "    -u|--uninstall                      Uninstall ${EZ_LOGO}"
        echo "    -v|--version                        Show version info"
        echo "    -t|--test <TEST_FILE.sh>            Run unit test"
        ls -1 "$(dirname ${0})/tests" | grep "^test_" | sed 's/^/              /'
        echo
        exit 0
    fi
    case "${1}" in
        "-c" | "--check")
            if which "shellcheck" > "/dev/null"; then
                find "$(dirname ${0})/src" -type f -name "*.sh" -exec shellcheck {} \;
            else
                echo "Run following commands to install shellcheck:"
                if [[ "$(uname -s)" = "Darwin" ]]; then
                    echo "    brew install shellcheck"
                else
                    echo "    apt install shellcheck"
                    echo "    yum install shellcheck"
                fi
            fi ;;
        "-t" | "--test") ez_self_unit_test "$(dirname ${0})/tests" "${@:2}" ;;
        "-i" | "--install")
            if [[ "$(dirname ${0})" = "." ]]; then
                ez_self_installation "$(pwd)"
            else
                ez_self_installation "$(pwd)/$(dirname ${0})"
            fi ;;
        "-u" | "--uninstall")
            if [[ "$(dirname ${0})" = "." ]]; then
                ez_self_installation "$(pwd)" "uninstall"
            else
                ez_self_installation "$(pwd)/$(dirname ${0})" "uninstall"
            fi ;;
        "-v" | "--version") ez_self_version ;;
        *) echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] Unknown argument identifier \"${1}\"" && exit 1 ;;
    esac
else
    # The script is being sourced
    local_current_bash_version="$(bash --version | sed -nre 's/^[^0-9]*(([0-9]+\.)+[0-9]+).*/\1/p' | cut -c1-1)"
    if [[ "${local_current_bash_version}" -lt "${EZ_REQUIRED_MIN_BASH_VERSION}" ]]; then
        echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] Current Bash Version \"${local_current_bash_version}\", Required Min Bash Version: \"${EZ_REQUIRED_MIN_BASH_VERSION}\""
        unset local_current_bash_version
        return 1
    fi
    unset local_current_bash_version
    [[ -z "${EZ_BASH_HOME}" ]] && export EZ_BASH_HOME="$(dirname ${BASH_SOURCE[0]})"
    # Source EZ-Bash Core
    source "${EZ_BASH_HOME}/src/core/basic.sh" || return 1
    source "${EZ_BASH_HOME}/src/core/function.sh" || return 1
    source "${EZ_BASH_HOME}/src/core/pipeable.sh" || return 1
    ez_self_source_option "${@:1}"
fi

unset ez_self_source_option
unset ez_self_installation
unset ez_self_unit_test
unset ez_self_version


