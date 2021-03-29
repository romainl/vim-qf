" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
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

" returns bool: Is quickfix window open?
function! qf#IsQfWindowOpen() abort
    for winnum in range(1, winnr('$'))
        if qf#IsQfWindow(winnum)
            return 1
        endif
    endfor
    return 0
endfunction

" returns bool: Is location window for window with given number open?
function! qf#IsLocWindowOpen(nmbr) abort
    let loclist = getloclist(a:nmbr)
    for winnum in range(1, winnr('$'))
        if qf#IsLocWindow(winnum) && loclist ==# getloclist(winnum)
            return 1
        endif
    endfor
    return 0
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

    " get user-defined maximum height
    let max_height = get(g:, 'qf_max_height', 10) < 1 ? 10 : get(g:, 'qf_max_height', 10)

    " call partial with optional arguments
    call call(Func, a:000)

    if a:newlist == []
        return
    endif

    if get(b:, 'qf_isLoc', 0)
        execute get(g:, "qf_auto_resize", 1) ? 'lclose|' . min([ max_height, len(getloclist(0)) ]) . 'lwindow' : 'lclose|lwindow'
    else
        execute get(g:, "qf_auto_resize", 1) ? 'cclose|' . min([ max_height, len(getqflist()) ]) . 'cwindow' : 'cclose|cwindow'
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
        " get user-defined maximum height
        let max_height = get(g:, 'qf_max_height', 10) < 1 ? 10 : get(g:, 'qf_max_height', 10)

        let qf_list = getqflist()

        " shorten paths if applicable
        if get(g:, 'qf_shorten_path', 0) > 0
            call setqflist(qf#ShortenPathsInList(qf_list))
        endif

        execute get(g:, "qf_auto_resize", 1) ? 'cclose|' . min([ max_height, len(qf_list) ]) . 'cwindow' : 'cclose|cwindow'
    endif
endfunction

" open a location window if there are valid locations
function! qf#OpenLoclist()
    if get(g:, 'qf_auto_open_loclist', 1)
        " get user-defined maximum height
        let max_height = get(g:, 'qf_max_height', 10) < 1 ? 10 : get(g:, 'qf_max_height', 10)

        let loc_list = getloclist(0)

        " shorten paths if applicable
        if get(g:, 'qf_shorten_path', 0) > 0
            call setloclist(0, qf#ShortenPathsInList(loc_list))
        endif

        execute get(g:, "qf_auto_resize", 1) ? 'lclose|' . min([ max_height, len(loc_list) ]) . 'lwindow' : 'lclose|lwindow'
    endif
endfunction

" shorten file paths in given qf/loc list
function! qf#ShortenPathsInList(list)
    let index = 0
    while index < len(a:list)
        " item is a dict, sample: { lnum: 14, text: 'foo bar', bufnr: 3, ... }
        let item = a:list[index]

        let filepath = bufname(item["bufnr"])
        let trim_len = get(g:, "qf_shorten_path", 1)

        " set the 'module' field to customise the visual filename in the qf/loc list (available since 8.0.1782)
        if has('patch-8.2.1741')
            let item["module"] = pathshorten(filepath, trim_len)
        else
            let item["module"] = pathshorten(filepath)
        endif

        let index = index + 1
    endwhile
    return a:list
endfunction

let &cpo = s:save_cpo
