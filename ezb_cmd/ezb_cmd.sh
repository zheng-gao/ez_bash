function ezb_cmd_md5() {
    local os=$(ezb_os_name)
    if [[ "${os}" = "macos" ]]; then
        if ! ezb_command_check "md5"; then ezb_log_error "Not found \"md5\", please run \"brew install md5\""
        else echo "md5 -q"; fi
    elif [[ "${os}" = "linux" ]]; then
        if ! ezb_command_check "md5sum"; then ezb_log_error "Not found \"md5sum\", please run \"yum install md5sum\""
        else echo "md5sum"; fi
    fi
}

function ezb_cmd_timeout() {
    local os=$(ezb_os_name)
    if [[ "${os}" = "macos" ]]; then
        if ! ezb_command_check "gtimeout"; then ezb_log_error "Not found \"gtimeout\", please run \"brew install coreutils\""
        else echo "gtimeout"; fi
    elif [[ "${os}" = "linux" ]]; then
        echo "timeout" # Should be installed by default
    fi
}
