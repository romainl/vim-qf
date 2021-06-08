" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/filegroup.vim
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

function! qf#filegroup#NextFile() abort
    if exists("b:qf_isLoc")
        let items = qf#GetListItems(b:->get("qf_isLoc", 0), 0)
        let current_index = line('.') - 1
        let current_bufnr = items[current_index]["bufnr"]
        let limit = items->len()

        while current_index < limit && items[current_index]["bufnr"] == current_bufnr
            let current_index += 1
        endwhile

        if current_index == limit
            1
        else
            execute current_index + 1
        endif
    endif
endfunction

function! qf#filegroup#PreviousFile() abort
    if exists("b:qf_isLoc")
        let items = qf#GetListItems(b:->get("qf_isLoc", 0), 0)
        let current_index = line('.') - 1
        let current_bufnr = items[current_index]["bufnr"]
        let limit = 0

        while current_index > limit && items[current_index]["bufnr"] == current_bufnr
            let current_index -= 1
        endwhile

        if current_index == limit
            normal! G
        else
            execute current_index + 1
        endif

        let current_index = line('.') - 1
        let current_bufnr = items[current_index]["bufnr"]

        while current_index > limit && items[current_index]["bufnr"] == current_bufnr
            let current_index -= 1
        endwhile

        if current_index == limit
            1
        else
            execute current_index + 2
        endif
    endif
endfunction

let &cpo = s:save_cpo
