# vim-qf

**vim-qf** – short for *vim-quickfix* – is a small collection of commands and mappings put together to make working with the quickfix list/window smoother.

## Features

* set `nowrap`
* set `norelativenumber`
* set `nobuflisted`
* Ack.vim-inspired mappings
* wrapping `:cnext`, `:cprevious`, `:lnext`, `:lprevious`
* jump to and from the quickfix window
* filter/restore the location/quickfix list
* perform commands on each line in the list
* perform commands on each file in the list
* automatically open the quickfix/location window after `:make`, `:grep`,
  `:lvimgrep` and friends if there are valid errors/locations
* quit Vim if the last window is a quickfix window

## TODO

* write proper documentation
* use `<Plug>` mappings
* export more options
* add a gifcast to this file?
* ask #vim's opinion
