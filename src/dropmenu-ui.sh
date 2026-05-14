# ui.sh - persistent ui that is hidden and shown

export LGSTEM=dropmenu
export LGSPEC=ui

lga start

in_fifo_path=$XDG_STATE_HOME/dropmenu/in.fifo
out_fifo_path=$XDG_STATE_HOME/dropmenu/out.fifo

if [ -n "${1:-}" ]; then
    lga . "processing argument[$1]"

    case "$1" in
        "--infifo") echo "$in_fifo_path"; ;;
        "--outfifo") echo "$out_fifo_path"; ;;
        *) lge "unrecognized argument[$1]" ; exit 1 ;;
    esac

    lga finish
    exit 0
fi

if [ -e "$in_fifo_path" ]; then
    lga I "removing existing fifo: $in_fifo_path"
    rm "$in_fifo_path" &> /dev/null || :
fi

if [ -e "$out_fifo_path" ]; then
    lga I "removing existing fifo: $out_fifo_path"
    rm "$out_fifo_path" &> /dev/null || :
fi

show_sh="$XDG_CONFIG_HOME/dropmenu/show.sh"
hide_sh="$XDG_CONFIG_HOME/dropmenu/hide.sh"

if [ ! -f "$show_sh" ]; then lge "expecting a script to show the ui dropdown at [$show_sh]" ; exit 1 ; fi
if [ ! -f "$hide_sh" ]; then lge "expecting a script to hide the ui dropdown at [$hide_sh]" ; exit 1 ; fi

lga I "initializing fifo: $in_fifo_path"
mkdir -p "$(dirname "$in_fifo_path")"
mkfifo "$in_fifo_path"

lga I "initializing fifo: $out_fifo_path"
mkdir -p "$(dirname "$out_fifo_path")"
mkfifo "$out_fifo_path"

logging_state="$LGENABLE"

lga I "beginning main loop: reading from fifo and processing"

while true; do
    export LGENABLE="$logging_state"

    lga F "loop start: awaiting input from in_fifo[$in_fifo_path]"

    input="$(cat "$in_fifo_path")"
    lga F "got input from infile"

    lga . "showing menu-ui"
    . "$show_sh" &

    separator="$(echo "$input" | head -n 1)"
    lga . "got separator[$separator]"
    list="$(echo "$input" | awk "/$separator/{section++; next} section==2")"
    lga . "got list '$(echo "$list" | tr '\n' ',')'"

    flag_allow_new=0
    flag_print_query=0
    flag_secure=0
    flag_fast=0

    while IFS= read -r flag; do
        case "$flag" in
            "--secure") flag_secure=1; lga . "set flag_secure[$flag_secure] NOTE: LOGGING WILL DISABLE" ;;
            "--allow-new") flag_allow_new=1; lga . "set flag_allow_new[$flag_allow_new]" ;;
            "--print-query") flag_print_query=1; lga . "set flag_print_query[$flag_print_query]" ;;
            "--fast") flag_fast=1; lga . "set flag_fast[$flag_fast]" ;;
        esac
    done < <(echo "$input" | awk "/$separator/{section++; next} section==1")

    if (( flag_secure )); then export LGENABLE=0;
    else export LGENABLE="$logging_state"; fi

    result=""

    if (( flag_allow_new )); then
        response="$(echo "$list" | fzf --print-query || :)"
        selected="$(echo "$response" | tail -n 1)"
        typed="$(echo "$response" | head -n 1)"
        [ "$(echo "$response" | wc -l)" == "1" ] && selected=""

        if echo "$typed" | grep -q "\*$"; then
            result="${typed%\*}" # a star signifies to use this input over anything else
        elif [ -n "$selected" ]; then
            result="$selected" # it exists, and we prefer it always (except for "...*" case)
        else
            result="$typed" # typed input is completey new
        fi
    elif (( flag_print_query )); then
        result="$(echo "$list" | fzf --print-query || :)"
    else
        result="$(echo "$list" | fzf || :)"
    fi

    lga . "hiding menu-ui"
    if (( flag_fast ));
    then . "$hide_sh" &
    else . "$hide_sh"
    fi

    lga F "loop end: returning result to out_fifo: $(echo "$result" | tr '\n' '$')"

    echo "$result" > "$out_fifo_path"
done
