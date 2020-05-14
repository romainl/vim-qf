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

function! s:flip(is_qf, cur_list)
    let lt = split(a:cur_list.context, "_")
    if lt[0] == "vimqf"
        let flip_count = lt[-1] - a:cur_list.id
        let cmd = (a:is_qf ? 'c' : 'l') . (flip_count > 0 ? ("newer " . flip_count) : ("older " . abs(flip_count)))
        execute cmd
    endif
endfunction

function! s:ctxarg(is_qf, is_long, cur_list)
    let stack_size = a:is_qf ? getqflist({'nr' : '$'}).nr : getloclist(0, {'nr' : '$'}).nr
    return a:is_long ? {"nr": "$",
                        \ "items": qf#ShortenPathsInList(a:cur_list.items),
                        \ "context": "vimqf_long_at_" . a:cur_list.id}
                    \ : {"id": a:cur_list.id, "context": "vimqf_short_at_" . stack_size}
endfunction

function! qf#toggle#ToggleShortenPath() abort
    if qf#IsQfWindowOpen()
        let cur = getqflist({"all": 0})
        if len(cur.context) > 0 && type(cur.context) == type("")
            call s:flip(1, cur)
        elseif cur.context == "" && get(g:, 'qf_shorten_path') == 0
            call setqflist([], " ", s:ctxarg(1, 1, cur))
            call setqflist([], "a", s:ctxarg(1, 0, cur))
        endif
    elseif qf#IsLocWindowOpen(0)
        let cur = getloclist(0, {"all": 0})
        if len(cur.context) > 0 && type(cur.context) == type("")
            call s:flip(0, cur)
        elseif cur.context == "" && get(g:, 'qf_shorten_path') == 0
            call setloclist(0, [], " ", s:ctxarg(0, 1, cur))
            call setloclist(0, [], "a", s:ctxarg(0, 0, cur))
        endif
    endif
endfunction

let &cpo = s:save_cpo
