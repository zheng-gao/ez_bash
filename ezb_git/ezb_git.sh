###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ezb_dependency_check "git" "sort" "awk" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ezb_git_flow() {
    echo
    echo "           + \----------------------------------\  +                               "
    echo "           |  >>>>>>>>>>> commit -a >>>>>>>>>>>>>> |                               "
    echo "           + /-----------------+----------------/  +                               "
    echo "           |                   |                   |                               "
    echo "           + \--------------\  | \--------------\  +                               "
    echo "           |  >>> add (-u) >>> |  >>>> commit >>>> |                               "
    echo "           + /--------------/  | /--------------/  +                               "
    echo "           |                   |                   |                               "
    echo "           |                   |                   + \--------------\  +           "
    echo "           |                   |                   |  >>>> push >>>>>> |           "
    echo "           |                   |                   + /--------------/  +           "
    echo "           |                   |                   |                   |           "
    echo "    +------+------+     +------+------+     +------+------+     +------+------+    "
    echo "    |             |     |             |     |    Local    |     |   Remote    |    "
    echo "    |  Workspace  |     |    Index    |     |             |     |             |    "
    echo "    |             |     |             |     |  Repository |     |  Repository |    "
    echo "    +------+------+     +------+------+     +------+------+     +------+------+    "
    echo "           |                   |                   |                   |           "
    echo "           +  /----------------+-------------------+-----------------/ +           "
    echo "           | <<<<<<<<<<<<<<<<<<<< pull or rebase <<<<<<<<<<<<<<<<<<<<  |           "
    echo "           +  \----------------+-------------------+-----------------\ +           "
    echo "           |                   |                   |                   |           "
    echo "           |                   |                   +  /--------------/ +           "
    echo "           |                   |                   | <<<<< fetch <<<<  |           "
    echo "           |                   |                   +  \--------------\ +           "
    echo "           |                   |                   |                               "
    echo "           +  /----------------+-----------------/ +                               "
    echo "           | <<<<<<<<<<< checkout HEAD <<<<<<<<<<  |                               "
    echo "           +  \----------------+-----------------\ +                               "
    echo "           |                   |                   |                               "
    echo "           +  /--------------/ +                   |                               "
    echo "           | <<< checkout <<<  |                   |                               "
    echo "           +  \--------------\ +                   |                               "
    echo "           |                   |                   |                               "
    echo "           +-------------------+-------------------+                               "
    echo "           |               diff HEAD               |                               "
    echo "           +-------------------+-------------------+                               "
    echo "           |                   |                                                   "
    echo "           +-------------------+                                                   "
    echo "           |        diff       |                                                   "
    echo "           +-------------------+                                                   "
    echo
}

function ezb_git_push_in_batches() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-b" --long "--batch-size" --default "500" --info "Number of commits in each batch" &&
        ezb_arg_set --short "-r" --long "--remote" --default "origin" --info "Git Remote" || return 1
    fi
    ezb_function_usage "${@}" && return
    local batch_size && batch_size="$(ezb_arg_get --short "-b" --long "--batch-size" --arguments "${@}")" &&
    local remote && remote="$(ezb_arg_get --short "-r" --long "--remote" --arguments "${@}")" || return 1
    local branch=$(git rev-parse --abbrev-ref HEAD) && echo "Branch: ${branch}"
    local number_of_commits=$(git log --first-parent --format=format:x HEAD | wc -l | bc) && echo "Number of Commits: ${number_of_commits}"
    local git_command=""; local git_tag=""

    # git for-each-ref --format='delete %(refname)' refs/pull | git update-ref --stdin

    # Turn Off Mirror
    git_command="git config --replace-all remote.origin.mirror false"
    echo "[Turn Off Mirror] ${git_command}" && ${git_command}
    
    # Push Each Tag
    for git_tag in $(git "tag" -l); do
        git_command="git push ${remote} refs/tags/${git_tag}"
        echo "[Push Tag] ${git_command}" && ${git_command}
    done

    # local x_th_commit_before_head=0
    # for x_th_commit_before_head in $(seq "${number_of_commits}" "-${batch_size}" "1"); do
    #     # Get the hash of the commit to push
    #     # local commit_hash=$(git log --first-parent --reverse --format=format:%H --skip "${x_th_commit_before_head}" -n1)
    #     # echo "[Pushing] git push ${remote} ${commit_hash}:refs/heads/${branch}"
    #     # git "push" "${remote}" "${commit_hash}:refs/heads/${branch}"
    #
    #     # echo "Pushing commits till $((number_of_commits - x_th_commit_before_head))-th"
    #     # git "push" "${remote}" "${branch}~${x_th_commit_before_head}:refs/heads/${branch}"
    # done

    # Turn On Mirror
    git_command="git config --replace-all remote.origin.mirror true"
    echo "[Turn On Mirror] ${git_command}" && ${git_command}

    # Final Push
    git_command="git push --mirror ${remote}"
    echo "[Final Push] ${git_command}" && ${git_command}
}

