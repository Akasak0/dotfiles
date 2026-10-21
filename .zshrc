eval "$(mise activate zsh)" # this sets up interactive sessions

# for Competitve Programming
export PATH="/opt/homebrew/bin:$PATH"
alias gcc=/opt/homebrew/bin/gcc-16
alias g++=/opt/homebrew/bin/g++-16

# for style
# PROMPT="%F{green}%n@%m %K{green}%F{black}%~%k
# %K{green}%#%f%k "

alias gpp="g++"
PS1="%B%F{226}%n@%m%f:%F{129}%~ $ %f%b"
RPROMPT="%F{240}%D %*%f"

# zsh syntax highlighting
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# for ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
