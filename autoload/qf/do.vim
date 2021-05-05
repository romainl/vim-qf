" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/do.vim
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

" Do something with each entry
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Handles :Doline and :Dofile, in quickfix and location lists.
" Wrapper aound :cdo, :cfdo, :ldo, :lfdo.
function! qf#do#DoList(line, cmd)
    let prefix   = b:->get("qf_isLoc", 1) ? "l" : "c"
    let modifier = a:line == 1 ? "" : "f"

    try
        execute prefix . modifier . "do " . a:cmd
    catch /^Vim\%((\a\+)\)\=:E\%(553\|42\):/
    endtry
endfunction

let &cpo = s:save_cpo
