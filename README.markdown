# bumblebee.vim

Bumblebee provides fuzzy matching buffer commands: `:B`, `:Sb`, and `:Vb`.

Bumblebee "overrides" Vim's native `:b` and `:sb` commands by using a smart
abbreviation that expands to `:B` and `:Sb` respectively. `:vb` is also
expanded to ``:Vb` for consistency.

## Installation

If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/PeterRincker/vim-bumblebee.git

Once help tags have been generated, you can view the manual with
`:help bumblebee`.
