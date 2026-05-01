if status is-interactive
    set fish_greeting # disable greeting
    starship init fish | source
		zoxide init fish | source

		alias cz "chezmoi"
		alias czcd "chezmoi cd"
		alias czad "chezmoi add"
		alias czra "chezmoi re-add"
		alias czed "chezmoi edit"
		alias czap "chezmoi apply"
		alias czd "chezmoi diff"

		alias ls "eza -l"
		alias ll "eza -lgo"
		alias la "eza -laa"
		alias lla "eza -lgoaa"
		alias lt "eza -T"
end

set -gx EDITOR nvim
set -gx VISUAL nvim

fish_add_path ~/.cargo/bin
