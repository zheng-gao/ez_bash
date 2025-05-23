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
EZ_SELF_LOGO="EZ-Bash"
EZ_SELF_VERSION="2.0.1"
EZ_SELF_REQUIRED_MIN_BASH_VERSION=5

###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
EZ_DEFAULT_DEPENDENCIES=(
    "basename"
    "bash"
    "bc"
    "column"
    "date"
    "dirname"
    "echo"
    "false"
    "grep"
    "ls"
    "mkdir"
    "mv"
    "printf"
    "pwd"
    "rm"
    "sed"
    "sort"
    "test"
    "tr"
    "true"
    "uname"
)

unset EZ_DEPENDENCY_SET
declare -g -A EZ_DEPENDENCY_SET
function ez.dependencies.check {
    local cmd; for cmd in "${@}"; do
        if [[ -z "${EZ_DEPENDENCY_SET[${cmd}]}" ]]; then
            if ! which "${cmd}" > "/dev/null"; then
                local function_stack="$(for ((i="${#FUNCNAME[@]}"-1; i>=0; i--)); do echo "${FUNCNAME[${i}]}"; done | tr '\n' '.')"
                echo -e "[${EZ_SELF_LOGO}][\e[31mERROR\e[0m][${function_stack:0:-1}] Command \"${cmd}\" not found!"
                return 1
            fi
            EZ_DEPENDENCY_SET["${cmd}"]="${EZ_TRUE}"
        fi
    done
}

function ez.dependencies.show {
    local dependency; for dependency in "${!EZ_DEPENDENCY_SET[@]}"; do echo "${dependency}"; done
}

ez.dependencies.check "${EZ_DEFAULT_DEPENDENCIES[@]}"

###################################################################################################
# ------------------------------------------ Utilities ------------------------------------------ #
###################################################################################################
function ez.self.install {
    local ez_bash_home="${1}" uninstall="${2}"
    local bash_profile="${HOME}/.bash_profile" bashrc="${HOME}/.bashrc"
    if [[ -n "${uninstall}" ]]; then  # Uninstall
        if [[ -f "${bash_profile}" ]]; then
            if grep "ez.sh" "${bash_profile}" > "/dev/null"; then
                grep -v "ez.sh" < "${bash_profile}" > "${bash_profile}.new"
                mv "${bash_profile}.new" "${bash_profile}"
            else
                echo -e "[${EZ_SELF_LOGO}][\e[31mERROR\e[0m] ${EZ_SELF_LOGO} not found!" && return 1
            fi
        elif [[ -f "${bashrc}" ]]; then
            if grep "ez.sh" "${bashrc}" > "/dev/null"; then
                grep -v "ez.sh" < "${bashrc}" > "${bashrc}.new"
                mv "${bashrc}.new" "${bashrc}"
            else
                echo -e "[${EZ_SELF_LOGO}][\e[31mERROR\e[0m] ${EZ_SELF_LOGO} not found!" && return 1
            fi
        fi
        echo "[${EZ_SELF_LOGO}][INFO] Uninstallation Complete!"
        echo "[${EZ_SELF_LOGO}][INFO] Please restart all the existing terminals."
    else  # Install
        if [[ -f "${bash_profile}" ]]; then
            if grep "ez.sh" "${bash_profile}" > "/dev/null"; then
                echo -e "[${EZ_SELF_LOGO}][\e[31mERROR\e[0m] ${EZ_SELF_LOGO} was previously installed!" && return 1
            else
                echo -e "source ${ez_bash_home}/ez.sh --all\n" >> "${bash_profile}"
                source "${bash_profile}"
            fi
        elif [[ -f "${bashrc}" ]]; then
            if grep "ez.sh" "${bashrc}" > "/dev/null"; then
                echo -e "[${EZ_SELF_LOGO}][\e[31mERROR\e[0m] ${EZ_SELF_LOGO} was previously installed!" && return 1
            else
                echo -e "source ${ez_bash_home}/ez.sh --all\n" >> "${bashrc}"
                source "${bashrc}"
            fi
        fi
        echo "[${EZ_SELF_LOGO}][INFO] Installation Complete!"
        echo "[${EZ_SELF_LOGO}][INFO] Please restart all the other terminals."
    fi
}

function ez.self.version {
    echo
    echo "[${EZ_SELF_LOGO}]"
    echo "    Author : Zheng Gao"
    echo "    Version: ${EZ_SELF_VERSION}"
    echo "    Require: Bash v${EZ_DEFAULT_BASH_VERSION}"
    echo
}

function ez.self.test {
    local tests_dir="${1}" test_files=("${@:2}") test_file test_result test_summary has_error test_error
    local spliter="--------------------------------------------------------------------------------"
    [[ -z "${test_files}" ]] && test_files=($(ls -1 ${tests_dir} | grep -v 'utils.sh'))
    for test_file in "${test_files[@]}"; do
        if test_result=$("${tests_dir}/${test_file}"); then
            test_summary+="[✓] ${test_file}\n"
        else
            has_error="True"
            test_summary+="[\e[31m☓\e[0m] ${test_file}\n"
            test_error+="${spliter}\n\e[31mError\e[0m in ${test_file}\n${spliter}\n${test_result}"
        fi
    done
    echo -e "${spliter}\n[Test Summary]\n${spliter}\n${test_summary}"
    [[ -n "${has_error}" ]] && echo -e "${test_error}\n"
}

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
function ez.self.source {
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
                while [[ -n "${1}" ]]; do ez.includes "${1}" "${args[@]}" && break; import_libs+=("${1}"); shift; done ;;
            "-s" | "--skip") shift;
                while [[ -n "${1}" ]]; do ez.includes "${1}" "${args[@]}" && break; skip_libs+=("${1}"); shift; done ;;
            *) log_error "Unknown argument identifier \"${1}\""; return 1 ;;
        esac
    done
    # Source Other Libs, echo to stderr (>&2) to unblock rsync.
    if [[ -n "${all_flag}" ]]; then
        ez.source --path "${EZ_BASH_HOME}/src/libs" || return 1
        [[ -z "${quiet_flag}" ]] && >&2 echo -e "[${EZ_SELF_LOGO}][INFO] Imported $(ez.text.decorate -f 'Yellow' -t 'ALL') ${EZ_SELF_LOGO} libraries!"
    elif [[ -n "${skip_libs}" ]]; then
        ez.source --path "${EZ_BASH_HOME}/src/libs" --exclude "${skip_libs[@]}" || return 1
        [[ -z "${quiet_flag}" ]] && >&2 echo -e "[${EZ_SELF_LOGO}][$(ez.text.decorate -f 'Yellow' -t 'WARNING')] Imported ${EZ_SELF_LOGO}, skipping libraries $(ez.text.decorate -f 'Yellow' -t "$(ez.join ', ' ${skip_libs[@]})")"
    elif [[ -n "${import_libs}" ]]; then
        # Source the designated libraries
        local ez_library; for ez_library in "${import_libs[@]}"; do ez.source --path "${EZ_BASH_HOME}/src/libs/${ez_library}" || return 1; done
        [[ -z "${quiet_flag}" ]] && >&2 echo "[${EZ_SELF_LOGO}][INFO] Imported ${EZ_SELF_LOGO} libraries: ${@}"
    else
        [[ -z "${quiet_flag}" ]] && >&2 echo "[${EZ_SELF_LOGO}][INFO] Imported ${EZ_SELF_LOGO} core"
    fi
}

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    # The script is being executed
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        echo
        echo "[${EZ_SELF_LOGO}]"
        echo "    -i|--install                        Install ${EZ_SELF_LOGO}"
        echo "    -u|--uninstall                      Uninstall ${EZ_SELF_LOGO}"
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
        "-t" | "--test") ez.self.test "$(dirname ${0})/tests" "${@:2}" ;;
        "-i" | "--install")
            if [[ "$(dirname ${0})" = "." ]]; then
                ez.self.install "$(pwd)"
            else
                ez.self.install "$(pwd)/$(dirname ${0})"
            fi ;;
        "-u" | "--uninstall")
            if [[ "$(dirname ${0})" = "." ]]; then
                ez.self.install "$(pwd)" "uninstall"
            else
                ez.self.install "$(pwd)/$(dirname ${0})" "uninstall"
            fi ;;
        "-v" | "--version") ez.self.version ;;
        *) echo -e "[${EZ_SELF_LOGO}][\e[31mERROR\e[0m] Unknown argument identifier \"${1}\"" && exit 1 ;;
    esac
