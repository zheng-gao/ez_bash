###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez.time.clock {
    ez.time.now; sleep 1; while true; do ez.clear -l 1; ez.time.now; sleep 1; done
}

function ez.time.zones {
    local zone_info_dir="/usr/share/zoneinfo"
    pushd "${zone_info_dir}" > "/dev/null"
    find . -type f | sed 's@./@@' | grep '^[[:upper:]]' | sort
    popd > "/dev/null"
}

function ez.time.from_epoch_seconds {
    if ez.function.unregistered; then
        ez.argument.set --short "-e" --long "--epoch" --required --default "0" --info "Epoch Seconds" &&
        ez.argument.set --short "-f" --long "--format" --required --default "%Y-%m-%d %H:%M:%S" --info "Timestamp Format" || return 1
    fi; ez.function.help "${@}" --run-with-no-argument || return 0
    local epoch && epoch="$(ez.argument.get --short "-e" --long "--epoch" --arguments "${@}")" &&
    local format && format="$(ez.argument.get --short "-f" --long "--format" --arguments "${@}")" || return 1
    [[ "$(uname -s)" = "Darwin" ]] && date -r "${epoch}" "+${format}" || date "+${format}" -d "@${epoch}"
}

function ez.time.to_epoch_seconds {
    if ez.function.unregistered; then
        ez.argument.set --short "-t" --long "--timestamp" --info "Timestamp, default: now" &&
        ez.argument.set --short "-f" --long "--format" --default "%Y-%m-%d %H:%M:%S" --info "Timestamp Format" || return 1
    fi; ez.function.help "${@}" --run-with-no-argument || return 0
    local timestamp && timestamp="$(ez.argument.get --short "-t" --long "--timestamp" --arguments "${@}")" &&
    local format && format="$(ez.argument.get --short "-f" --long "--format" --arguments "${@}")" || return 1
    if [[ -n "${timestamp}" ]]; then
        [[ "$(uname -s)" = "Darwin" ]] && date -j -f "${format}" "${timestamp}" "+%s" || date -d "${timestamp}" "+%s"
    else
        [[ "$(uname -s)" = "Darwin" ]] && date -j "+%s" || date "+%s"
    fi
}

function ez.time.offset {
    if ez.function.unregistered; then
        ez.argument.set --short "-t" --long "--timestamp" --required --info "Base Timestamp" &&
        ez.argument.set --short "-f" --long "--format" --required --default "%Y-%m-%d %H:%M:%S" --info "Timestamp Format" &&
        ez.argument.set --short "-u" --long "--unit" --required --default "seconds" --choices "seconds" "minutes" "hours" "days" "weeks" --info "Offset Unit" &&
        ez.argument.set --short "-o" --long "--offset" --required --default "0" --info "Offset Value" || return 1
    fi; ez.function.help "${@}" || return 0
    local timestamp && timestamp="$(ez.argument.get --short "-t" --long "--timestamp" --arguments "${@}")" &&
    local format && format="$(ez.argument.get --short "-f" --long "--format" --arguments "${@}")" &&
    local unit && unit="$(ez.argument.get --short "-u" --long "--unit" --arguments "${@}")" &&
    local offset && offset="$(ez.argument.get --short "-o" --long "--offset" --arguments "${@}")" || return 1
    local unit_value=0 epoch_seconds=$(ez.time.to_epoch_seconds --timestamp "${timestamp}" --format "${format}")
    case "${unit}" in
        "seconds") unit_value=1 ;;
        "minutes") unit_value=60 ;;
          "hours") unit_value=3600 ;;
           "days") unit_value=86400 ;;
          "weeks") unit_value=604800 ;;
                *) unit_value=0 ;;
    esac
    ((epoch_seconds += unit_value * offset))
    ez.time.from_epoch_seconds --epoch "${epoch_seconds}" --format "${format}"
}

function ez.time.seconds_to_readable {
    if ez.function.unregistered; then
        local output_formats=("Short" "Long")
        ez.argument.set --short "-s" --long "--seconds" --required --default "0" --info "Input Seconds" &&
        ez.argument.set --short "-f" --long "--format" --required --default "Short" --choices "${output_formats[@]}" || return 1
    fi; ez.function.help "${@}" || return 0
    local seconds && seconds="$(ez.argument.get --short "-s" --long "--seconds" --arguments "${@}")" &&
    local format && format="$(ez.argument.get --short "-f" --long "--format" --arguments "${@}")" || return 1
    local output=""
    if [[ "${seconds}" -lt 0 ]]; then
        seconds="${seconds:1}"
        output="-"
    fi
    local days=$((seconds / 86400))
    local hours=$((seconds / 3600 % 24))
    local minutes=$((seconds / 60 % 60))
    local seconds=$((seconds % 60))
    if [ ${days} -gt 0 ]; then [[ "${format}" = "Short" ]] && output+="${days}d" || output+="${days} Days "; fi
    if [ ${hours} -gt 0 ]; then [[ "${format}" = "Short" ]] && output+="${hours}h" || output+="${hours} Hours "; fi
    if [ ${minutes} -gt 0 ]; then [[ "${format}" = "Short" ]] && output+="${minutes}m" || output+="${minutes} Minutes "; fi
    if [ ${seconds} -ge 0 ]; then [[ "${format}" = "Short" ]] && output+="${seconds}s" || output+="${seconds} Seconds"; fi
    echo "${output}"
}

function ez.time.elapsed.epoch {
    if ez.function.unregistered; then
        ez.argument.set --short "-s" --long "--start" --required --info "Start Time Epoch Seconds" &&
        ez.argument.set --short "-e" --long "--end" --required --info "End Time Epoch Seconds" || return 1
    fi; ez.function.help "${@}" || return 0
    local start && start="$(ez.argument.get --short "-s" --long "--start" --arguments "${@}")" &&
    local end && end="$(ez.argument.get --short "-e" --long "--end" --arguments "${@}")" || return 1
    ez.time.seconds_to_readable --seconds "$((end - start))"
}

function ez.time.elapsed {
    if ez.function.unregistered; then
        ez.argument.set --short "-s" --long "--start" --required --info "Start Timestamp" &&
        ez.argument.set --short "-e" --long "--end" --required --info "End Timestamp" &&
        ez.argument.set --short "-f" --long "--format" --required --default "%Y-%m-%d %H:%M:%S" --info "Timestamp Format" || return 1
    fi; ez.function.help "${@}" || return 0
    local start && start="$(ez.argument.get --short "-s" --long "--start" --arguments "${@}")" &&
    local end && end="$(ez.argument.get --short "-e" --long "--end" --arguments "${@}")" &&
    local format && format="$(ez.argument.get --short "-f" --long "--format" --arguments "${@}")" || return 1
    local start_epoch_seconds=$(ez.time.to_epoch_seconds --timestamp "${start}" --format "${format}")
    local end_epoch_seconds=$(ez.time.to_epoch_seconds --timestamp "${end}" --format "${format}")
    ez.time.seconds_to_readable --seconds "$((end_epoch_seconds - start_epoch_seconds))" --format "Long"
}




