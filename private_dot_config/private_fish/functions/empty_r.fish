function r --description 'Repeat last command'
    for cmd in $history
        if test "$cmd" != "r"
            eval $cmd
            return
        end
    end
end
