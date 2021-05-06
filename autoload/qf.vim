" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/qf.vim
" Website:	https://github.com/romainl/vim-qf

let s:save_cpo = &cpo
set cpo&vim

" Returns 1 if the window with the given number is a quickfix window
"         0 if the window with the given number is not a quickfix window
" TODO (Nelo-T. Wallus): make a:nbmr optional and return current window
"                        by default
function! qf#IsQfWindow(nmbr)
    if getwinvar(a:nmbr, "&filetype") == "qf"
        return qf#IsLocWindow(a:nmbr) ? 0 : 1
    endif

    return 0
endfunction

" Returns 1 if the window with the given number is a location window
"         0 if the window with the given number is not a location window
function! qf#IsLocWindow(nmbr)
    return getbufvar(winbufnr(a:nmbr), "qf_isLoc") == 1
endfunction

" Returns bool: Is quickfix window open?
function! qf#IsQfWindowOpen() abort
    for winnum in range(1, winnr("$"))
        if qf#IsQfWindow(winnum)
            return 1
        endif
    endfor

    return 0
endfunction

" Returns bool: Is location window for window with given number open?
function! qf#IsLocWindowOpen(nmbr) abort
    let loclist = getloclist(a:nmbr)

    for winnum in range(1, winnr("$"))
        if qf#IsLocWindow(winnum) && loclist ==# getloclist(winnum)
            return 1
        endif
    endfor

    return 0
endfunction

" Returns items of the current location/quickfix list
"   qf#GetListItems(0, 0) .... all items of the quickfix list
"   qf#GetListItems(0, 5) .... item 5 of the quickfix list
"   qf#GetListItems(1, 0) .... all items of the location list
"   qf#GetListItems(1, 5) .... item 5 of the location list
function! qf#GetListItems(loc, idx)
    let what = { "idx": get(a: "idx", 0), "items": 1 }

    if get(a:, "loc", 0)
        return getloclist(0, what)["items"]
    else
        return getqflist(what)["items"]
    endif
endfunction

" Returns the number of items in a location/quickfix list
"   qf#GetListSize(0) .... size of the quickfix list
"   qf#GetListSize(1) .... size of the location list
function! qf#GetListSize(loc)
    let what = { "size": 1 }

    if get(a:, "loc", 0)
        return getloclist(0, what)["size"]
    else
        return getqflist(what)["size"]
    endif
endfunction

" Returns the maximum height of the location/quickfix window
function! qf#GetMaxHeight()
    return get(g:, "qf_max_height", 10) < 1 ? 10 : get(g:, "qf_max_height", 10)
endfunction

" Sets location or quickfix list based in b:qf_isLoc to passed newlist
function! qf#SetList(newlist, ...)
    " Generate partial
    let Func = get(b:, 'qf_isLoc', 0)
                \ ? function('setloclist', [0, a:newlist])
                \ : function('setqflist', [a:newlist])

    " Get user-defined maximum height
    let max_height = qf#GetMaxHeight()

    " Call partial with optional arguments
    call call(Func, a:000)

    if a:newlist == []
        return
    endif

    if get(b:, "qf_isLoc", 0)
        call qf#OpenLocationWindow()
    else
        call qf#OpenQuickfixWindow()
    endif
endfunction

" Open the quickfix window if there are valid errors
function! qf#OpenQuickfixWindow()
    if get(g:, "qf_auto_open_quickfix", 1)
        " Get user-defined maximum height
        let max_height = qf#GetMaxHeight()

        execute get(g:, "qf_auto_resize", 1) ? "cclose|" . min([ max_height, qf#GetListSize(0) ]) . "cwindow" : "cclose|cwindow"
    endif
endfunction

" Open a location window if there are valid locations
function! qf#OpenLocationWindow()
    if get(g:, "qf_auto_open_loclist", 1)
        " Get user-defined maximum height
        let max_height = qf#GetMaxHeight()

        execute get(g:, "qf_auto_resize", 1) ? "lclose|" . min([ max_height, qf#GetListSize(1) ]) . "lwindow" : "lclose|lwindow"
    endif
endfunction

" Handles formatting of the text in the buffer
function! qf#QuickfixTextFunc(options)
    let items = a:options["quickfix"] == 1 ? getqflist() : getloclist(a:options["winid"])

    return items->map({ key, val -> val->qf#format#FormatItem() })
endfunction

let &cpo = s:save_cpo
