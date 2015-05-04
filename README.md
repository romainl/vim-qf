# vim-qf

**vim-qf** – short for *vim-quickfix* – is a small collection of settings, commands and mappings put together to make working with the quickfix list/window smoother.

## Features

* disabled soft-wrapping,
* disabled relative numbers,
* quickfix buffers hidden from `:ls` and buffer navigation,
* Ack.vim-inspired mappings,
* wrapping mappings for `:cnext`, `:cprevious`, `:lnext`, `:lprevious`,
* jump to and from the location/quickfix window with a single mapping
* filter/restore the list
* perform commands on each line in the list
* perform commands on each file in the list
* automatically open the location/quickfix window after `:make`, `:grep`,
  `:lvimgrep` and friends if there are valid locations/errors
* quit Vim if the last window is a location/quickfix window

## Installation

Use your favorite plugin manager or dump the files below in their standard location:

    # Unix-like systems
    ~/.vim/after/ftplugin/qf.vim
    ~/.vim/autoload/qf.vim
    ~/.vim/plugin/qf.vim

    # Windows
    %userprofile%\vimfiles\plugin\qlist.vim
    %userprofile%\vimfiles\after\ftplugin\qf.vim
    %userprofile%\vimfiles\autoload\qf.vim
    %userprofile%\vimfiles\plugin\qf.vim

## Configuration

The plugin provides two sets of mappings.

* Mappings available in every buffer.

        " <Home> and <End> go up and down the quickfix list and wrap around
        nmap <Home>   <Plug>QfCprevious
        nmap <End>    <Plug>QfCnext

        " <C-Home> and <C-End> go up and down the location list and wrap around
        nmap <C-Home> <Plug>QfLprevious
        nmap <C-end>  <Plug>QfLnext

        " ç jumps to and from the location/quickfix window
        nmap ç        <Plug>QfSwitch

  Here is how you would map `<leader>n` to jump to the next error in the quickfix list:

        nmap <leader>n <Plug>QfCprevious

* Mappings available in the quickfix window only.

        " Ack.vim-inspired mappings
        " s - open entry in a new horizontal window
        " v - open entry in a new vertical window.
        " t - open entry in a new tab.
        " o - open entry and come back
        " O - open entry and close the location/quickfix window.
        let g:qf_mapping_ack_style = 1

  Here is how you would map `<leader>f` to filter the current list based on the filename under the cursor:

        let g:qf_mapping_filter = '<leader>f'

## TODO

* Write a proper `help` file.
* Ask #vim's opinion.
* Export more options?
* Add a gifcast to the README?
* Add proper attribution for a few features.

## DONE

* Use `<Plug>` mappings.
