" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/namedlist.vim
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

let s:named_lists = {}
let s:last_saved_list = ''

function! qf#namedlist#SaveList(add, name) abort
    if a:name == ''
        if s:last_saved_list == ''
            echomsg 'No last saved list'

            return
        endif

        let curname = s:last_saved_list
    else
        let curname           = a:name
        let s:last_saved_list = curname
    endif

    let curlist = qf#GetList()

    if empty(curlist)
        " fail silently on empty lists
        return
    endif

    for entry in curlist
        " grab the correct filename for setqflist() in case the
        " corresponding buffer is being closed in the meantime
        let entry.filename = bufname(entry.bufnr)
        unlet entry.bufnr

        " unlet valid, not recognized by setqflist()
        unlet entry.valid
    endfor

    if a:add
        let s:named_lists[curname] += curlist
    else
        let s:named_lists[curname] = curlist
    endif
endfunction

" loads the given named list
function! qf#namedlist#LoadList(add, ...)
    if empty(a:000)
        let names = [ s:last_saved_list ]
    else
        let names = a:000
    endif

    if !a:add
        call qf#SetList([])
    endif

    for name in names
        if ! has_key(s:named_lists, name)
            echomsg 'No list named "' . name . '" saved'
            return
        endif

        call qf#SetList(s:named_lists[name], 'a')
    endfor
endfunction

" echoes a simple list of the current named lists
function! qf#namedlist#ListLists()
    for name in keys(s:named_lists)
        echo name
    endfor
endfunction

" removes lists from the current named lists
function! qf#namedlist#RemoveList(bang, ...)
    if a:bang
        let s:named_lists = {}
    else
        for name in a:000
            call remove(s:named_lists, name)
        endfor
    endif
endfunction

" pulls suggestions from the current named lists
function! qf#namedlist#CompleteList(ArgLead, CmdLine, CursorPos)
    let completions = []

    for name in keys(s:named_lists)
        if name =~ a:ArgLead
            call add(completions, name)
        endif
    endfor

    return completions
endfunction

let &cpo = s:save_cpo
