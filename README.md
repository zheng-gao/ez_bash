# Bash Tools for Linux and MacOS
## Installation Steps
#### 1. Clone this project
```bash
git clone https://github.com/zheng-gao/ez_bash.git ${SOME_DIRECTORY}/ez_bash
```
#### 2. Setup environment variable: [__EZ_BASH_HOME__](https://github.com/zheng-gao/ez_bash)
```bash
export EZ_BASH_HOME="${SOME_DIRECTORY}/ez_bash"
```
#### 3. Import "ezb" libraries
##### a. Import core functions only
```bash
source "${EZ_BASH_HOME}/ezb.sh"
```
##### b. Import other "ezb" libraries (including core)
```bash
source "${EZ_BASH_HOME}/ezb.sh" "lib1" "lib2" ...
```
##### c. Import ALL "ezb" libraries (including core)
```bash
source "${EZ_BASH_HOME}/ezb.sh" --all
```
# Contents
* [Function](docs/function.md)
* [Math](docs/math.md)
* [Table](docs/table.md)
* [Time](docs/time.md)
* [SSH](docs/ssh.md)
* [URL](docs/url.md)
* [Version](docs/version.md)

