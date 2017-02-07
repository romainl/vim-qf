# vim-qf

**vim-qf**—short for *vim-quickfix*—is a growing collection of settings, commands and mappings put together to make working with the location list/window and the quickfix list/window smoother.

## Features

### Global features (available from any window)

- quickfix buffers are hidden from `:ls` and buffer navigation

- quit Vim if the last window is a location/quickfix window

- close the location window automatically when quitting parent window

- (optional) mappings for `:cnext`, `:cprevious`, `:lnext`, `:lprevious` that wrap around the beginning and end of the list

- (optional) mapping for jumping to and from the location/quickfix window,

- (optional) mappings for toggling location/quickfix windows

- (optional) open the location/quickfix window automatically after `:make`, `:grep`, `:lvimgrep` and friends if there are valid locations/errors

### Local features (available only in location/quickfix windows)

- disable soft-wrapping

- disable relative numbers

- set height of location/quickfix windows automatically to the number of listed items if less than the default height (10)

- filter and restore the current list:

  ![filter](https://romainl.github.io/vim-qf/filter.gif)

- perform commands on each line in the current list

- perform commands on each file in the current list

- jump to next group of entries belonging to same file ("file grouping"):

  ![group](https://romainl.github.io/vim-qf/group.gif)

- save and load named lists:

  ![list](https://romainl.github.io/vim-qf/list.gif)

- (optional) Ack.vim-inspired mappings

## Installation

Use your favorite runtimepath/plugin manager or dump the files below in their standard location:

    # Unix-like systems
    ~/.vim/after/ftplugin/qf.vim
    ~/.vim/autoload/qf.vim
    ~/.vim/autoload/qf/*.vim
    ~/.vim/doc/qf.txt
    ~/.vim/plugin/qf.vim

    # Windows
    %userprofile%\vimfiles\after\ftplugin\qf.vim
    %userprofile%\vimfiles\autoload\qf.vim
    %userprofile%\vimfiles\autoload\qf\*.vim
    %userprofile%\vimfiles\doc\qf.txt
    %userprofile%\vimfiles\plugin\qf.vim

## Documentation

If you go with the manual installation method, don't forget to index the documentation:

    # Unix-like systems
    :helptags ~/.vim/doc

    # Windows
    :helptags %userprofile%\vimfiles\doc

Once the documentation is indexed, you can use this command to get help on vim-qf:

    :help vim-qf

## TODO

- Export more options?

- Add a gifcast to the README?

- Add titles to saved lists, e.g. to display in :ListLists?

## DONE

- Use `<Plug>` mappings.

- Add proper attribution for a few features.

- Write a proper `help` file.

- Ask #vim's opinion.
