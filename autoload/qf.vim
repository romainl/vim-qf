" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.1.1
" License:	MIT
" Location:	autoload/lib.vim
" Website:	https://github.com/romainl/vim-qf
"
" See :help qf for help.
"
" If this doesn't work and you installed vim-qf manually, use the following
" command to index vim-qf's documentation:
"
" :helptags ~/.vim/doc
"
" If you use a runtimepath/plugin manager, read its documentation.

let s:save_cpo = &cpo
set cpo&vim

" helper function
" " returns 1 if the window with the given number is a quickfix window
" "         0 if the window with the given number is not a quickfix window
" TODO (Nelo-T. Wallus): make a:nbmr optional and return current window
"                        by default
function qf#IsQfWindow(nmbr)
    if getwinvar(a:nmbr, "&filetype") == "qf"
        return qf#IsLocWindow(a:nmbr) ? 0 : 1
    endif

    return 0
endfunction

" helper function
" " returns 1 if the window with the given number is a location window
" "         0 if the window with the given number is not a location window
function qf#IsLocWindow(nmbr)
    return getbufvar(winbufnr(a:nmbr), "isLoc") == 1
endfunction

" returns location list of the current loclist if isLoc is set
"         qf list otherwise
function qf#GetList()
    if get(b:, 'isLoc', 0)
        return getloclist(0)
    else
        return getqflist()
    endif
endfunction

" sets location or qf list based in b:isLoc to passed newlist
function qf#SetList(newlist, ...)
    " generate partial
    let Func = get(b:, 'isLoc', 0)
                \ ? function('setloclist', [0, newlist])
                \ : function('setqflist', [newlist])

    " call partial with optional arguments
    call call(Func, a:000)
endfunction

function qf#GetEntryPath(line) abort
    "                          +- match from the first pipe to the end of line
    "                          |  declaring EOL explicitly is faster than implicitly
    "                          |      +- replace match with nothing
    "                          |      |   +- no flags
    return substitute(a:line, '|.*$', '', '')
endfunction

" open the quickfix window if there are valid errors
function qf#OpenQuickfix()
    if get(g:, 'qf_auto_open_quickfix', 1)
        cwindow
    endif
endfunction

" open a location window if there are valid locations
function qf#OpenLoclist()
    if get(g:, 'qf_auto_open_loclist', 1)
        lwindow
    endif
endfunction

let &cpo = s:save_cpo
