" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.1.1
" License:	MIT
" Location:	autoload/qf.vim
" Website:	https://github.com/romainl/vim-qf
"
" Use this command to get help on vim-qf:
"
"     :help qf
"
" If this doesn't work and you installed vim-qf manually, use the following
" command to index vim-qf's documentation:
"
"     :helptags ~/.vim/doc
"
" or read your runtimepath/plugin manager documentation.

let s:save_cpo = &cpo
set cpo&vim

" open the current entry in th preview window
function qf#PreviewFileUnderCursor()
    let cur_list = b:qf_isLoc == 1 ? getloclist('.') : getqflist()
    let cur_line = getline(line('.'))
    let cur_file = fnameescape(substitute(cur_line, '|.*$', '', ''))
    if cur_line =~ '|\d\+'
        let cur_pos  = substitute(cur_line, '^\(.\{-}|\)\(\d\+\)\(.*\)', '\2', '')
        execute "pedit +" . cur_pos . " " . cur_file
    else
        execute "pedit " . cur_file
    endif
endfunction

" helper function
" returns 1 if the window with the given number is a quickfix window
"         0 if the window with the given number is not a quickfix window
" TODO (Nelo-T. Wallus): make a:nbmr optional and return current window
"                        by default
function! qf#IsQfWindow(nmbr)
    if getwinvar(a:nmbr, "&filetype") == "qf"
        return qf#IsLocWindow(a:nmbr) ? 0 : 1
    endif

    return 0
endfunction

" helper function
" returns 1 if the window with the given number is a location window
"         0 if the window with the given number is not a location window
function! qf#IsLocWindow(nmbr)
    return getbufvar(winbufnr(a:nmbr), "qf_isLoc") == 1
endfunction

" returns location list of the current loclist if isLoc is set
"         qf list otherwise
function! qf#GetList()
    if get(b:, 'qf_isLoc', 0)
        return getloclist(0)
    else
        return getqflist()
    endif
endfunction

" sets location or qf list based in b:qf_isLoc to passed newlist
function! qf#SetList(newlist, ...)
    " generate partial
    let Func = get(b:, 'qf_isLoc', 0)
                \ ? function('setloclist', [0, a:newlist])
                \ : function('setqflist', [a:newlist])

    " call partial with optional arguments
    call call(Func, a:000)

    if get(b:, 'qf_isLoc', 0)
        lclose
        execute min([ 10, len(getloclist(0)) ]) 'lwindow'
    else
        cclose
        execute min([ 10, len(getqflist()) ]) 'cwindow'
    endif
endfunction

function! qf#GetEntryPath(line) abort
    "                          +- match from the first pipe to the end of line
    "                          |  declaring EOL explicitly is faster than implicitly
    "                          |      +- replace match with nothing
    "                          |      |   +- no flags
    return substitute(a:line, '|.*$', '', '')
endfunction

" open the quickfix window if there are valid errors
function! qf#OpenQuickfix()
    if get(g:, 'qf_auto_open_quickfix', 1)
        execute min([ 10, len(getqflist()) ]) 'cwindow'
    endif
endfunction

" open a location window if there are valid locations
function! qf#OpenLoclist()
    if get(g:, 'qf_auto_open_loclist', 1)
        execute min([ 10, len(getloclist(0)) ]) 'lwindow'
    endif
endfunction

let &cpo = s:save_cpo
