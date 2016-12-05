" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.1.0
" License:	MIT
" Location:	autoload/qf.vim
" Website:	https://github.com/romainl/vim-qf
"
" See qf.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help qf

let s:save_cpo = &cpo
set cpo&vim

" open the current entry in th preview window
function qf#PreviewFileUnderCursor()
    let cur_list = b:isLoc == 1 ? getloclist('.') : getqflist()
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
" " returns 1 if the window with the given number is a quickfix window
" "         0 if the window with the given number is not a quickfix window
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

" toggles the quickfix window
function qf#ToggleQfWindow()
    " assume we don't have a quickfix window
    let has_qf_window = 0

    " save the view if the current window is not a quickfix window
    if ! qf#IsQfWindow(winnr())
        let t:my_winview = winsaveview()
    endif

    " if one of the windows is a quickfix window close it and return
    for winnumber in range(winnr("$"))
        if qf#IsQfWindow(winnumber + 1)
            call s:CloseWindow('c')
            return
        endif
    endfor

    " there's no quickfix window so open one
    call s:OpenWindow('c')
endfunction

" toggles the location window associated with the current window
" " or whatever location window has the focus
function qf#ToggleLocWindow()
    " assume we don't have a location window
    let has_loc_window = 0

    " save the view if the current window is not a location window
    if ! qf#IsLocWindow(winnr())
        let t:my_winview = winsaveview()
    endif

    " close the current window if it's a location window and return
    if qf#IsLocWindow(winnr())
        call s:CloseWindow('l')
        return
    endif

    for i in range(winnr("$"))
        if qf#IsLocWindow(i) && getloclist(0) == getloclist(i)
            call s:CloseWindow('l')
        endif
    endfor

    call s:OpenWindow('l')
endfunction

function s:OpenWindow(prefix)
    exec a:prefix . 'window'

    wincmd p

    if exists("my_winview")
        call winrestview(t:my_winview)
    endif

    wincmd p
endfunction

function s:CloseWindow(prefix)
    exec a:prefix . 'close'

    if exists("my_winview")
        call winrestview(t:my_winview)
    endif
endfunction


" jump to previous/next file grouping
function qf#GetFilePath(line) abort
    return substitute(a:line, '|.*$', '', '')
    "                          |      |   +- no flags
    "                          |      +- replace match with nothing
    "                          +- match from the first pipe to the end of line
    "                             declaring EOL explicitly is faster than implicitly
endfunction

function qf#JumpToFirstItemOfFileChunk() abort
    let l:chunk_file_path = qf#GetFilePath(getline('.'))

    while line('.') - 1 != 0 && l:chunk_file_path == qf#GetFilePath(getline(line('.') - 1))
        normal! k
    endwhile

    normal! zz
endfunction

function qf#JumpFileChunk(down) abort
    let l:start_file_path = qf#GetFilePath(getline('.'))
    let l:direction       = a:down ? 'j' : 'k'
    let l:end             = a:down ? '$' : 1

    while l:start_file_path == qf#GetFilePath(getline('.')) && getline('.') != getline(l:end)
        execute 'normal! ' . l:direction
    endwhile

    call qf#JumpToFirstItemOfFileChunk()
endfunction

function qf#PreviousFile() abort
    if exists("b:isLoc")
        call qf#JumpFileChunk(0)
    endif
endfunction

function qf#NextFile() abort
    if exists("b:isLoc")
        call qf#JumpFileChunk(1)
    endif
endfunction

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

    if &foldopen =~ 'quickfix' && foldclosed(line('.')) != -1
        normal! zv
    endif
endfunction

" do something with each entry
" a single function for :Doline and :Dofile both in a quickfix list and
" a location list
" falls back to :cdo, :cfdo, :ldo, :lfdo when possible
function qf#DoList(line, cmd)
    if exists("b:isLoc")
        let prefix = b:isLoc == 1 ? "l" : "c"
    else
        let prefix = "c"
    endif

    if v:version >= 705 || v:version == 704 && has("patch858")
        if a:line == 1
            let modifier = ""
        else
            let modifier = "f"
        endif

        try
            execute prefix . modifier . "do " . a:cmd
        catch /^Vim\%((\a\+)\)\=:E\%(553\|42\):/
        endtry
    else
        try
            silent execute prefix . "first"
            while 1
                execute a:cmd

                silent execute a:line == 1 ? prefix . "next" : prefix . "nfile"
            endwhile
        catch /^Vim\%((\a\+)\)\=:E\%(553\|42\):/
        endtry
    endif
