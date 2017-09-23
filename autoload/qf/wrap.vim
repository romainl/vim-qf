" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/wrap.vim
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

" wrap around
" TODO (Nelo-T. Wallus): I actually don't know what this does
" TODO (romainl): Built-in :cn/:cp/:ln/:lp stop at the beginning
"                 and end of the list. This allows us to wrap
"                 around.
function! qf#wrap#WrapCommand(direction, prefix)
    if a:direction == "up"
        try
            execute a:prefix . "previous"
        catch /^Vim\%((\a\+)\)\=:E553/
            execute a:prefix . "last"
        catch /^Vim\%((\a\+)\)\=:E\%(325\|776\|42\):/
        endtry
    else
        try
            execute a:prefix . "next"
        catch /^Vim\%((\a\+)\)\=:E553/
            execute a:prefix . "first"
        catch /^Vim\%((\a\+)\)\=:E\%(325\|776\|42\):/
        endtry
    endif

    if &foldopen =~ 'quickfix' && foldclosed(line('.')) != -1
        normal! zv
    endif
endfunction

let &cpo = s:save_cpo
