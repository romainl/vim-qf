" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/preview.vim
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

" open the current entry in th preview window
function! qf#preview#PreviewFileUnderCursor()
    let cur_list = qf#GetList()
    let cur_line = getline(line('.'))
    let cur_file = fnameescape(qf#GetEntryPath(cur_line))

    if cur_line =~ '|\d\+'
        let cur_pos  = substitute(cur_line, '^\(.\{-}|\)\(\d\+\)\(.*\)', '\2', '')
        execute "pedit +" . cur_pos . " " . cur_file
    else
        execute "pedit " . cur_file
    endif
endfunction

let &cpo = s:save_cpo
