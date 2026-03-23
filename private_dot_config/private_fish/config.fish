if status is-interactive
    set fish_greeting # disable greeting
    starship init fish | source
end

set -gx EDITOR nvim
set -gx VISUAL nvim