function ezb_git_commit_stats() {
    if ezb_function_unregistered; then
        local valid_time_formats=("Epoch" "Datetime")
        ezb_arg_set --short "-r" --long "--repo-path" --required --info "Path to the git repo directory" &&
        ezb_arg_set --short "-t" --long "--time-format" --required --default "Datetime" --choices "${valid_time_formats[@]}" || return 1
    fi
    ezb_function_usage "${@}" && return
    local repo_path && repo_path="$(ezb_arg_get --short "-r" --long "--repo-path" --arguments "${@}")" &&
    local time_format && time_format="$(ezb_arg_get --short "-t" --long "--time-format" --arguments "${@}")" || return 1
    [[ ! -d "${repo_path}" ]] && ezb_log_error "\"${repo_path}\" Not Found!" && return 1
    local date_option="iso-strict"
    [[ "${time_format}" = "Epoch" ]] && date_option="unix"
    git -C "${repo_path}" config diff.renameLimit 999999
    git -C "${repo_path}" log --numstat --first-parent master --no-merges --date="${date_option}" --pretty="format:[%ad] [%H] [%an] [%ae]"
}


function ezb_git_file_stats() {
    if ezb_function_unregistered; then
        local valid_operations=("${EZB_OPT_ALL}" "ExcludeHeadFiles" "OnlyHeadFiles")
        ezb_arg_set --short "-r" --long "--repo-path" --default "." --info "Path to the git repo directory" &&
        ezb_arg_set --short "-o" --long "--operation" --default "${EZB_OPT_ALL}" --choices "${valid_operations[@]}" || return 1
    fi
    ezb_function_usage --run-with-no-argument "${@}" && return
    local repo_path && repo_path="$(ezb_arg_get --short "-r" --long "--repo-path" --arguments "${@}")" &&
    local operation && operation="$(ezb_arg_get --short "-o" --long "--operation" --arguments "${@}")" || return 1
    [[ -n "${repo_path}" ]] && [[ ! -d "${repo_path}" ]] && ezb_log_error "\"${repo_path}\" Not Found!" && return 1
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

function ezb_git_remove_file_from_history() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-r" --long "--repo-path" --info "Path to the git repo directory" &&
        ezb_arg_set --short "-f" --long "--file-path" --info "Relative file path, e.g. ./test.txt" || return 1
    fi
    ezb_function_usage "${@}" && return
    local repo_path && repo_path="$(ezb_arg_get --short "-r" --long "--repo-path" --arguments "${@}")" &&
    local file_path && file_path="$(ezb_arg_get --short "-f" --long "--file-path" --arguments "${@}")" || return 1
    [[ -n "${repo_path}" ]] && [[ ! -d "${repo_path}" ]] && ezb_log_error "\"${repo_path}\" Not Found!" && return 1
    [[ -z "${repo_path}" ]] && repo_path="."
    git -C "${repo_path}" "filter-branch" -f --prune-empty --index-filter "git -C ${repo_path} rm -r --cached --ignore-unmatch ${file_path}" "HEAD"
}




