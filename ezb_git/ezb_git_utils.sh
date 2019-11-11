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
            *) ez_print_log -l ERROR -m "Unknown argument \"$1\""; ez_print_usage "${usage_string}"; return 1; ;;
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
    git -C "${repo_path}" config diff.renameLimit 999999
    git -C "${repo_path}" log --numstat --first-parent master --no-merges --date="${date_option}" --pretty="format:[%ad] [%H] [%an] [%ae]"
}


function ez_git_file_stats() {
    local valid_operation=("all" "exclude-head-files" "only-head-files")
    local valid_operation_string=$(ez_print_array_with_delimiter -d ", " -a "${valid_operation[@]}")
    local usage_string=$(ez_build_usage -o "init" -a "ez_git_repo_file_stats" -d "Print files in git history")
    usage_string+=$(ez_build_usage -o "add" -a "-o|--operation" -d "Choose from [${valid_operation_string}], default = \"all\"")
    usage_string+=$(ez_build_usage -o "add" -a "-r|--repo-path" -d "Repo path")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local operation="all"
    local repo_path=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-r" | "--repo-path") shift; repo_path=${1-} ;;
            "-o" | "--operation") shift; operation=${1-} ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if [[ $(ez_command_check -c "git") == "${EZ_BASH_BOOL_FALSE}" ]]; then ez_print_log -l ERROR -m "Command \"git\" Not Found"; return 1; fi
    if ! ez_argument_check -n "-o|--operation" -v "${operation}" -c "${valid_operation[@]}" -o "${usage_string}"; then return 1; fi
    if ! ez_nonempty_check -n "-r|--repo-path" -v "${repo_path}" -o "${usage_string}"; then return 1; fi
    if [ ! -e "${repo_path}" ]; then ez_print_log -l ERROR -m "\"${repo_path}\" Not Found!"; return 1; fi
    if [[ "${operation}" == "only-head-files" ]]; then
         git -C "${repo_path}" ls-tree -r -t -l --full-name HEAD | sort -n -k 4 | awk -F ' ' '{print $3" "$4" "$5}' | column -t
    else
        local log_file="/var/tmp/ez_git_file_stats.log"
        git -C "${repo_path}" rev-list --objects --all \
        | git -C "${repo_path}" cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
        | sed -n 's/^blob //p' \
        | sort --numeric-sort --key=2 \
        | $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest > "${log_file}"
        if [[ "${operation}" == "all" ]]; then
            cat "${log_file}"
        elif [[ "${operation}" == "exclude-head-files" ]]; then
            declare -A file_hashes_in_head
            for line in $(git -C "${repo_path}" ls-tree -r HEAD | awk '{print $3}'); do
                file_hashes_in_head["${line}"]="true"
            done
            while read -r line; do
                local hash=$(echo "${line}" | cut -d ' ' -f 1)
                if [ ! ${file_hashes_in_head["${hash}"]+_} ]; then echo "$line"; fi
            done < "${log_file}"
        fi
    fi
}