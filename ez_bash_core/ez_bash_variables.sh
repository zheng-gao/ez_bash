###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
[ -z "${EZ_BASH_HOME}" ] && echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!" && exit 1

###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
export EZ_BASH_LOG_LOGO="EZ-BASH"
export EZ_BASH_TAB_SIZE="30"
export EZ_BASH_BOOL_TRUE="True"
export EZ_BASH_BOOL_FALSE="False"
export EZ_BASH_SHARP="SHARP"
export EZ_BASH_SPACE="SPACE"
export EZ_BASH_ALL="ALL"
export EZ_BASH_NONE="NONE"

export EZ_BASH_WORKSPACE="/var/tmp/ez_bash_workspace"; mkdir -p "${EZ_BASH_WORKSPACE}"
export EZ_BASH_LOGS="${EZ_BASH_WORKSPACE}/logs"; mkdir -p "${EZ_BASH_LOGS}"
export EZ_BASH_DATA="${EZ_BASH_WORKSPACE}/data"; mkdir -p "${EZ_BASH_DATA}"
