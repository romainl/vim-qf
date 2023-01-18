" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
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

function! s:SetList(pat, range, reject, strategy)
    " decide what regexp operator to use
    let operator   = a:reject == 0 ? '=~' : '!~'
    " get user-defined maximum height
    let max_height = get(g:, 'qf_max_height', 10) < 1 ? 10 : get(g:, 'qf_max_height', 10)

    if exists("b:qf_isLoc")
        if b:qf_isLoc == 1
            " bufname && text
            if a:strategy == 0
                call setloclist(0, filter(getloclist(0), "(bufname(v:val['bufnr']) . v:val['text'] " . operator . " a:pat)"), "r")
            endif

            " only bufname
            if a:strategy == 1
                call setloclist(0, filter(getloclist(0), "bufname(v:val['bufnr']) " . operator . " a:pat"), "r")
            endif

            " only text
            if a:strategy == 2
                call setloclist(0, filter(getloclist(0), "v:val['text'] " . operator . " a:pat"), "r")
            endif

            " range
            if a:strategy == 3
                let current_list = getloclist(0)
                if a:reject
                    " remove range from list
                    call remove(current_list, a:range[0], a:range[1])
                    call setloclist(0, current_list, "r")
                else
                    " take range from list
                    call setloclist(0, remove(current_list, a:range[0], a:range[1]), "r")
                endif
            endif

            execute get(g:, "qf_auto_resize", 1) ? 'lclose|' . min([ max_height, len(getloclist(0)) ]) . 'lwindow' : 'lclose|lwindow'
        else
            " bufname && text
            if a:strategy == 0
                call setqflist(filter(getqflist(), "(bufname(v:val['bufnr']) . v:val['text'] " . operator . " a:pat)"), "r")
            endif

            " only bufname
            if a:strategy == 1
                call setqflist(filter(getqflist(), "bufname(v:val['bufnr']) " . operator . " a:pat"), "r")
            endif

            " only text
            if a:strategy == 2
                call setqflist(filter(getqflist(), "v:val['text'] " . operator . " a:pat"), "r")
            endif

            " range
            if a:strategy == 3
                let current_list = getqflist()
                if a:reject
                    " remove range from list
                    call remove(current_list, a:range[0], a:range[1])
                    call setqflist(current_list, "r")
                else
                    " take range from list
                    call setqflist(remove(current_list, a:range[0], a:range[1]), "r")
                endif
            endif

            execute get(g:, "qf_auto_resize", 1) ? 'cclose|' . min([ max_height, len(getqflist()) ]) . 'cwindow' : 'cclose|cwindow'
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
"       :lgrep foo sample.txt [keep: entries 6..9]
"       :lgrep foo sample.txt [reject: entry 13]
"   - quickfix window:
"       :grep foo sample.txt [keep: 'bar']
"       :grep foo sample.txt [reject: 'bar']
"       :grep foo sample.txt [keep: entries 6..9]
"       :grep foo sample.txt [reject: entry 13]
function! s:SetTitle(pat, range, reject)
    " did we use :Keep or :Reject?
    let action = a:reject == 0 ? 'keep' : 'reject'

    " describe the filter that was applied
    if a:pat != ''
        let filter = "'" . a:pat . "'"
    else
        if a:range[0] == a:range[1]
            let filter = 'entry ' . (a:range[0] + 1)
        else
            let filter = 'entries ' . (a:range[0] + 1) . '..' . (a:range[1] + 1)
        endif
    endif

    let str = " [" . action . ": " . filter . "]"

    if exists("b:qf_isLoc")
        if b:qf_isLoc == 1
            call s:SetTitleValue(getwinvar(winnr("#"), "qf_location_titles")[0] . str)
        else
            if exists("g:qf_quickfix_titles")
                if len(g:qf_quickfix_titles) > 0
                    call s:SetTitleValue(g:qf_quickfix_titles[0] . str)
                else
                    call s:SetTitleValue(w:quickfix_title . str)
                endif
            else
                call s:SetTitleValue(w:quickfix_title . str)
            endif
        endif
    endif
