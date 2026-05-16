# cli.sh - end user interface

# TODO pgrep for dropmenu ui process, if not running, open it

export LGSTEM=dropmenu
export LGSPEC=cli

if [ ! -f "$XDG_CONFIG_HOME/dropmenu/show.sh" ]; then echo "error: need a script to show the ui @ [$XDG_CONFIG_HOME/dropmenu/show.sh]" ; exit 1 ; fi
if [ ! -f "$XDG_CONFIG_HOME/dropmenu/hide.sh" ]; then echo "error: need a script to hide the ui @ [$XDG_CONFIG_HOME/dropmenu/hide.sh]" ; exit 1 ; fi

flag_help=0
flag_secure=0
uiflag_allow_new=0
uiflag_print_query=0
uiflag_fast=0

lga start

while [ -n "${1:-}" ]; do
    case "$1" in
        "-h"|"--help") flag_help=1; lga . "set help: $flag_help" ;;
        "--secure") flag_secure=1; lga . "set flag_secure: $flag_secure NOTE: LOGGING WILL DISABLE";;

        "--fast") uiflag_fast=1; lga . "set uiflag_fast[$uiflag_fast]" ;;
        "--allow-new") uiflag_allow_new=1; lga . "set uiflag_allow_new: $uiflag_allow_new";;
        "--print-query") uiflag_print_query=1; lga . "set uiflag_print_query: $uiflag_print_query";;
    esac

    shift
done

in_fifo_path="$(dropmenu-ui --infifo)"
out_fifo_path="$(dropmenu-ui --outfifo)"

(( flag_secure )) && export LGENABLE=0

if (( flag_help )); then
    echo "'dropmenu' is a dmenu like script"
    echo ""
    echo "pass choice options in stdin, separated by newlines"
    echo "dropmenu will allow the user to choose one of these options, which will be printed to stdout"
    echo ""
    echo "-h | --help      : print this help menu"
    echo '--secure         : disable logging'
    echo "--fast           : don't wait for ui to close before exiting"
    echo "    NOTE: only one of the below may be passed"
    echo "--allow-new      : allow the user to create their own option instead of choosing from the presented ones"
    echo "--print-query    : 1st line of stdout is exactly what the user typed, 2nd line is the exact choice (usual output)"
    exit
fi

lga I "writing flag & options to in_fifo[$in_fifo_path]"
separator="MENU FLAG OPTION SEPARATOR $(mktemp --dry-run XXXXXXXXXXXXXXXXXXXXXXXXXXXXX)"
echo "$(
    echo "$separator"
    (( flag_secure )) && echo "--secure"
    (( uiflag_allow_new )) && echo "--allow-new"
    (( uiflag_print_query )) && echo "--print-query"
    (( uiflag_fast )) && echo "--fast"
    echo "$separator"
    cat # pass stdin
)" > "$in_fifo_path"

lga I "awaiting result from out_fifo[$out_fifo_path]"
result="$(cat "$out_fifo_path")"
lga . "got result[$(echo "$result" | tr '\n' '$')], printing"
echo "$result"

lga finish
