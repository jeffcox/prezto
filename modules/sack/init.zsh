# Print help / usage information about sack
sack_print_help() {
    echo "usage sack: [options] pattern [path]"
    echo ""
    echo "Wrapper around ag, ack or grep"
    echo "  F [line_no] to open file at line [line_no]"
    echo ""
    echo "-ag   to use ag"
    echo "-grep to use grep"
    echo ""
}

# Prefixes a shortcut tag to relevant output lines.
display_shortcuts() {
    # Note that by default ack uses the --nogroup -H option by default when
    # output is piped or redirected, so we do get a file name on each line as $1
    # We could have restored the default look for ack with the --group option, but
    # it turns out that this is actually simpler to parse with --nogroup and then
    # reformat the output to match the --group formats.
    gawk -v f_name="" -F':' '
    BEGIN {x=1};
    {
        if ($1 != f_name) {
            f_name=$1;
            sub(/\[[0-9]{1,2}(;[0-9]{0,2}){0,2}m\[K$/, "[0m[K", $1);
            printf("\n%s\n", $1);
        };
        printf("[%s] ", x);
        printf("%s", $2);
        for (i=3; i<=NF; i++) {
            printf(":%s", $i);
        }
        printf("\n");
        x++;
    };'
}

# Processes the output that goes into the shortcut file:
# Format: line_number:full_file_path
process_shorcut_paths() {
    # Using : as the delimiter here should be fine, because : is not used in file names
    gawk -F':' '
    {
        gsub(/\[([0-9]{0,2}(;[0-9]{0,2}){0,2})?[m|K]/, "", $0);
        print $2 " " $1;
    };'
}

sack() {
    # =============================================
    # ================ Main Script ================
    # =============================================

    # Deal with the options that only have to do with sack instead of ack
    sack__option=$1
    # By default, use ack:
    sack__default_tool=ag
    # Variable(s) to remove magic values from the code
    sack__dev_null=/dev/null
    # Color parameter is different for ack / ag than for grep:
    if [ -n "$SACK_COLORS" ]; then
        sack__color_param=$SACK_COLORS
    else
        sack__color_param='--color'
    fi

    # Sack shortcut file. '.~/.sack_shortcurt' if the variable SACK_SHORTCUT is not
    # defined.
    if [ ! -z ${SACK_SHORTCUT+x} ]; then
        sack__shortcut_file=$SACK_SHORTCUT
    else
        sack__shortcut_file=~/.sack_shortcuts
    fi

    # Determine which search tool to use
    if [[ "$sack__option" == "-ag" ]]; then
        sack__default_tool=ag
        shift
    # Determine which search tool to use
    elif [[ "$sack__option" == "-grep" ]]; then
        sack__default_tool='grep -r -I -n'
        sack__color_param='--color=always'
        shift
    # Show help printout
    elif [[ -z "$sack__option" || "$sack__option" == "-h" || "$sack__option" == "--help" || "$sack__option" == "--info" ]]; then
        sack_print_help
        echo ""
        exit 0
    fi

    # The actual wrapper around ack, ag or grep
    $sack__default_tool $sack__color_param "$@" | tee >$sack__dev_null >(display_shortcuts) >(process_shorcut_paths >! $sack__shortcut_file)
}

alias sag='sack -ag "$@"'

F(){
    # Sack shortcut file. '.~/.sack_shortcurt' if the variable SACK_SHORTCUT is not
    # defined.
    if [ ! -z ${SACK_SHORTCUT+x} ]; then
        sack_shortcutfile=$SACK_SHORTCUT
    else
        sack_shortcutfile=~/.sack_shortcuts
    fi

    # Get the line number and the file name

    _sack_line=`sed -n "$1p" < $sack_shortcutfile`
    _lineno=`echo $_sack_line | awk '{ print $1 }'`
    _fname=`echo $_sack_line | awk '{ print $2 }'`

    if [ -f $sack_shortcut ]; then
        # SublimeText
        if [[ "$EDITOR" =~ 'subl' ]]; then
            subl $_fname:$_lineno
        # Emacs & Vim
        else
            $EDITOR +$_lineno $_fname
        fi
    else
        echo "Sack shortcuts file '~/.sack_shortcuts' not found."
        echo "Please define the env. variable SACK_SHORTCUT or check if the file exist."
        exit 0
    fi
}
