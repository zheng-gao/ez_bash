###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez.dependencies.check "git" "awk" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez.git.flow {
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

function ez.git.push.batches {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-b" --long "--batch-size" --default "500" --info "Number of commits in each batch" &&
        ez.argument.set --short "-r" --long "--remote" --default "origin" --info "Git Remote" || return 1
    fi; ez.function.help "${@}" && return
    local batch_size && batch_size="$(ez.argument.get --short "-b" --long "--batch-size" --arguments "${@}")" &&
    local remote && remote="$(ez.argument.get --short "-r" --long "--remote" --arguments "${@}")" || return 1
    local branch=$(git rev-parse --abbrev-ref HEAD) && echo "Branch: ${branch}"
    local number_of_commits=$(git log --first-parent --format=format:x HEAD | wc -l | bc) && echo "Number of Commits: ${number_of_commits}"
    local git_command=""

    # git for-each-ref --format='delete %(refname)' refs/pull | git update-ref --stdin

    # Turn Off Mirror
    git_command="git config --replace-all remote.origin.mirror false"
    echo "[Turn Off Mirror] ${git_command}" && ${git_command}
    
    # Push Each Tag
    local git_tag; for git_tag in $(git "tag" -l); do
        git_command="git push ${remote} refs/tags/${git_tag}"
        echo "[Push Tag] ${git_command}" && ${git_command}
    done

    # local x_th_commit_before_head=0; for x_th_commit_before_head in $(seq "${number_of_commits}" "-${batch_size}" "1"); do
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

function ez.git.commit.stats {
    if ez.function.is_unregistered; then
        local valid_time_formats=("Epoch" "Datetime")
        ez.argument.set --short "-r" --long "--repo-path" --required --info "Path to the git repo directory" &&
        ez.argument.set --short "-t" --long "--time-format" --required --default "Datetime" --choices "${valid_time_formats[@]}" || return 1
    fi; ez.function.help "${@}" && return
    local repo_path && repo_path="$(ez.argument.get --short "-r" --long "--repo-path" --arguments "${@}")" &&
    local time_format && time_format="$(ez.argument.get --short "-t" --long "--time-format" --arguments "${@}")" || return 1
    [[ ! -d "${repo_path}" ]] && ez.log.error "\"${repo_path}\" Not Found!" && return 1
    local date_option="iso-strict"
    [[ "${time_format}" = "Epoch" ]] && date_option="unix"
    git --git-dir "${repo_path}" config diff.renameLimit 999999
    git --git-dir "${repo_path}" log --numstat --first-parent master --no-merges --date="${date_option}" --pretty="format:[%ad] [%H] [%an] [%ae]"
}


function ez.git.file.stats {
    if ez.function.is_unregistered; then
        local valid_operations=("${EZ_ALL}" "ExcludeHeadFiles" "OnlyHeadFiles")
        ez.argument.set --short "-r" --long "--repo-path" --default "." --info "Path to the git repo directory" &&
        ez.argument.set --short "-o" --long "--operation" --default "${EZ_ALL}" --choices "${valid_operations[@]}" || return 1
    fi; ez.function.help --run-with-no-argument "${@}" && return
    local repo_path && repo_path="$(ez.argument.get --short "-r" --long "--repo-path" --arguments "${@}")" &&
    local operation && operation="$(ez.argument.get --short "-o" --long "--operation" --arguments "${@}")" || return 1
    [[ -n "${repo_path}" ]] && [[ ! -d "${repo_path}" ]] && ez.log.error "\"${repo_path}\" Not Found!" && return 1
    if [[ "${operation}" = "OnlyHeadFiles" ]]; then
         git --git-dir "${repo_path}" ls-tree -r -t -l --full-name HEAD | sort -n -k 4 | awk -F ' ' '{print $3" "$4" "$5}' | column -t
    else
        local log_file="${EZ_DIR_LOGS}/${FUNCNAME[0]}.log"
        git --git-dir "${repo_path}" rev-list --objects --all \
        | git --git-dir "${repo_path}" cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
        | sed -n 's/^blob //p' \
        | sort --numeric-sort --key=2 \
        | $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest > "${log_file}"
        if [[ "${operation}" = "${EZ_ALL}" ]]; then
            cat "${log_file}"
        elif [[ "${operation}" = "ExcludeHeadFiles" ]]; then
            declare -A file_hashes_in_head
            local line; for line in $(git -C "${repo_path}" ls-tree -r HEAD | awk '{print $3}'); do
                file_hashes_in_head["${line}"]="true"
            done
            while read -r line; do
                local hash=$(echo "${line}" | cut -d ' ' -f 1)
                if [ ! ${file_hashes_in_head["${hash}"]+_} ]; then echo "$line"; fi
            done < "${log_file}"
        fi
    fi
}

function ez.git.history.remove_file {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-r" --long "--repo-path" --info "Path to the git repo directory" &&
        ez.argument.set --short "-f" --long "--file-path" --info "Relative file path, e.g. ./test.txt" || return 1
    fi; ez.function.help "${@}" && return
    local repo_path && repo_path="$(ez.argument.get --short "-r" --long "--repo-path" --arguments "${@}")" &&
    local file_path && file_path="$(ez.argument.get --short "-f" --long "--file-path" --arguments "${@}")" || return 1
    [[ -n "${repo_path}" ]] && [[ ! -d "${repo_path}" ]] && ez.log.error "\"${repo_path}\" Not Found!" && return 1
    [[ -z "${repo_path}" ]] && repo_path="."
    ez.log.info "Removing ${file_path}"
    git --git-dir "${repo_path}" "filter-branch" --force --prune-empty --index-filter "git --git-dir ${repo_path} rm --cached --ignore-unmatch ${file_path}" --tag-name-filter cat -- --all
}

function ez.git.history.large_blobs() {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-r" --long "--repo-path" --info "Path to the git repo directory" &&
        ez.argument.set --short "-b" --long "--min-bytes" --info "Find blobs larger than this bytes" || return 1
    fi; ez.function.help "${@}" && return
    local repo_path && repo_path="$(ez.argument.get --short "-r" --long "--repo-path" --arguments "${@}")" &&
    local min_bytes && min_bytes="$(ez.argument.get --short "-b" --long "--min-bytes" --arguments "${@}")" || return 1
    [[ -n "${repo_path}" ]] && [[ ! -d "${repo_path}" ]] && ez.log.error "\"${repo_path}\" Not Found!" && return 1
    [[ -z "${repo_path}" ]] && repo_path="."
    local line first_line=true
    echo "{"
    echo "    \"objects\": ["
    git --git-dir "${repo_path}" "rev-list" --objects --all | \
    git --git-dir "${repo_path}" cat-file --batch-check='%(objectname) %(objectsize) %(objecttype) %(rest)' | \
    awk '$3 == "blob" && $2 >= '${min_bytes}' {print $0}' | \
    while read line; do
        if "${first_line}"; then first_line=false; else echo ","; fi
        local array=(${line})
        local blob_size="${array[1]}"
        # blob_size=$(numfmt --to=iec-i --suffix=B --padding=7 --round=nearest "${array[1]}")
        echo "        {"
        echo "            \"name\": \"${array[@]:3}\","
        echo "            \"blob\": \"${array[0]}\","
        echo "            \"size\": \"${blob_size}\","
        echo "            \"commits\": ["
        local first_commit=true commit
        for commit in $(git --git-dir "${repo_path}" "log" --pretty="format:%H" --all --find-object="${array[0]}"); do
            if "${first_commit}"; then first_commit=false; else echo ","; fi
            echo "                {"
            echo "                    \"hash\": \"${commit}\","
            echo "                    \"branches\": ["
            local first_branch=true branch
            for branch in $(git --git-dir "${repo_path}" branch -a --contains "${commit}"); do
                if "${first_branch}"; then first_branch=false; else echo ","; fi
                echo -n "                        \"${branch}\""
            done
            if "${first_branch}"; then echo "]"; else echo; echo "                    ]"; fi
            echo -n "                }"
        done
        if "${first_commit}"; then echo "]"; else echo; echo "            ]"; fi
        echo -n "        }"
    done
    echo; echo "    ]"
    echo "}"
}


