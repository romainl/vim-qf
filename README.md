# vim-qf

**vim-qf**—short for *vim-quickfix*—is a growing collection of settings, commands and mappings put together to make working with the location list/window and the quickfix list/window smoother.

## Features

### Anti-features

Many plugins interact with the quickfix/location list/window in ways that are more or less incompatible with vim-qf. I have put considerable effort into making most vim-qf features optional so it should be possible to disable individual features in case of conflict but well… you never know.

**If one of your plugins somehow already manages the quickfix/location list/window, then you should probably look elsewhere.**

### Global features (available from any window)

- quickfix buffers are hidden from `:ls` and buffer navigation

- quit Vim if the last window is a location/quickfix window

- close the location window automatically when quitting parent window

- (optional) mappings for `:cnext`, `:cprevious`, `:lnext`, `:lprevious` that wrap around the beginning and end of the list

- (optional) mapping for jumping to and from the location/quickfix window,

- (optional) mappings for toggling location/quickfix windows

- (optional) open the location/quickfix window automatically after `:make`, `:grep`, `:lvimgrep` and friends if there are valid locations/errors

- (optional) automatically set the height of location/quickfix windows to the number of list items if less than Vim's default height (10) or the user's preferred height

### Local features (available only in location/quickfix windows)

- disable relative numbers

- filter and restore the current list:

  ![filter][1]

- jump to next group of entries belonging to same file ("file grouping"):

  ![group][2]

- save and load named lists:

  ![list][3]

- (optional) disable soft-wrapping

- (optional) Ack.vim-inspired mappings

- (optional) shorten filepaths for better legibility

## Installation

### Method 1

Use your favorite runtimepath/plugin manager.

### Method 2

If you are using Vim 8.0 or above, move this directory to:

    # Unix-like systems
    ~/.vim/pack/{whatever name you want}/start/vim-qf

    # Windows
    %userprofile%\vimfiles\pack\{whatever name you want}\start\vim-qf

See `:help package`.

## Documentation

The full documentation is available through this command:

    :help vim-qf

## TODO

- Export more options?

- Add titles to saved lists, e.g. to display in :ListLists?

## DONE

- Use `<Plug>` mappings.

- Add proper attribution for a few features.

- Write a proper `help` file.

- Ask #vim's opinion.

- Add a gifcast to the README.

- Add `:packadd` support?

[1]: https://romainl.github.io/vim-qf/filter.gif
[2]: https://romainl.github.io/vim-qf/group.gif
[3]: https://romainl.github.io/vim-qf/list.gif
