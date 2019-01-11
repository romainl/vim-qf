" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/history.vim
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

function! s:history(newer)
    let loc = get(b:, 'qf_isLoc', 0)
    let cmd = (loc ? 'l' : 'c') . (a:newer ? 'newer' : 'older')

    try
        execute cmd
    catch /^Vim\%((\a\+)\)\=:E\%(380\|381\):/
    endtry
endfunction

function! qf#history#Older()
    call s:history(0)
endfunction

function! qf#history#Newer()
    call s:history(1)
endfunction

let &cpo = s:save_cpo
