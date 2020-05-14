" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/toggle.vim
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

" toggles the quickfix window
function! qf#toggle#ToggleQfWindow(stay) abort
    " save the view if the current window is not a quickfix window
    if get(g:, 'qf_save_win_view', 1)  && !qf#IsQfWindow(winnr())
        let winview = winsaveview()
    else
        let winview = {}
    endif

    " if one of the windows is a quickfix window close it and return
    if qf#IsQfWindowOpen()
        cclose
        if !empty(winview)
            call winrestview(winview)
        endif
    else
        cwindow
        if qf#IsQfWindowOpen()
            wincmd p
            if !empty(winview)
                call winrestview(winview)
            endif
            if !a:stay
                wincmd p
            endif
        endif
    endif
endfunction

" toggles the location window associated with the current window
" or whatever location window has the focus
function! qf#toggle#ToggleLocWindow(stay) abort
    " save the view if the current window is not a location window
    if get(g:, 'qf_save_win_view', 1) && !qf#IsLocWindow(winnr())
        let winview = winsaveview()
    else
        let winview = {}
    endif

    if qf#IsLocWindowOpen(0)
        lclose
        if !empty(winview)
            call winrestview(winview)
        endif
    else
        silent! lwindow
        if qf#IsLocWindowOpen(0)
            wincmd p
            if !empty(winview)
                call winrestview(winview)
            endif
            if !a:stay
                wincmd p
            endif
        endif
    endif
endfunction

function! qf#toggle#ToggleShortenPath() abort
    if qf#IsQfWindowOpen()
        "let curlist = qf#GetList()
        let cur = getqflist({"all": 0})
        echom("current qf " . cur.id . " -- " . cur.context)

        if len(cur.context) > 0 && type(cur.context) == type("")
            let lt = split(cur.context, "_")
            if lt[0] == "vimqf"
                let flip_count = lt[-1] - cur.id
                let cmd = flip_count > 0 ? "cnewer " . flip_count : "colder " . abs(flip_count)
                execute cmd
                echom(cmd)
            endif
        elseif cur.context == "" && get(g:, 'qf_shorten_path') == 0
            call setqflist([], " ", {"nr": "$", 
                                    \ "items": qf#ShortenPathsInList(cur.items), 
                                    \ "context": "vimqf_long_at_" . cur.id})
            let stack_size = getqflist({'nr' : '$'}).nr
            echom("cur.id " . cur.id . " size " . stack_size)
            call setqflist([], "a", {"id": cur.id, "context": "vimqf_short_at_" . stack_size})
        endif
    endif
endfunction

let &cpo = s:save_cpo
