###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez.dependencies.check "openssl" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez.ssl.base64.encode { openssl base64 | tr -d "=" | tr "/+" "_-" | tr -d "\n"; }

function ez.ssl.cert {
    if ez.function.unregistered; then
        ez.argument.set --short "-h" --long "--hostname" --required --info "FQDN" &&
        ez.argument.set --short "-p" --long "--port" --required --default "443" --info "Port Number" ||
        return 1
    fi; ez.function.help "${@}" || return 0
    local hostname && hostname="$(ez.argument.get --short "-h" --long "--hostname" --arguments "${@}")" &&
    local port && port="$(ez.argument.get --short "-p" --long "--port" --arguments "${@}")" || return 1
    echo | openssl "s_client" -connect "${hostname}:${port}" -showcerts | openssl "x509" -noout -text
}

function ez.ssl.fingerprint {
    if ez.function.unregistered; then
        ez.argument.set --short "-c" --long "--cert" --required --info "File path to the cert" &&
        ez.argument.set --short "-s" --long "--sha" --required --default "SHA1" --choices "SHA1" "SHA256" --info "SHA type" ||
        return 1
    fi; ez.function.help "${@}" || return 0
    local cert && cert="$(ez.argument.get --short "-c" --long "--cert" --arguments "${@}")" &&
    local sha && sha="$(ez.argument.get --short "-s" --long "--sha" --arguments "${@}")" || return 1
    openssl "x509" -noout -fingerprint "-${sha}" -in "${cert}"
}
