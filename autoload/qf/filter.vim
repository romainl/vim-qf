" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.1.1
" License:	MIT
" Location:	autoload/filter.vim
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

" deletes every original list
function! s:ResetLists()
    if exists("b:qf_isLoc")
        if b:qf_isLoc == 1
            call setwinvar(winnr("#"), "qf_location_lists", [])
            call setwinvar(winnr("#"), "qf_location_titles", [])
        else
            let g:qf_quickfix_lists = []
            let g:qf_quickfix_titles = []
        endif
    endif
endfunction

function! s:SetList(pat, reject)
    let operator  = a:reject == 0 ? "=~" : "!~"
    let condition = a:reject == 0 ? "||" : "&&"

    if exists("b:qf_isLoc")
        if b:qf_isLoc == 1
            call setloclist(0, filter(getloclist(0), "bufname(v:val['bufnr']) " . operator . " a:pat " . condition . " v:val['text'] " . operator . " a:pat"), "r")
            lclose
            execute min([ 10, len(getloclist(0)) ]) 'lwindow'
        else
            call setqflist(filter(getqflist(), "bufname(v:val['bufnr']) " . operator . " a:pat " . condition . " v:val['text'] " . operator . " a:pat"), "r")
            cclose
            execute min([ 10, len(getqflist()) ]) 'cwindow'
        endif
    endif
endfunction

function! s:AddList()
    if exists("b:qf_isLoc")
        if b:qf_isLoc == 1
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
function! s:SetTitle(pat, reject)
    " did we use :Keep or :Reject?
    let str = a:reject == 0 ? "keep" : "reject"

    if exists("b:qf_isLoc")
        if b:qf_isLoc == 1
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
function! s:AddTitle(title)
    if exists("b:qf_isLoc")
        if b:qf_isLoc == 1
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

" filter the current list
function! qf#filter#FilterList(pat, reject)
    if exists("b:qf_isLoc")
        call s:AddList()
        call s:AddTitle(w:quickfix_title)

        call s:SetList(a:pat, a:reject)

        call s:SetTitle(a:pat, a:reject)
        call s:AddTitle(w:quickfix_title)
    endif
endfunction

" restore the original list
function! qf#filter#RestoreList()
    if exists("b:qf_isLoc")
        if b:qf_isLoc == 1
            let lists = getwinvar(winnr("#"), "qf_location_lists")

            if len(lists) > 0
                call setloclist(0, getwinvar(winnr("#"), "qf_location_lists")[0], "r")
                lclose
                execute min([ 10, len(getloclist(0)) ]) 'lwindow'

                let w:quickfix_title = getwinvar(winnr("#"), "qf_location_titles")[0]
            else
                echo "No filter applied. Nothing to restore."
            endif
        else
            if exists("g:qf_quickfix_lists")
                if len(g:qf_quickfix_lists) > 0
                    call setqflist(g:qf_quickfix_lists[0], "r")
                    cclose
                    execute min([ 10, len(getqflist()) ]) 'cwindow'

                    let w:quickfix_title = g:qf_quickfix_titles[0]
                else
                    echo "No filter applied. Nothing to restore."
                endif
            endif
        endif
    endif

    call s:ResetLists()
endfunction

" replace the current title
function! qf#filter#ReuseTitle()
    if exists("b:qf_isLoc")
        if b:qf_isLoc == 1
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

let &cpo = s:save_cpo
