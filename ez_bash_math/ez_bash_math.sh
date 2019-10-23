###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
[ -z "${EZ_BASH_HOME}" ] && echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!" && exit 1

###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
export EZ_BASH_MATH_SCALE=6

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_math() {
    bc <<< "scale=${EZ_BASH_MATH_SCALE}; ${@}"
}