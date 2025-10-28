#!/bin/sh

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
    -h | --help) printf "The following flags are supported:\n -d | --difficulty #) sets the" >&2
        exit;; 
    *) printf "${RED}Error:${CLEAR} $1 is not a valid option\n Usage: $curDir [-d -m]" >&2
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
