" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.1.1
" License:	MIT
" Location:	autoload/toggle.vim
" Website:	https://github.com/romainl/vim-qf
"
" See :help qf for help.
"
" If this doesn't work and you installed vim-qf manually, use the following
" command to index vim-qf's documentation:
"
" :helptags ~/.vim/doc
"
" If you use a runtimepath/plugin manager, read its documentation.

let s:save_cpo = &cpo
set cpo&vim

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

" toggles the quickfix window
function qf#toggle#ToggleQfWindow()
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
function qf#toggle#ToggleLocWindow()
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
        " if qf#IsLocWindow(i) && getloclist(0) == getloclist(i)
        "     echom "-------"
        "     call s:CloseWindow('l')
        "     echom "--------"
        " endif
        if qf#IsLocWindow(i)
            echo "hum"
            if getloclist(0) == getloclist(i)
                call s:CloseWindow('l')
            endif
        endif
    endfor

    call s:OpenWindow('l')
endfunction

let &cpo = s:save_cpo

finish

" template
function qf#toggle#FunctionName(argument)
    if exists("b:isLoc")
        if b:isLoc == 1
            " do something if we are in a location list
        else
            " do something else if we are in a quickfix list
        endif
    endif
endfunction
