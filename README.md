# dotfiles

Put snippet in `.zshrc`
```
#=============================================================
# Source dotfiles common utils
#-------------------------------------------------------------
# dotfiles location
DOTFILES=~/git/hasueki/dotfiles

# Import .aliases
. $DOTFILES/.aliases

# Import .path
. $DOTFILES/.path

# Import .functions
for func in $DOTFILES/.functions/*.sh
do
  . $func
done

# Import .general
. $DOTFILES/.general
#=============================================================
```