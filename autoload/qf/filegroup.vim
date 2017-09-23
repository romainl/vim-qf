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

function! s:JumpToFirstItemOfFileChunk() abort
    let l:chunk_file_path = qf#GetEntryPath(getline('.'))

    while line('.') - 1 != 0
                \ && l:chunk_file_path == qf#GetEntryPath(getline(line('.') - 1))
        normal! k
    endwhile

    normal! zz
endfunction

function! s:JumpFileChunk(down) abort
    let l:start_file_path = qf#GetEntryPath(getline('.'))
    let l:direction       = a:down ? 'j' : 'k'
    let l:end             = a:down ? '$' : 1

    while l:start_file_path
                \ == qf#GetEntryPath(getline('.'))
                \    && getline('.') != getline(l:end)
        execute 'normal! ' . l:direction
    endwhile

    call s:JumpToFirstItemOfFileChunk()
endfunction

function! qf#filegroup#PreviousFile() abort
    if exists("b:qf_isLoc")
        call s:JumpFileChunk(0)
    endif
endfunction

function! qf#filegroup#NextFile() abort
    if exists("b:qf_isLoc")
        call s:JumpFileChunk(1)
    endif
endfunction

let &cpo = s:save_cpo
