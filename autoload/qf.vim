" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/qf.vim
" Website:	https://github.com/romainl/vim-qf

let s:save_cpo = &cpo
set cpo&vim

function! s:GetWinInfo(nr)
    let win_id = a:nr != 0 ? win_getid(a:nr) : win_getid()

    return win_id->getwininfo()->get(0, {})
endfunction

" Returns 1 if the window with the given number is a quickfix window
"         0 if the window with the given number is not a quickfix window
" Uses current window if no number is given
function! qf#IsQfWindow(...)
    let info = get(a:, 1, 0)-><SID>GetWinInfo()

    return info->get("quickfix", 0) == 1 && info->get("loclist", 0) == 0
endfunction

" Returns 1 if the window with the given number is a location window
"         0 if the window with the given number is not a location window
" Uses current window if no number is given
function! qf#IsLocWindow(...)
    let info = get(a:, 1, 0)-><SID>GetWinInfo()

    return info->get("loclist", 0) == 1
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

    if loclist->len() > 0
        for winnum in range(1, winnr("$"))
            if qf#IsLocWindow(winnum) && loclist ==# getloclist(winnum)
                return 1
            endif
        endfor
    endif

    return 0
endfunction

" Returns items of the current location/quickfix list
"   qf#GetListItems(0, 0) .... all items of the quickfix list
"   qf#GetListItems(0, 5) .... item 5 of the quickfix list
"   qf#GetListItems(1, 0) .... all items of the location list
"   qf#GetListItems(1, 5) .... item 5 of the location list
function! qf#GetListItems(loc = 0, idx = 0)
    if a:loc == 1
        return getloclist(0, { "idx": a:idx, "items": 1 })["items"]
    else
        return getqflist({ "idx": a:idx, "items": 1 })["items"]
    endif
endfunction

" Returns the number of items in a location/quickfix list
"   qf#GetListSize(0) .... size of the quickfix list
"   qf#GetListSize(1) .... size of the location list
function! qf#GetListSize(loc = 0)
    if a:loc == 1
        return getloclist(0, { "size": 1 })->get("size", 99999)
    else
        return getqflist({ "size": 1 })->get("size", 99999)
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

    " Call partial with optional arguments
    call call(Func, a:000)

    if a:newlist == []
        return
    endif

    call get(b:, "qf_isLoc", 0)->qf#OpenWindow()
endfunction

" Open the quickfix window if there are valid errors
function! qf#OpenQuickfixWindow()
    if get(g:, "qf_auto_open_quickfix", 1)
        call qf#OpenWindow(0)
    endif
endfunction

" Open a location window if there are valid locations
function! qf#OpenLocationWindow()
    if get(g:, "qf_auto_open_loclist", 1)
        call qf#OpenWindow(1)
    endif
endfunction

" Refresh the location/quickfix window
function! qf#OpenWindow(loc)
    let prefix    = get(a:, "loc", 0) ? "l" : "c"
    let list_size = qf#GetListSize(a:loc)

    if list_size > 0
        execute get(g:, "qf_auto_resize", 1)
                    \ ? prefix .. "close|" .. min([ qf#GetMaxHeight(), list_size ]) .. prefix .. "window"
                    \ : prefix .. "close|" .. prefix .. "window"
    endif
endfunction

" Handles formatting of the text in the buffer
function! qf#QuickfixTextFunc(options)
    let items = qf#GetListItems(!a:options["quickfix"], 0)

    return items->map({ key, val -> qf#format#FormatItem(val) })
endfunction

let &cpo = s:save_cpo
