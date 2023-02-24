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
EZ_DEFAULT_BASH_VERSION="5"

###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
EZ_DEFAULT_DEPENDENCIES=(
    "alias"
    "basename"
    "bash"
    "column"
    "date"
    "dirname"
    "echo"
    "false"
    "grep"
    "mkdir"
    "mv"
    "printf"
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
            hash "${cmd}" || return 1
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
function ez_self_verification {
    if [[ -z "${EZ_BASH_HOME}" ]]; then
        echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] \e[33mEZ_BASH_HOME\e[0m is not set!" && return 1
    elif [[ ! -d "${EZ_BASH_HOME}" ]]; then
        echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] Invalid directory \"${EZ_BASH_HOME}\"" && return 1
    elif [[ ! "$(basename ${EZ_BASH_HOME})" = "ez_bash" ]]; then
        echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] Invalid \e[33mEZ_BASH_HOME\e[0m: ${EZ_BASH_HOME}" && return 1
    fi
}

function ez_self_installation {
    local ez_bash_home="${1}" uninstall="${2}"
    local bash_profile="${HOME}/.bash_profile" bashrc="${HOME}/.bashrc"
    if [[ -n "${uninstall}" ]]; then
        if [[ -f "${bash_profile}" ]]; then
            if grep "^export EZ_BASH_HOME=" "${bash_profile}" > "/dev/null"; then
                grep -v "^export EZ_BASH_HOME=" < "${bash_profile}" > "${bash_profile}.new"
                mv "${bash_profile}.new" "${bash_profile}"
            else
                echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] ${EZ_LOGO} not found!" && return 1
            fi
        elif [[ -f "${bashrc}" ]]; then
            if grep "^export EZ_BASH_HOME=" "${bashrc}" > "/dev/null"; then
                grep -v "^export EZ_BASH_HOME=" < "${bashrc}" > "${bashrc}.new"
                mv "${bashrc}.new" "${bashrc}"
            else
                echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] ${EZ_LOGO} not found!" && return 1
            fi
        fi
        echo "[${EZ_LOGO}][INFO] Uninstalled ${EZ_LOGO}!"
        echo "[${EZ_LOGO}][INFO] Please restart all the existing terminals."
    else
        if [[ -f "${bash_profile}" ]]; then
            if grep "^export EZ_BASH_HOME=" "${bash_profile}" > "/dev/null"; then
                echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] ${EZ_LOGO} was previously installed!" && return 1
            else
                echo -e "export EZ_BASH_HOME=${ez_bash_home}; source ${ez_bash_home}/ez.sh --all\n" >> "${bash_profile}"
                source "${bash_profile}"
            fi
        elif [[ -f "${bashrc}" ]]; then
            if grep "^export EZ_BASH_HOME=" "${bashrc}" > "/dev/null"; then
                echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] ${EZ_LOGO} was previously installed!" && return 1
            else
                echo -e "export EZ_BASH_HOME=${ez_bash_home}; source ${ez_bash_home}/ez.sh --all\n" >> "${bashrc}"
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
    if ! ez_self_verification; then return 1; fi
    local tests_dir="${1}" test_file test_result test_summary has_error test_error
    local spliter="--------------------------------------------------------------------------------"
    for test_file in $(ls -1 ${tests_dir} | grep -v 'utils.sh'); do
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
if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    # The script is being executed
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        echo
        echo "[${EZ_LOGO}]"
        echo "    -t|--test         Run unit test"
        echo "    -i|--install      Install ${EZ_LOGO}"
        echo "    -u|--uninstall    Uninstall ${EZ_LOGO}"
        echo "    -v|--version      Show version info"
        echo
        exit 0
    fi
    case "${1}" in
        "-t" | "--test") ez_self_unit_test "$(dirname ${0})/tests" ;;
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
    if ! ez_self_verification; then return 1; fi
    bash --version | grep "version ${EZ_DEFAULT_BASH_VERSION}\." &> "/var/tmp/null" || {
        echo -e "[${EZ_LOGO}][\e[31mERROR\e[0m] \"Bash ${EZ_DEFAULT_BASH_VERSION}\" not found!"; return 1
    }
    rm -f "/var/tmp/null"
    # Source EZ-Bash Core
    source "${EZ_BASH_HOME}/src/core/basic.sh" || return 1
    source "${EZ_BASH_HOME}/src/core/function.sh" || return 1
    source "${EZ_BASH_HOME}/src/core/pipeable.sh" || return 1
    # Source Other Libs
    if [[ -z "${1}" ]]; then
        echo "[${EZ_LOGO}][INFO] Imported ${EZ_LOGO} core"
    elif [[ "${1}" = "--all" ]]; then
        # By default source ALL other libs
        ez_source_dir --path "${EZ_BASH_HOME}/src/libs" || return 1
        echo -e "[${EZ_LOGO}][INFO] Imported $(ez_string_format 'ForegroundYellow' 'ALL') ${EZ_LOGO} libraries!"
    else
        # Source the designated libraries
        for ez_library in "${@}"; do
            ez_source_dir --path "${EZ_BASH_HOME}/src/libs/${ez_library}" || return 1
        done
        unset ez_library
        echo "[${EZ_LOGO}][INFO] Imported ${EZ_LOGO} libraries: ${@}"
    fi
fi

unset ez_self_installation
unset ez_self_verification
unset ez_self_unit_test
unset ez_self_version


