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

" returns current location list or quickfix list
function! qf#GetListItems(idx)
    let what = { 'idx': a:->get('idx', 0), 'items': 1 }

    if get(b:, 'qf_isLoc', 0)
        return getloclist(0, what)["items"]
    else
        return getqflist(what)["items"]
    endif
endfunction

" helper
" returns the number of items in a loc/qf list
function! qf#GetListSize()
    let what = { 'size': 1 }

    if get(b:, 'qf_isLoc', 0)
        return getloclist(0, what)["size"]
    else
        return getqflist(what)["size"]
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

" open the quickfix window if there are valid errors
function! qf#OpenQuickfixWindow()
    if get(g:, 'qf_auto_open_quickfix', 1)
        " get user-defined maximum height
        let max_height = get(g:, 'qf_max_height', 10) < 1 ? 10 : get(g:, 'qf_max_height', 10)

        execute get(g:, "qf_auto_resize", 1) ? 'cclose|' . min([ max_height, qf#GetListSize() ]) . 'cwindow' : 'cclose|cwindow'
    endif
endfunction

" open a location window if there are valid locations
function! qf#OpenLocationWindow()
    if get(g:, 'qf_auto_open_loclist', 1)
        " get user-defined maximum height
        let max_height = get(g:, 'qf_max_height', 10) < 1 ? 10 : get(g:, 'qf_max_height', 10)

        execute get(g:, "qf_auto_resize", 1) ? 'lclose|' . min([ max_height, qf#GetListSize() ]) . 'lwindow' : 'lclose|lwindow'
    endif
endfunction

function! qf#QuickfixTextFunc(options)
    let items = a:options["quickfix"] == 1 ? getqflist() : getloclist(a:options["winid"])
    return items->map({ key, val -> val->qf#FormatItem() })
endfunction

function! qf#FormatItem(item)
    return [
                \ a:item->qf#FormatFilename(),
                \ a:item->qf#FormatLocation(),
                \ a:item->qf#FormatText(),
                \ ]->join('|')
endfunction

function! qf#FormatFilename(item)
    let filename = a:item["bufnr"]->bufname()

    if has('patch-8.2.1741')
        return pathshorten(filename, g:->get("qf_shorten_path", 1))
    else
        return pathshorten(filename)
    endif
endfunction

function! qf#FormatLocation(item)
    return [
                \ a:item->get("lnum", 0)->qf#FormatLineNumber(),
                \ a:item->get("col", 0)->qf#FormatColumn(),
                \ a:item->get("type", '')->qf#FormatType(),
                \ a:item->get("nr", 0)->qf#FormatErrorNumber(),
                \ ]->join('')
endfunction

function! qf#FormatText(item)
    " return ' ' .. a:item->get("text", '')
    return a:item["text"]
endfunction

function! qf#FormatLineNumber(lnum)
    return a:lnum != 0 ? a:lnum : '-'
endfunction

function! qf#FormatColumn(col)
    return a:col > 0 ? ' col ' .. a:col : ''
endfunction

function! qf#FormatType(type)
    if a:type =~? 'e'
        return ' error'
    elseif a:type =~? 'i'
        return ' info'
    elseif a:type =~? 'n'
        return ' note'
    elseif a:type =~? 'w'
        return ' warning'
    else
        return ''
    endif
endfunction

function! qf#FormatErrorNumber(nr)
    if a:nr > 0
        if a:nr->string()->len() == 1
            return '   ' .. a:nr
        elseif a:nr->string()->len() == 2
            return '  ' .. a:nr
        else
            return ' ' .. a:nr
        endif
    else
        return ''
    endif
endfunction

let &cpo = s:save_cpo
