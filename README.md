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
    ~/.vim/plugin/qf.vim

    # Windows
    %userprofile%\vimfiles\after\ftplugin\qf.vim
    %userprofile%\vimfiles\autoload\qf.vim
    %userprofile%\vimfiles\plugin\qf.vim

## Usage

The following commands are available when the location/quickfix window is focused:

    :Filter            " Without argument, removes every item not found
                       " in the file of the current item.
    :Filter foo        " Removes every item that doesn't match with the
                       " supplied argument, either in the filename or
                       " in the description.
    :Restore           " Restores the list to its original state.
    :Doline command    " Executes 'command' on every line in the current list.
    :Dofile command    " Executes 'command' on every file in the current list.

## Configuration

### Mappings available everywhere

Go up and down the quickfix list and wrap around

    <Plug>QfCprevious
    <Plug>QfCnext

Go up and down the location list and wrap around

    <Plug>QfLprevious
    <Plug>QfLnext

Jump to and from the location/quickfix window

    <Plug>QfSwitch

Here is how you would map `<leader>n` to jump to the next error in the quickfix list:

    nmap <leader>n <Plug>QfCnext

### Ack.vim-inspired mappings available only in the quickfix window

    s - open entry in a new horizontal window
    v - open entry in a new vertical window.
    t - open entry in a new tab.
    o - open entry and come back
    O - open entry and close the location/quickfix window.

Add the line below to your `vimrc` to enable that feature:

    let g:qf_mapping_ack_style = 1

### Statusline customization

It is possible to define what comes before and after the default information displayed in the statusline. Feel free to play with the options below.

    let g:qf_statusline = {}
    let g:qf_statusline.before = '%<\ '
    let g:qf_statusline.after = '\ %f%=%l\/%-6L\ \ \ \ \ '

## AKNOWLEDGEMENTS

The "Ack.vim-inspired mappings" come from [Ack.vim](https://github.com/mileszs/ack.vim), obviously.

`:Doline` and `:Dofile` are inspired by these online resources:

* http://vimcasts.org/episodes/project-wide-find-and-replace/
* https://github.com/nelstrom/vim-qargs
* https://github.com/henrik/vim-qargs
* http://stackoverflow.com/questions/4792561/how-to-do-search-replace-with-ack-in-vim/4793316#4793316
* http://stackoverflow.com/a/5686810/546861
* and another one I can't find right now.

`:Filter` is adapted from the answers to [this question](http://stackoverflow.com/questions/15406138/is-it-possible-to-grep-vim%CA%BCs-quickfix).

## TODO

* Write a proper `help` file.
* Ask #vim's opinion.
* Export more options?
* Add a gifcast to the README?

## DONE

* Use `<Plug>` mappings.
* Add proper attribution for a few features.
