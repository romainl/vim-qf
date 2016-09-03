# vim-qf

**vim-qf**—short for *vim-quickfix*—is a small collection of settings, commands and mappings put together to make working with the location/quickfix list/window smoother.

## Features

### Global features

    - quickfix buffers are hidden from `:ls` and buffer navigation
    - optional mappings for `:cnext`, `:cprevious`, `:lnext`, `:lprevious`
      that wrap around the beginning and end of the list
    - optional mapping for jumping to and from the location/quickfix window,
    - optional mappings for toggling location/quickfix windows
    - open the location/quickfix window automatically after `:make`, `:grep`,
      `:lvimgrep` and friends if there are valid locations/errors
    - quit Vim if the last window is a location/quickfix window
    - close the location window automatically when quitting parent window

### Local features

    - disable soft-wrapping in the location/quickfix window
    - disable relative numbers in the location/quickfix window
    - optional Ack.vim-inspired mappings
    - filter and restore the current list
    - perform commands on each line in the current list
    - perform commands on each file in the current list
    - jump to next group of entries belonging to same file ("file grouping")
    - save and load named lists


## Installation

Use your favorite plugin manager or dump the files below in their standard location:

    # Unix-like systems
    ~/.vim/after/ftplugin/qf.vim
    ~/.vim/autoload/qf.vim
    ~/.vim/doc/qf.txt
    ~/.vim/plugin/qf.vim

    # Windows
    %userprofile%\vimfiles\after\ftplugin\qf.vim
    %userprofile%\vimfiles\autoload\qf.vim
    %userprofile%\vimfiles\doc\qf.txt
    %userprofile%\vimfiles\plugin\qf.vim

If you go with the manual method, don't forget to index the documentation with:

    :helptags ~/.vim/doc

on Unix-like systems, or:

    :helptags %userprofile%\vimfiles\doc

on Windows.

## TODO

* Export more options?
* Add a gifcast to the README?

## DONE

* Use `<Plug>` mappings.
* Add proper attribution for a few features.
* Write a proper `help` file.
* Ask #vim's opinion.
