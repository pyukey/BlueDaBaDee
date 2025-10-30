#!/bin/sh

WHITE="\033[1m"
RED="\033[31;1m"
GREEN="\033[32;1m"
CLEAR="\033[0m"
NUM_VULNS="all"
MIN_DIFF_LVL=1
MAX_DIFF_LVL=5
MODULES="all"
curDir=$0

RANDOM=$$$(date +%s)

# Parse flags
while [ $# -gt 0 ]; do
  case $1 in
    -d | --difficulty) MIN_DIFF_LVL=$(echo $2 | awk -F'-' '{print $1}')
        if echo "$MIN_DIFF_LVL" | grep -q -e "^[1-5]$"; then
          :
        else
          printf "${RED}Error:${CLEAR} The min difficulty must be a number from 1-5\n" >&2
          exit
        fi

        MAX_DIFF_LVL=$(echo $2 | awk -F'-' '{print $2}')
        if [ "$MAX_DIFF_LVL" != "" ]; then
          if echo "$MAX_DIFF_LVL" | grep -q -e "^[1-5]$"; then
            if [ "$MAX_DIFF_LVL" -lt "$MIN_DIFF_LVL" ]; then
              printf "${RED}Error:${CLEAR} The max difficulty can not be less than the min difficulty\n" >&2
              exit
            fi
          else
            printf "${RED}Error:${CLEAR} The max difficulty must be a number from 1-5\n" >&2
            exit
          fi
        else
          MAX_DIFF_LVL=$MIN_DIFF_LVL
        fi
        shift;;
    -m | --modules) MODULES=$2
        shift;;
    -r | --random) NUM_VULNS=$2
        shift;;
    -h | --help) printf "This program selects vulnerabilities from ${WHITE}config.txt${CLEAR} to use in ${WHITE}preplant.sh${CLEAR} and ${WHITE}checker.sh${CLEAR}. The following flags are supported:\n\n ${WHITE}-d | --difficulty #)${CLEAR} Allows you to limit the vulns to a specifc difficulty, where ${WHITE}#${CLEAR} is the difficulty level. This can take on 2 formats:\n    - A single digit [1-5]: This will select vulnerabilities of only the difficulty specified\n    - Two digits[1-5] seperated by an emdash: Selects all vulenrabilities with a difficulty in the specified range.\n      For example, ${WHITE}2-4${CLEAR} would limit the vulnerabilities to those of difficulty 2, 3, or 4.\n\n ${WHITE}-m | --modules yourList)${CLEAR} Allows you to specify the specific vulnerabilities, where ${WHITE}yourList${CLEAR} is a comma separated list of either the module or vulnerability names, as specified in ${WHITE}config.txt${CLEAR}\n      For example, ${WHITE}-m pamPermit,user,capCat${CLEAR} would select the specific vulnerabilities pamPermit, capCat, as well as any vulnerability in the user module.\n\n ${WHITE}-r | --random #)${CLEAR} By default, all of the vulnerabilities that match your earlier criteria will be selected. However, what if you only wanted a few vulnerabilities, chosen at random? That's what this flag does! It limits yourr selection to no more than ${WHITE}#${CLEAR} vulnerabilities chosen at random.\n      For example, ${WHITE}-r 3${CLEAR} would randomly select 3 vulnerabilities from your previous criteria.\n" >&2
        exit;; 
    *) printf "${RED}Error:${CLEAR} $1 is not a valid option\n Usage: $curDir [-d -m]" >&2
        exit
  esac
  shift
done
printf "${GREEN}MinDifficulty:${CLEAR} $MIN_DIFF_LVL\n${GREEN}MaxDifficulty:${CLEAR} $MAX_DIFF_LVL\n" >&2

if [ "$MODULES" = "all" ]; then
  cp config.txt currentSet.txt
else
  moduleGrep="$(echo "$MODULES" | sed 's/,/ " -e "^/g')"
  functionGrep="$(echo "$MODULES" | sed 's/,/$" -e " /g')"
  eval "grep -e \"^$moduleGrep \" -e \" $functionGrep$\" config.txt" | grep -e " [$MIN_DIFF_LVL-$MAX_DIFF_LVL] " > currentSet.txt
fi

if [ "$NUM_VULNS" = "all" ]; then
  :
elif echo "$NUM_VULNS" | grep -q -e "^[0-9]\+$"; then
  current=$(wc -l < currentSet.txt)
  while [ "$current" -gt "$NUM_VULNS" ]; do
    randomLine=$((RANDOM % current + 1))
    sed -i "${randomLine}d" currentSet.txt
    current=$((current - 1))
  done
else
  printf "${RED}Error:${CLEAR} $NUM_VULNS is not a number!\n" >&2
fi