else
    # The script is being sourced
    local_current_bash_version="$(bash --version | sed -nre 's/^[^0-9]*(([0-9]+\.)+[0-9]+).*/\1/p' | cut -c1-1)"
    if [[ "${local_current_bash_version}" -lt "${EZ_SELF_REQUIRED_MIN_BASH_VERSION}" ]]; then
        echo -e "[${EZ_SELF_LOGO}][\e[31mERROR\e[0m] Current Bash Version \"${local_current_bash_version}\", Required Min Bash Version: \"${EZ_SELF_REQUIRED_MIN_BASH_VERSION}\""
        unset local_current_bash_version
        return 1
    fi
    unset local_current_bash_version
    [[ -z "${EZ_BASH_HOME}" ]] && export EZ_BASH_HOME="$(dirname ${BASH_SOURCE[0]})"
    # Source EZ-Bash Core
    source "${EZ_BASH_HOME}/src/core/alias.sh" || return 1
    source "${EZ_BASH_HOME}/src/core/basic.sh" || return 1
    source "${EZ_BASH_HOME}/src/core/function.sh" || return 1
    if [[ -n "${@:1}" ]]; then ez.self.source "${@:1}" || return 1; fi
fi

unset ez.self.source
unset ez.self.install
unset ez.self.test
unset ez.self.version


