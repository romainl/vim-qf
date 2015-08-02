# vim-qf

**vim-qf** – short for *vim-quickfix* – is a small collection of settings, commands and mappings put together to make working with the quickfix list/window smoother.

## Features

* no soft-wrapping,
* no relative numbers,
* quickfix buffers hidden from `:ls` and buffer navigation,
* Ack.vim-inspired mappings,
* wrapping mappings for `:cnext`, `:cprevious`, `:lnext`, `:lprevious`,
* jump to and from the location/quickfix window with a single mapping
* filter/restore the list
* perform commands on each line in the list
* perform commands on each file in the list
* open the location/quickfix window automatically after `:make`, `:grep`,
  `:lvimgrep` and friends if there are valid locations/errors
* quit Vim if the last window is a location/quickfix window

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

Don't forget to index the documentation with:

    :helptags ~/.vim/doc

on Unix-like systems, or:

    :helptags %userprofile%\vimfiles\doc

on Windows.

## TODO

* Ask #vim's opinion.
* Export more options?
* Add a gifcast to the README?

## DONE

* Use `<Plug>` mappings.
* Add proper attribution for a few features.
* Write a proper `help` file.
`<Plug>` mappings.
* Add proper attribution for a few features.
* Write a proper `help` file.
* Ask #vim's opinion.
