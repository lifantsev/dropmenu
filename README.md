# dropmenu

A dmenu-like program that uses a dropdown terminal with fzf as its ui. Can work with all window managers and any dropdown program.

## Usage

```
cat options.txt | dropmenu
```

Pipe a list of options to the tool, and it will show fzf in a dropdown terminal to let the user select an option.

- --help (-h) : print a help menu
- --secure : disable logging
- --allow-new : allow the user to choose something not on the list of options ([details](#--allow-new))
- --print-query : print two lines - 1st is the user's typed query, 2nd is the chosen option
- --fast : close the ui asynchronously (can cause problems if called in quick repetition)

## Installation

This program has two components: a cli interface `dropmenu`, and a ui `dropmenu-ui` that should be running in a dropdown terminal, waiting to be shown by a call to `dropmenu`.

### flake

``` nix
# flake.nix
inputs.dropmenu.url = "github:lifantsev/dropmenu";

# configuration.nix
imports = [ inputs.dropmenu.nixosModules.default ];

# or install manually
environment.systemPackages = with inputs.dropmenu.packages; [
    dropmenu
    dropmenu-ui
]
```

### other

If you are not a nix user, you can download the [shellscripts](https://github.com/lifantsev/dropmenu/tree/main/src), add shebangs, and install them however you prefer (maybe put it in ~/.local/bin or create an alias).

Note that both scripts optionally depend on [lg](https://github.com/lifantsev/lg). If you don't want to install it, just use `sed -i '/ *lg / d' <file.sh>` to remove all calls to it.

## Configuration

## --allow-new

The fuzzy nature of fzf causes some ambiguity here. What to do if one of the options is 'bernard' but the user wants to enter 'bed'? There is no way to distinguish between a user that wants to type 'bed' and one that typed the same characters to fuzzy find 'bernard'.

This is resolved using a special character '\*'. If '\*' is found at the end of user input, it is removed and the remaining string is returned as output, regardless of if it matched any options.

So if we run `echo 'bernard*' | dropmenu --allow-new`, here are the cases:
```
'new'      -> 'new'
'bed'      -> 'bernard*'
'bed*'     -> 'bed'
'bernard*' -> 'bernard'
```