endfunction

" Perform the actual title value assignments. w:quickfix_title is always set,
" and if this Vim supports it (>7.4.2200), the list title is also updated,
" allowing the title to be reused after :[cl]older/:[cl]newer
function! s:SetTitleValue(title)
    let w:quickfix_title = a:title
    " Update the quickfix/location list title if this Vim supports it
    if has('patch-7.4.2200')
        if b:qf_isLoc == 1
            noautocmd call setloclist(0, [], 'a', {'title': a:title})
        else
            noautocmd call setqflist([], 'a', {'title': a:title})
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

function! s:GetSelection()
    let old_reg = getreg("v")
    normal! gv"vy
    let raw_search = getreg("v")
    call setreg("v", old_reg)
    return substitute(escape(raw_search, '\/.*$^~[]'), "\n", '\\n', "g")
endfunction

" filter the current list
function! qf#filter#FilterList(pat, reject, lnum1, lnum2, cnt)
    let strategy = get(g:, 'qf_bufname_or_text', 0)
    let pat      = ''
    let range    = []

    if a:pat != ''
        let pat = a:pat
    else
        if a:cnt == -1
            " no range was given
            "   :Reject
            if col('.') == 1
                if get(g:, 'qf_shorten_path', 1)
                    let pat  = split(split(getline('.'), '|')[0], '/')[-1]
                else
                    let pat  = split(getline('.'), '|')[0]
                endif
                let strategy = 1
            else
                let pat      = expand('<cword>')
                let strategy = 2
            endif
        else
            " a range was given
            "   :.Reject
            "   :10,15Reject
            "   V:'<,'>Reject
            let range    = [ a:lnum1 - 1, a:lnum2 -1 ]
            let strategy = 3
        endif
    endif

    if exists("b:qf_isLoc")
        call s:AddList()
        call s:AddTitle(get(w:, 'quickfix_title', ' '))

        call s:SetList(pat, range, a:reject, strategy)

        call s:SetTitle(pat, range, a:reject)
        call s:AddTitle(get(w:, 'quickfix_title', ' '))
    endif
endfunction

" restore the original list
function! qf#filter#RestoreList()
    " get user-defined maximum height
    let max_height = get(g:, 'qf_max_height', 10) < 1 ? 10 : get(g:, 'qf_max_height', 10)

    if exists("b:qf_isLoc")
        if b:qf_isLoc == 1
            let lists = getwinvar(winnr("#"), "qf_location_lists")

            if len(lists) > 0
                call setloclist(0, getwinvar(winnr("#"), "qf_location_lists")[0], "r")
                execute get(g:, "qf_auto_resize", 1) ? 'lclose|' . min([ max_height, len(getloclist(0)) ]) . 'lwindow' : 'lwindow'

                call s:SetTitleValue(getwinvar(winnr("#"), "qf_location_titles")[0])
            else
                echo "No filter applied. Nothing to restore."
            endif
        else
            if exists("g:qf_quickfix_lists")
                if len(g:qf_quickfix_lists) > 0
                    call setqflist(g:qf_quickfix_lists[0], "r")
                    execute get(g:, "qf_auto_resize", 1) ? 'cclose|' . min([ max_height, len(getqflist()) ]) . 'cwindow' : 'cwindow'

                    call s:SetTitleValue(g:qf_quickfix_titles[0])
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
            if has('patch-7.4.2200')
                let w:quickfix_title = getloclist(0, {'title': 0}).title
            else
                let titles = getwinvar(winnr("#"), "qf_location_titles")

                if len(titles) > 0
                    let w:quickfix_title = getwinvar(winnr("#"), "qf_location_titles")[0]
                endif
            endif
        else
            if has('patch-7.4.2200')
                let w:quickfix_title = getqflist({'title': 0}).title
            else
                if exists("g:qf_quickfix_titles")
                    if len(g:qf_quickfix_titles) > 0
                        let w:quickfix_title = g:qf_quickfix_titles[0]
                    endif
                endif
            endif
        endif
    endif
endfunction

let &cpo = s:save_cpo
