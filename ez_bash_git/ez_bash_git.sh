#!/usr/bin/env bash
###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################

THIS_SCRIPT_NAME="ez_bash_git.sh"
if [[ "${0}" != "-bash" ]]; then
    RUNNING_SCRIPT=$(basename "${0}")
    if [[ "${RUNNING_SCRIPT}" == "${THIS_SCRIPT_NAME}" ]]; then
        echo "[EZ-BASH][ERROR] ${THIS_SCRIPT_NAME} is not runnable!"
    fi
else
    if [[ "${EZ_BASH_HOME}" == "" ]]; then
        # For other script to source
        echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"
        exit 1
    fi
fi

###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
if ! source "${EZ_BASH_HOME}/ez_bash_log/ez_bash_log.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_variables/ez_bash_variables.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_sanity_check/ez_bash_sanity_check.sh"; then exit 1; fi

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_git_commit_stats() {
    local valid_time_formats=("Epoch" "Datetime")
    local valid_time_formats_string=$(ez_print_array_with_delimiter -d ", " -a "${valid_time_formats[@]}")
    local usage_string=$(ez_build_usage -o "init" -a "ez_git_commit_stats" -d "Print Commit Statistics Of Git Repo")
    usage_string+=$(ez_build_usage -o "add" -a "-r|--repo-path" -d "Repo Path")
    usage_string+=$(ez_build_usage -o "add" -a "-f|--time-format" -d "Choose From: [${valid_time_formats_string}], default = Datetime")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local repo_path=""
    local time_format="Datetime"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-r" | "--repo-path") shift; repo_path=${1-} ;;
            "-f" | "--time-format") shift; time_format=${1-} ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if ! ez_argument_check -n "-f|--time-format" -v "${time_format}" -c "${valid_time_formats[@]}" -o "${usage_string}"; then return 1; fi
    if ! ez_nonempty_check -n "-r|--repo-path" -v "${repo_path}" -o "${usage_string}"; then return 1; fi
    if ! ez_command_check --silent --command "git"; then
        ez_print_log -l ERROR -m "Command \"git\" not found!"
        ez_print_usage "${usage_string}"; return 1
    fi
    local date_option="iso-strict"
    if [[ "${time_format}" == "Epoch" ]]; then date_option="unix"; fi
    git -C "${repo_path}" log --numstat --no-merges --date="${date_option}" --pretty="format:[%ad] [%H] [%an] [%ae]"
}
