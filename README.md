# dropmenu

A dmenu-like program that uses a dropdown terminal with fzf as its ui. Can work with any window manager or dropdown program.

## Usage

```
cat options.txt | dropmenu
```

Pipe a list of options to the tool, and it will show fzf in a dropdown terminal to let the user select an option.

- --help (-h) : print a help menu
- --secure : disable logging
- --allow-new : allow the user to choose something not on the list of options ([details](#allow-new))
- --print-query : print two lines - 1st is the user's typed query, 2nd is the chosen option
- --fast : close the ui asynchronously (can cause problems if called in quick repetition)

### allow-new

The fuzzy nature of fzf causes some ambiguity here. What to do if one of the options is 'bernard' but the user wants to enter 'bed'? There is no way to distinguish between a user that wants to type 'bed' and one that typed the same characters to fuzzy find 'bernard'.

This is resolved using a special character '\*'. If '\*' is found at the end of user input, it is removed and the remaining string is returned as output, regardless of if it matched any options.

So if we run `echo 'bernard*' | dropmenu --allow-new`, here are the cases:
- input 'bed' -> 'bernard*'
- input 'bed*' -> 'bed'
- input 'bernard*' -> 'bernard'

## Configuration
## Installation
