" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/toggle.vim
" Website:	https://github.com/romainl/vim-qf

let s:save_cpo = &cpo
set cpo&vim

" Toggles the quickfix window.
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
        call qf#OpenQuickfixWindow()
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

" Toggles the location window associated with the current window
" or whatever location window has the focus.
function! qf#toggle#ToggleLocWindow(stay) abort
    " save the view if the current window is not a location window
    if get(g:, 'qf_save_win_view', 1) && qf#IsLocWindow(winnr())
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
        call qf#OpenLocationWindow()
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
