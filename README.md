# Pure Shell Tools for Linux & MacOS
## Full Installation
```shell
git clone https://github.com/zheng-gao/ez_bash.git
ez_bash/ez.sh --install  # Import all the libraries and update ~/.bashrc or ~/.bash_profile
ez_bash/ez.sh --test     # Run unit tests
```
## Partial Installation
#### 1. Clone Repo
```shell
git clone https://github.com/zheng-gao/ez_bash.git
````
#### 2. Set Environment
```shell
export EZ_BASH_HOME="$(pwd)/ez_bash"
```
#### 3. Import Libraries
```shell
source "${EZ_BASH_HOME}/ez.sh"                             # Import core functions only
source "${EZ_BASH_HOME}/ez.sh" --import "lib1" "lib2" ...  # Import libraries (including core)
source "${EZ_BASH_HOME}/ez.sh" --all                       # Import ALL libraries (including core)
source "${EZ_BASH_HOME}/ez.sh" --skip "lib1" "lib2"        # Import ALL libraries (including core) but skip some libraries
```
#### 4. Show Commands
```shell
ez_show_pipeables
ez_show_variables
ez_show_functions
```

# Contents
* [Function](docs/function.md)
* [Math](docs/math.md)
* [Table](docs/table.md)
* [Time](docs/time.md)
* [SSH](docs/ssh.md)
* [URL](docs/url.md)
* [Version](docs/version.md)

