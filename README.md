# Pure Shell Tools for Linux & MacOS
## Full Installation
```shell
git clone https://github.com/zheng-gao/ez_bash.git
ez_bash/ez.sh --install  # Import all the libraries and update ~/.bashrc or ~/.bash_profile
ez_bash/ez.sh --test     # Run unit test
```
## Partial Installation
#### 1. Clone the project
```shell
git clone https://github.com/zheng-gao/ez_bash.git
````
#### 2. Set variable [__EZ_BASH_HOME__](https://github.com/zheng-gao/ez_bash/blob/master/ez.sh#L10)
```shell
export EZ_BASH_HOME="$(pwd)/ez_bash"
```
#### 3. Import "ezb" libraries
```shell
source "${EZ_BASH_HOME}/ez.sh"                    # Import core functions only
source "${EZ_BASH_HOME}/ez.sh" "lib1" "lib2" ...  # Import "ezb" libraries (including core)
source "${EZ_BASH_HOME}/ez.sh" --all              # Import ALL "ezb" libraries (including core)
```
#### 4. Check "ezb" variables & functions
```shell
ez_variables
ez_functions
```
# Contents
* [Function](docs/function.md)
* [Math](docs/math.md)
* [Table](docs/table.md)
* [Time](docs/time.md)
* [SSH](docs/ssh.md)
* [URL](docs/url.md)
* [Version](docs/version.md)

