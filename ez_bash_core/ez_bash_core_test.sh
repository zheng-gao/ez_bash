#!/usr/bin/env bash

###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_core/ez_bash_core.sh"; then exit 1; fi

###################################################################################################
# --------------------------------------- Main Function ----------------------------------------- #
###################################################################################################
THIS_TEST_FILE_NAME="ez_bash_core_test.sh"

argument_list=("--name" "EZ-BASH" "--bool-item1" "--list-1" "1" "-2" "3" "-l" "a" "bb" "-v" "Hello World" "--another-list")

my_list=("1" "-2" "3")
index=0
for item in $(ez_get_argument --ez-argument-type "List" --ez-long-identifier "--list-1" --ez-argument-list "${argument_list[@]}"); do
    if [[ "${my_list[${index}]}" != "${item}" ]]; then echo "[${THIS_TEST_FILE_NAME}][ERROR] \"${item}\" != \"${my_list[${index}]}\""; exit 1; fi
    ((index++))
done

my_list=("a" "bb")
index=0
for item in $(ez_get_argument --ez-argument-type "List" --ez-argument-list "${argument_list[@]}" --ez-short-identifier "-l"); do
    if [[ "${my_list[${index}]}" != "${item}" ]]; then echo "[${THIS_TEST_FILE_NAME}][ERROR] \"${item}\" != \"${my_list[${index}]}\""; exit 1; fi
    ((index++))
done

my_list=()
index=0
for item in $(ez_get_argument --ez-argument-list "${argument_list[@]}" --ez-long-identifier "--another-list" --ez-argument-type "List"); do
    if [[ "${my_list[${index}]}" != "${item}" ]]; then echo "[${THIS_TEST_FILE_NAME}][ERROR] \"${item}\" != \"${my_list[${index}]}\""; exit 1; fi
    ((index++))
done

default_list=("LIST" "NOT" "FOUND")
index=0
for item in $(ez_get_argument --ez-argument-list "${argument_list[@]}" --ez-argument-type "List" --ez-long-identifier "--list-not-exit"  --ez-default-value "${default_list[@]}"); do
    if [[ "${default_list[${index}]}" != "${item}" ]]; then echo "[${THIS_TEST_FILE_NAME}][ERROR] \"${item}\" != \"${default_list[${index}]}\""; exit 1; fi
    ((index++))
done

my_string=$(ez_get_argument --ez-argument-list "${argument_list[@]}" --ez-long-identifier "--name")
if [[ "${my_string}" != "EZ-BASH" ]]; then echo "[${THIS_TEST_FILE_NAME}][ERROR] \"${my_string}\" != \"EZ-BASH\""; exit 1; fi

my_string=$(ez_get_argument --ez-argument-type "String" --ez-short-identifier "-v" --ez-argument-list "${argument_list[@]}")
if [[ "${my_string}" != "Hello World" ]]; then echo "[${THIS_TEST_FILE_NAME}][ERROR] \"${my_string}\" != \"Hello World\""; exit 1; fi

my_valid_string=$(ez_get_argument --ez-argument-type "String" --ez-short-identifier "--name" --ez-argument-list "${argument_list[@]}" --ez-choose-from "Valid1" "EZ-BASH" "Valid2")
if [[ "${?}" != "0" ]]; then echo "[${THIS_TEST_FILE_NAME}][ERROR] \"--ez-choose-from\" does not work as expected"; exit 1; fi

my_invalid_string=$(ez_get_argument --ez-argument-type "String" --ez-short-identifier "--name" --ez-argument-list "${argument_list[@]}" --ez-choose-from "Valid1" "Valid2")
if [[ "${?}" != "4" ]]; then echo "[${THIS_TEST_FILE_NAME}][ERROR] \"--ez-choose-from\" does not work as expected"; exit 1; fi

default_string=$(ez_get_argument --ez-short-identifier "NA" --ez-argument-list "${argument_list[@]}" --ez-default-value "Not Found")
if [[ "${default_string}" != "Not Found" ]]; then echo "[${THIS_TEST_FILE_NAME}][ERROR] \"${default_string}\" != \"Not Found\""; exit 1; fi

my_boolean=$(ez_get_argument --ez-argument-list "${argument_list[@]}" --ez-argument-type "Boolean" --ez-long-identifier "--bool-item1")
if [[ "${my_boolean}" != "${EZ_BASH_BOOL_TRUE}" ]]; then echo "[${THIS_TEST_FILE_NAME}][ERROR] \"${my_boolean}\" != \"${EZ_BASH_BOOL_TRUE}\""; exit 1; fi

my_boolean=$(ez_get_argument --ez-argument-list "${argument_list[@]}" --ez-argument-type "Boolean" --ez-long-identifier "--bool-item2")
if [[ "${my_boolean}" != "${EZ_BASH_BOOL_FALSE}" ]]; then echo "[${THIS_TEST_FILE_NAME}][ERROR] \"${my_boolean}\" != \"${EZ_BASH_BOOL_FALSE}\""; exit 1; fi

default_boolean=$(ez_get_argument --ez-argument-list "${argument_list[@]}" --ez-default-value "FAKE-FALSE" --ez-long-identifier "--bool-item2" --ez-argument-type "Boolean")
if [[ "${default_boolean}" != "FAKE-FALSE" ]]; then echo "[${THIS_TEST_FILE_NAME}][ERROR] \"${default_boolean}\" != \"FAKE-FALSE\""; exit 1; fi

echo "[Passed All Tests]"
