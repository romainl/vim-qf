" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.0.2
" License:	Vim License (see :help license)
" Location:	autoload/qf.vim
" Website:	https://github.com/romainl/vim-qf
"
" See qf.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help qf

let s:save_cpo = &cpo
set cpo&vim

" wrap around
function qf#WrapCommand(direction, prefix)
    if a:direction == "up"
        try
            execute a:prefix . "previous"
        catch /^Vim\%((\a\+)\)\=:E553/
            execute a:prefix . "last"
        catch /^Vim\%((\a\+)\)\=:E\%(776\|42\):/
        endtry
    else
        try
            execute a:prefix . "next"
        catch /^Vim\%((\a\+)\)\=:E553/
            execute a:prefix . "first"
        catch /^Vim\%((\a\+)\)\=:E\%(776\|42\):/
        endtry
    endif
endfunction

" do something with each entry
function qf#DoList(line, cmd)
    if exists("b:isLoc")
        let stub = b:isLoc == 1 ? "l" : "c"
    else
        let stub = "c"
    endif
    try
      silent execute stub . "first"
        while 1
            execute a:cmd
            silent execute a:line == 1 ? stub . "next" : stub . "nfile"
        endwhile
    catch /^Vim\%((\a\+)\)\=:E\%(553\|42\):/
    endtry
endfunction

" filter the current list
function qf#FilterList(pat)
    call qf#AddList()
    call qf#AddTitle(w:quickfix_title)

    call qf#SetList(a:pat)

    call qf#SetTitle(a:pat)
    call qf#AddTitle(w:quickfix_title)
endfunction

" restore the original list
function qf#RestoreList()
    if exists("b:isLoc")
        if b:isLoc == 1
            let lists = getwinvar(winnr("#"), "qf_location_lists")
            if len(lists) > 0
                call setloclist(0, getwinvar(winnr("#"), "qf_location_lists")[0], "r")
                let w:quickfix_title = getwinvar(winnr("#"), "qf_location_titles")[0]
            else
                echo "No filter applied. Nothing to restore."
            endif
        else
            if exists("g:qf_quickfix_lists")
                if len(g:qf_quickfix_lists) > 0
                    call setqflist(g:qf_quickfix_lists[0], "r")
                    let w:quickfix_title = g:qf_quickfix_titles[0]
                else
                    echo "No filter applied. Nothing to restore."
                endif
            endif
        endif
    endif
    call qf#ResetLists()
endfunction

function qf#ResetLists()
    if exists("b:isLoc")
        if b:isLoc == 1
            call setwinvar(winnr("#"), "qf_location_lists", [])
            call setwinvar(winnr("#"), "qf_location_titles", [])
        else
            let g:qf_quickfix_lists = []
            let g:qf_quickfix_titles = []
        endif
    endif
endfunction

function qf#SetStatusline()
    if exists("b:isLoc")
        if b:isLoc == 1
            let titles = getwinvar(winnr("#"), "qf_location_titles")
            if len(titles) > 0
                return titles[-1]
            else
                if exists("w:quickfix_title")
                    return w:quickfix_title
                else
                    return ""
                endif
            endif
        else
            if exists("g:qf_quickfix_titles")
                if len(g:qf_quickfix_titles) > 0
                    return g:qf_quickfix_titles[-1]
                else
                    if exists("w:quickfix_title")
                        return w:quickfix_title
                    else
                        return ""
                    endif
                endif
            else
                if exists("w:quickfix_title")
                    return w:quickfix_title
                else
                    return ""
                endif
            endif
        endif
    endif
endfunction

function qf#SetList(pat)
    if exists("b:isLoc")
        if b:isLoc == 1
            call setloclist(0, filter(getloclist(0), "bufname(v:val['bufnr']) =~ a:pat || v:val['text'] =~ a:pat"), "r")
        else
            call setqflist(filter(getqflist(), "bufname(v:val['bufnr']) =~ a:pat || v:val['text'] =~ a:pat"), "r")
        endif
    endif
endfunction

function qf#AddList()
    if exists("b:isLoc")
        if b:isLoc == 1
            let locations = getwinvar(winnr("#"), "qf_location_lists")
            if len(locations) > 0
                call add(locations, getloclist(0))
                call setwinvar(winnr("#"), "qf_location_lists", locations)
            else
                call setwinvar(winnr("#"), "qf_location_lists", [getloclist(0)])
            endif
        else
            if exists("g:qf_quickfix_lists")
                let g:qf_quickfix_lists = add(g:qf_quickfix_lists, getqflist())
            else
                let g:qf_quickfix_lists = [getqflist()]
            endif
        endif
    endif
endfunction

function qf#SetTitle(pat)
    if exists("b:isLoc")
        if b:isLoc == 1
            let w:quickfix_title = getwinvar(winnr("#"), "qf_location_titles")[0] . " [filter: '" . a:pat . "']"
        else
            if len(g:qf_quickfix_titles) > 0
                let w:quickfix_title = g:qf_quickfix_titles[0] . " [filter: '" . a:pat . "']"
            else
                let w:quickfix_title = w:quickfix_title . " [filter: '" . a:pat . "']"
            endif
        endif
    endif
endfunction

function qf#AddTitle(title)
    if exists("b:isLoc")
        if b:isLoc == 1
            let titles = getwinvar(winnr("#"), "qf_location_titles")
            if len(titles) > 0
                call add(titles, a:title)
                call setwinvar(winnr("#"), "qf_location_titles", titles)
            else
                call setwinvar(winnr("#"), "qf_location_titles", [a:title])
            endif
        else
            if exists("g:qf_quickfix_titles")
                let g:qf_quickfix_titles = add(g:qf_quickfix_titles, a:title)
            else
                let g:qf_quickfix_titles = [a:title]
            endif
        endif
    endif
endfunction

function qf#ReuseTitle()
    if exists("b:isLoc")
        if b:isLoc == 1
            let titles = getwinvar(winnr("#"), "qf_location_titles")
            if len(titles) > 0
                let w:quickfix_title = getwinvar(winnr("#"), "qf_location_titles")[0]"
            endif
        else
            if exists("g:qf_quickfix_titles")
                let w:quickfix_title = g:qf_quickfix_titles[0]
            endif
        endif
    endif
endfunction

" template
function qf#FunctionName(argument)
    if exists("b:isLoc")
        if b:isLoc == 1
            " do something
        else
            " do something else
        endif
    endif
endfunction

let &cpo = s:save_cpo
