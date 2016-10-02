# Watch files in infinite loop
watch () {
    # This script will re-run every time any of the specified files changes.
    #
    # $1: Command to execute
    # $*: Files to watch (can be a glob pattern)

    if (( $# < 2 ))
    then
        echo "Usage: watch <CMD> <FILES>"
        return 1
    fi

    # Should watch log anything? 1 means no
    SILENT=0

    while getopts ":s" opt; do
        case $opt in
            s)
                SILENT=1
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                return 1
                ;;
        esac
    done

    shift $(($OPTIND-1))

    # The command to execute
    CMD=$1
    shift

    # The files to watch
    FILES=$*;

    # Start the watch process
    if [ $SILENT -eq 0 ]; then
        echo "Watching files.."
    fi

    local stat_opts='-f "%m"'
    if [[ "$(uname)" == "Linux" ]]; then
        stat_opts='-c "%Y"'
    fi

    local CTIME=$(printf "%i" $(date "+%s"))
    local mtime
    while :; do
        sleep 1
        # Check if any files have changed
        for f in $(echo $FILES); do
            mtime=$(stat -c "%Y" $f)
            mtime=$(printf "%i" $mtime)
            if [ $? -eq 0 ]; then
                if [ $mtime -gt $CTIME ]; then
                    CTIME=$(printf "%i" $(date "+%s"))

                    if [ $SILENT -eq 0 ]; then
                        echo 'Retrying: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                    fi

                    # Run the command
                    clear
                    eval $CMD

                    # If it succeeded
                    if [ $? -eq 0 ]; then
                        if [ $SILENT -eq 0 ]; then
                            echo 'Succeeded: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                        fi
                    # If it failed
                    else
                        if [ $SILENT -eq 0 ]; then
                            echo 'Failed: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                        fi
                    fi
                fi
            else
                echo "watch: $f is not a file."
                return 1
            fi
        done
    done
}

