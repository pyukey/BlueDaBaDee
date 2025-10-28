# Getting Started

The purpose of this repo is for you to be able to automate installing vulnerabilities on your machine so you can practice whenever you want, wherever your want.

To begin, run the following steps in a **Linux-based VM** (we support a large variety, even Reptilian OS!)

1. `git clone https://github.com/pyukey/BlueDaBaDee.git`
2. `cd BlueDaBaDee/Linux`

## Step 1: Picking Vulns

First you need to tell BlueDaBaDee which vulns you want to practice. This will be stored in a file named `currentSet.txt`. You can see all supported vulnerabilities in `config.txt`, where each line has the following format:

```
vulnModule difficulty vulnName
```

To make picking vulnerabilities simple, you can just run `./pick.sh`. By default, it will pick **all** available vulns. However, there are a few flags you can use to customize your selection:

- `-d #` or `--difficulty #` : Allows you to limit the vulns to a specific difficulty. `#` is the difficulty level, which can take on 2 formats:   
   1) A single digit [1-5] : This will select vulnerabilities of *only* the difficulty specified   
   2) Two digits [1-5], separated by an emdash : Selects all vulnerabilities with a difficulty in the specified range. For example, `2-4` would limit the vulnerabilities to those of difficulty 2, 3, or 4.
- `-m yourList` or `--modules yourList` : Allows you to specify the specific vulnerabilities, where `yourList` is a comma separated list of either the module or vulnerability names, as specified in `config.txt`
- `-r #` or `--random #` : By default, *all* of the vulnerabilities that match your earlier criteria will be selected. However, what if you only wanted a few vulnerabilities, chosen at random? That's what this flag does! It randomly limits your selection to no more than `#` vulnerabilities.

Putting it all together, you could do `./pick.sh -d 2-4 -m pamPermit,user,capCat -r 3` : this will randomly select 3 vulnreabilities of difficulty between 2 and 4 inclusive, and they can either be `pamPermit`, `capCat`, or any vulnerability in the module `user`.

## Step 2: Planting Vulns

Now that you've selected which vulns you want run `sudo ./setup.sh` to plant them!

Your machine is now vulnerable! Have fun patching it >:)

## Step 3: Checking Vulns

If you ever want to check your progress, you can run `sudo ./checker.sh` and it will list all the vulnerabilities you've successfully patched, as well as your total score. If you give up and don't know what the remaining vulnerabilities are, you can *cheat* by running `sudo ./checker.sh -c` or `sudo ./checker.sh --cheat`. 

![test image](./SPOILER_image.webp)

# Contributing to this repo

Since BlueDaBaDee is modular, it is easy to contribute new vulnerabilities!

## Adding a new vulnerability

There are 3 files you need to change:

1. `config.txt` : Make sure to add a line with the following info
   ```
   vulnModule difficulty vulnName
   ```
2. `preplant.sh` : This is the code to plant the vulnerability. Add a function for your vulnerability. Make sure it is the **EXACT SAME NAME** you specified in `config.txt`
   ```bash
   vulnName() {
       #put your code to implant here
   }
   ```
3. `checker.sh` : This is the code to check if the vulnerability has been patched. Add a function for your vulnerability. Make sure it is the **EXACT SAME NAME** you specified in `config.txt`
   ```bash
   vulnName() {
       if check "conditional statement" true|false "description for the vuln"; then
        correct=$(($correct+1))
    fi
    }

   ```
   - This syntax may be confusing so let me explain what `check()` does. The `conditional statement` is what you run to check if the vulnerability is still there. The `boolean` value afterwards lets you specify whether a success is true or false for the conditional statement. The `description` is the short description that the `checker` displays.

## Adding a new module

This is the exact same as for adding new vulnerabilities. The only reason I'm explicitly mentioning it here is that it's nice (for readability) if you group the functions by there module. So, if you're adding a new module, you should put a header like the following at the start:

```
###################
#   MODULE NAME   #
###################
```