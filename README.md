# dropmenu

A dmenu-like program that uses a dropdown terminal with fzf as its ui. Can work with all window managers and any dropdown program.

## Usage

```
cat options.txt | dropmenu
```

Pipe in a list of options, and then choose one using fzf in a dropdown terminal.

```
--help (-h)   : print a help menu
--secure      : disable logging
--allow-new   : allow the user to choose something not on the list of options (see details farther below)
--print-query : print two lines - 1st is the user's typed query, 2nd is the chosen option
--fast        : close the ui asynchronously (can cause problems if called in quick repetition)
```

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

In order to work properly, `dropmenu` needs to know how to talk to whatever dropdown program you are using.

Populate `$XDG_CONFIG_HOME/dropmenu/show.sh` and `hide.sh` with bash scripts that will show and hide the ui. (See [examples](https://github.com/lifantsev/dropmenu/tree/main/scripts)).

### flake

This flake exposes a home manager module that generates these scripts:

``` nix
# home.nix

imports = [ inputs.dropmenu.homeManagerModules.default ];

programs.dropmenu = {
    enable = true;

    show = "pypr show dropmenu-ui";
    hide = "pypr hide dropmenu-ui";
};
```

There are also some premade show/hide scripts you can use by setting the `showhide` option. See legal option values [here](https://github.com/lifantsev/niridrop/blob/main/options.nix).
```nix
programs.dropmenu.showhide = "niridrop"; # populate show & hide with scripts for niridrop
```

If you are using [niridrop](https://github.com/lifantsev/niridrop) and its flake, you can enable this option to register `dropmenu-ui` as a dropdown window:
``` nix
programs.dropmenu.integrations.niridrop = true;
```

## --allow-new

The fuzzy nature of fzf causes some ambiguity here. What to do if one of the options is 'bernard' but the user wants to enter 'bed'? There is no way to distinguish between a user that wants to type 'bed' and one that typed the same characters to fuzzy find 'bernard'.

This is resolved using a special character '\*'. If '\*' is found at the end of user input, it is removed and the remaining string is returned as output, regardless of if it matched any options.

So if we run `echo 'bernard*' | dropmenu --allow-new`, here are the cases:
```
user enters: bed      -> bernard*
user enters: bed*     -> bed
user enters: bernard* -> bernard
user enters: new      -> new
```
