Dotfiles, managed using GNU Stow.

Example:

`~/.config/nvim/*` maps to `./nvim/.config/nvim*`

`~/.bashrc` maps to `./bash/.bashrc`

Adding a new package:

1. Move configs to here: `mv ~/.config/nvim ./nvim`
2. Then, stow then: `stow -t ~ nvim`

