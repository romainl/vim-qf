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

    " get user-defined maximum height
    let max_height = get(g:, 'qf_max_height', 10) < 1 ? 10 : get(g:, 'qf_max_height', 10)

    " if one of the windows is a quickfix window close it and return
    if qf#IsQfWindowOpen()
        cclose
        if !empty(winview)
            call winrestview(winview)
        endif
    else
        execute get(g:, 'qf_auto_resize', 1) ? min([ max_height, len(getqflist()) ]) . 'cwindow' : max_height . 'cwindow'
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

    " get user-defined maximum height
    let max_height = get(g:, 'qf_max_height', 10) < 1 ? 10 : get(g:, 'qf_max_height', 10)

    if qf#IsLocWindowOpen(0)
        lclose
        if !empty(winview)
            call winrestview(winview)
        endif
    else
        execute get(g:, 'qf_auto_resize', 1) ? min([ max_height, len(getloclist(0)) ]) . 'lwindow' : max_height . 'lwindow'
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

let &cpo = s:save_cpo
