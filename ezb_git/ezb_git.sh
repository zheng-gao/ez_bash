###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
if ! ezb_dependency_check "git"; then return 1; fi

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ezb_git_commit_stats() {
    if ! ezb_function_exist; then
        local valid_time_formats=("Epoch" "Datetime")
        ezb_arg_set --short "-r" --long "--repo-path" --required --info "Path to the git repo directory" &&
        ezb_arg_set --short "-t" --long "--time-format" --required --default "Datetime" --choices "${valid_time_formats[@]}" || return 1
    fi
    ezb_function_usage "${@}" && return
    local repo_path; repo_path="$(ezb_arg_get --short "-r" --long "--repo-path" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local time_format; time_format="$(ezb_arg_get --short "-t" --long "--time-format" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    [[ ! -d "${repo_path}" ]] && ezb_log_error "\"${repo_path}\" Not Found!" && return 1
    local date_option="iso-strict"
    [[ "${time_format}" = "Epoch" ]] && date_option="unix"
    git -C "${repo_path}" config diff.renameLimit 999999
    git -C "${repo_path}" log --numstat --first-parent master --no-merges --date="${date_option}" --pretty="format:[%ad] [%H] [%an] [%ae]"
}


function ezb_git_file_stats() {
    if ! ezb_function_exist; then
        local valid_operations=("${EZB_OPT_ALL}" "ExcludeHeadFiles" "OnlyHeadFiles")
        ezb_arg_set --short "-r" --long "--repo-path" --required --info "Path to the git repo directory" &&
        ezb_arg_set --short "-o" --long "--operation" --required --default "${EZB_OPT_ALL}" --choices "${valid_operations[@]}" || return 1
    fi
    ezb_function_usage "${@}" && return
    local repo_path; repo_path="$(ezb_arg_get --short "-r" --long "--repo-path" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local operation; operation="$(ezb_arg_get --short "-o" --long "--operation" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    [[ ! -d "${repo_path}" ]] && ezb_log_error "\"${repo_path}\" Not Found!" && return 1
    if [[ "${operation}" = "OnlyHeadFiles" ]]; then
         git -C "${repo_path}" ls-tree -r -t -l --full-name HEAD | sort -n -k 4 | awk -F ' ' '{print $3" "$4" "$5}' | column -t
    else
        local log_file="${EZB_DIR_LOGS}/${FUNCNAME[0]}.log"
        git -C "${repo_path}" rev-list --objects --all \
        | git -C "${repo_path}" cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
        | sed -n 's/^blob //p' \
        | sort --numeric-sort --key=2 \
        | $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest > "${log_file}"
        if [[ "${operation}" = "${EZB_OPT_ALL}" ]]; then
            cat "${log_file}"
        elif [[ "${operation}" = "ExcludeHeadFiles" ]]; then
            declare -A file_hashes_in_head
            local line=""; for line in $(git -C "${repo_path}" ls-tree -r HEAD | awk '{print $3}'); do
                file_hashes_in_head["${line}"]="true"
            done
            while read -r line; do
                local hash=$(echo "${line}" | cut -d ' ' -f 1)
                if [ ! ${file_hashes_in_head["${hash}"]+_} ]; then echo "$line"; fi
            done < "${log_file}"
        fi
    fi
}
