" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/filter.vim
" Website:	https://github.com/romainl/vim-qf

let s:save_cpo = &cpo
set cpo&vim

" deletes every original list
function! s:ResetLists()
    if qf#IsLocWindow()
        call winnr("#")->setwinvar("qf_location_lists", [])
        call winnr("#")->setwinvar("qf_location_titles", [])
    endif

    if qf#IsQfWindow()
        let g:qf_quickfix_lists  = []
        let g:qf_quickfix_titles = []
    endif
endfunction

function! s:FilteredList(list, pat, range, reject, strategy)
    " decide what regexp operator to use
    let operator = a:reject == 0 ? '=~' : '!~'

    " create an empty list
    let new_list = []

    " bufname && text
    if a:strategy == 0
        let new_list = a:list->filter("(bufname(v:val['bufnr']) .. v:val['text'] " .. operator .. " a:pat)")
    endif

    " only bufname
    if a:strategy == 1
        let new_list = a:list->filter("bufname(v:val['bufnr']) " .. operator .. " a:pat")
    endif

    " only text
    if a:strategy == 2
        let new_list = a:list->filter("v:val['text'] " .. operator .. " a:pat")
    endif

    " range
    if a:strategy == 3
        if a:reject
            let current_list = a:list

            " remove range from list
            call current_list->remove(a:range[0], a:range[1])

            let new_list = current_list
        else
            " take range from list
            let new_list = a:list->remove(a:range[0], a:range[1])
        endif
    endif

    return new_list
endfunction

function! s:AddList()
    if qf#IsLocWindow()
        let locations = winnr("#")->getwinvar("qf_location_lists")

        if !locations->empty()
            call locations->add(qf#GetListItems(1))

            call winnr("#")->setwinvar("qf_location_lists", locations)
        else
            call winnr("#")->setwinvar("qf_location_lists", [qf#GetListItems(1)])
        endif
    endif

    if qf#IsQfWindow()
        if exists("g:qf_quickfix_lists")
            let g:qf_quickfix_lists = add(g:qf_quickfix_lists, qf#GetListItems())
        else
            let g:qf_quickfix_lists = [qf#GetListItems()]
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
    let action = a:reject == 0 ? "keep" : "reject"

    " describe the filter that was applied
    if a:pat != ''
        let filter = "'" .. a:pat .. "'"
    else
        if a:range[0] == a:range[1]
            let filter = "entry " .. (a:range[0] + 1)
        else
            let filter = "entries " .. (a:range[0] + 1) .. ".." .. (a:range[1] + 1)
        endif
    endif

    let str = " [" .. action .. ": " .. filter .. "]"

    if qf#IsLocWindow()
        call s:SetTitleValue(winnr("#")->getwinvar("qf_location_titles")[0] .. str)
    endif

    if qf#IsQfWindow()
        if exists("g:qf_quickfix_titles")
            if !g:qf_quickfix_titles->empty()
                call s:SetTitleValue(g:qf_quickfix_titles[0] .. str)
            else
                call s:SetTitleValue(w:quickfix_title .. str)
            endif
        else
            call s:SetTitleValue(w:quickfix_title .. str)
        endif
    endif
endfunction

" Perform the actual title value assignments. w:quickfix_title is always set,
" and if this Vim supports it (>7.4.2200), the list title is also updated,
" allowing the title to be reused after :[cl]older/:[cl]newer
function! s:SetTitleValue(title)
    let w:quickfix_title = a:title
    " Update the quickfix/location list title if this Vim supports it
    if qf#IsLocWindow()
        noautocmd call setloclist(0, [], "a", {"title": a:title})
    endif

    if qf#IsQfWindow()
        noautocmd call setqflist([], "a", {"title": a:title})
    endif
endfunction

" store the current title
function! s:AddTitle(title)
    if qf#IsLocWindow()
        let titles = winnr("#")->getwinvar("qf_location_titles")

        if !titles->empty()
            call titles->add(a:title)

            call winnr("#")->setwinvar("qf_location_titles", titles)
        else
            call winnr("#")->setwinvar("qf_location_titles", [a:title])
        endif
    endif

    if qf#IsQfWindow()
        let g:qf_quickfix_titles = get(g:, "qf_quickfix_titles", [])->add(a:title)
    endif
endfunction

function! s:GetSelection()
    let old_reg = getreg("v")
    normal! gv"vy
    let raw_search = getreg("v")
    call setreg("v", old_reg)
    return raw_search
                \ ->escape('\/.*$^~[]')
                \ ->substitute("\n", '\\n', "g")
endfunction

" filter the current list
function! qf#filter#FilterList(pat, reject, lnum1, lnum2, cnt)
    let strategy = get(g:, "qf_bufname_or_text", 0)
    let pat      = ""
    let range    = []

    if a:pat != ""
        let pat = a:pat
    else
        if a:cnt == -1
            " no range was given
            "   :Reject
            if col(".") == 1
                if get(g:, "qf_shorten_path", 1)
                    let pat  = split(split(getline("."), "|")[0], "/")[-1]
                else
                    let pat  = split(getline("."), "|")[0]
                endif
                let strategy = 1
            else
                let pat      = expand("<cword>")
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

    if qf#IsLocWindow() || qf#IsQfWindow()
        call s:AddList()
        call s:AddTitle(get(w:, "quickfix_title", " "))

        call qf#GetListItems(qf#IsLocWindow(), 0)
                    \ ->s:FilteredList(pat, range, a:reject, strategy)
                    \ ->s:ReplaceList(qf#IsLocWindow())

        call s:SetTitle(pat, range, a:reject)
        call s:AddTitle(get(w:, "quickfix_title", " "))
    endif
endfunction

function! s:ReplaceList(new_list, loc)
    if a:loc == 1
        call setloclist(0, a:new_list, "r")
    else
        call setqflist(a:new_list, "r")
    endif

    call qf#OpenWindow(a:loc)
endfunction

" restore the original list
function! qf#filter#RestoreList()
    if qf#IsLocWindow()
        let lists = winnr("#")->getwinvar("qf_location_lists")

        if !lists->empty()
            call setloclist(0, winnr("#")->getwinvar("qf_location_lists")[0], "r")

            call qf#OpenWindow(1)

            call s:SetTitleValue(winnr("#")->getwinvar("qf_location_titles")[0])
        else
            echo "No filter applied. Nothing to restore."
        endif
    endif

    if qf#IsQfWindow()
        if exists("g:qf_quickfix_lists")
            if !g:qf_quickfix_lists->empty()
                call setqflist(g:qf_quickfix_lists[0], "r")

                call qf#OpenWindow(0)

                call s:SetTitleValue(g:qf_quickfix_titles[0])
            else
                echo "No filter applied. Nothing to restore."
            endif
        endif
    endif

    call s:ResetLists()
endfunction

" replace the current title
function! qf#filter#ReuseTitle()
    if qf#IsLocWindow()
        let w:quickfix_title = qf#GetListTitle(1)
    endif

    if qf#IsQfWindow()
        let w:quickfix_title = qf#GetListTitle()
    endif
endfunction

let &cpo = s:save_cpo