endfunction

" filter the current list
function qf#FilterList(pat, reject)
    if exists("b:isLoc")
        call qf#AddList()
        call qf#AddTitle(w:quickfix_title)

        call qf#SetList(a:pat, a:reject)

        call qf#SetTitle(a:pat, a:reject)
        call qf#AddTitle(w:quickfix_title)
    endif
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

" deletes every original list
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

" used to inject the current title into the current status line
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

function qf#SetList(pat, reject)
    let operator  = a:reject == 0 ? "=~" : "!~"
    let condition = a:reject == 0 ? "||" : "&&"

    if exists("b:isLoc")
        if b:isLoc == 1
            call setloclist(0, filter(getloclist(0), "bufname(v:val['bufnr']) " . operator . " a:pat " . condition . " v:val['text'] " . operator . " a:pat"), "r")
        else
            call setqflist(filter(getqflist(), "bufname(v:val['bufnr']) " . operator . " a:pat " . condition . " v:val['text'] " . operator . " a:pat"), "r")
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

" sets the proper title for the current window after :Keep and :Reject
"   - location window:
"       :lgrep foo sample.txt [keep: 'bar']
"       :lgrep foo sample.txt [reject: 'bar']
"   - quickfix window:
"       :grep foo sample.txt [keep: 'bar']
"       :grep foo sample.txt [reject: 'bar']
function qf#SetTitle(pat, reject)
    " did we use :Keep or :Reject?
    let str = a:reject == 0 ? "keep" : "reject"

    if exists("b:isLoc")
        if b:isLoc == 1
            let w:quickfix_title = getwinvar(winnr("#"), "qf_location_titles")[0] . " [" . str . ": '" . a:pat . "']"
        else
            if exists("g:qf_quickfix_titles")
                if len(g:qf_quickfix_titles) > 0
                    let w:quickfix_title = g:qf_quickfix_titles[0] . " [" . str . ": '" . a:pat . "']"
                else
                    let w:quickfix_title = w:quickfix_title . " [" . str . ": '" . a:pat . "']"
                endif
            else
                let w:quickfix_title = w:quickfix_title . " [" . str . ": '" . a:pat . "']"
            endif
        endif
    endif
endfunction

" store the current title
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

" replace the current title
function qf#ReuseTitle()
    if exists("b:isLoc")
        if b:isLoc == 1
            let titles = getwinvar(winnr("#"), "qf_location_titles")

            if len(titles) > 0
                let w:quickfix_title = getwinvar(winnr("#"), "qf_location_titles")[0]"
            endif
        else
            if exists("g:qf_quickfix_titles")
                if len(g:qf_quickfix_titles) > 0
                    let w:quickfix_title = g:qf_quickfix_titles[0]
                endif
            endif
        endif
    endif
endfunction

let s:named_lists = {}
let s:last_saved_list = ''

function qf#SaveList(add, name) abort
    if a:name != ''
        let curname           = a:name
        let s:last_saved_list = curname
    else
        if s:last_saved_list == ''
            echomsg 'No last saved list'

            return
        endif

        let curname = s:last_saved_list
    endif

    if get(b:, 'isLoc', 0)
        let curlist = getloclist(0)
    else
        let curlist = getqflist()
    endif

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
function qf#LoadList(add, ...)
    if empty(a:000)
        let names = [ s:last_saved_list ]
    else
        let names = a:000
    endif

    if !a:add
        if get(b:, 'isLoc', 0)
            call setloclist(0, [])
        else
            call setqflist([])
        endif
    endif

    for name in names
        if has_key(s:named_lists, name)
            if get(b:, 'isLoc', 0)
                call setloclist(0, s:named_lists[name], 'a')
            else
                call setqflist(s:named_lists[name], 'a')
            endif
        else
            echomsg 'No list named "' . name . '" saved'
        endif
    endfor
endfunction

" echoes a simple list of the current named lists
function qf#ListLists()
    for name in keys(s:named_lists)
        echo name
    endfor
endfunction

" removes lists from the current named lists
function qf#RemoveList(bang, ...)
    if a:bang
        let s:named_lists = {}
    else
        for name in a:000
            call remove(s:named_lists, name)
        endfor
    endif
endfunction

" pulls suggestions from the current named lists
function qf#CompleteList(ArgLead, CmdLine, CursorPos)
    let completions = []

    for name in keys(s:named_lists)
        if name =~ a:ArgLead
            call add(completions, name)
        endif
    endfor

    return completions
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
