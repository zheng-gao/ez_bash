###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez_dependency_check "docker" || return 1


###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
# docker ps --format "${EZ_DOCKER_PS_FORMAT}"
EZ_DOCKER_PS_FORMAT="\nID\t{{.ID}}\nIMAGE\t{{.Image}}\nCOMMAND\t{{.Command}}\nCREATED\t{{.RunningFor}}\nSTATUS\t{{.Status}}\nPORTS\t{{.Ports}}\nNAMES\t{{.Names}}\n"
###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_docker_ps {
	docker ps --format "${EZ_DOCKER_PS_FORMAT}"
}

