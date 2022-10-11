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
##### a. Import ezb_core only
```bash
source "${EZ_BASH_HOME}/ez_bash.sh"
```
##### b. Import other "ezb" libraries (include ezb_core)
```bash
source "${EZ_BASH_HOME}/ez_bash.sh" "lib_1" "lib_2" ...
```
##### c. Import ALL "ezb" libraries (include ezb_core)
```bash
source "${EZ_BASH_HOME}/ez_bash.sh" --all
```
# Contents
* [Function](ezb_core/ezb_function.md)
* [Math](ezb_math/ezb_math.md)
* [Time](ezb_time/ezb_time.md)
