" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.1.1
" License:	MIT
" Location:	autoload/filegroup.vim
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

" jump to previous/next file grouping
function s:GetFilePath(line) abort
    "                          +- match from the first pipe to the end of line
    "                          |  declaring EOL explicitly is faster than implicitly
    "                          |      +- replace match with nothing
    "                          |      |   +- no flags
    return substitute(a:line, '|.*$', '', '')
endfunction

function s:JumpToFirstItemOfFileChunk() abort
    let l:chunk_file_path = s:GetFilePath(getline('.'))

    while line('.') - 1 != 0 && l:chunk_file_path == s:GetFilePath(getline(line('.') - 1))
        normal! k
    endwhile

    normal! zz
endfunction

function s:JumpFileChunk(down) abort
    let l:start_file_path = s:GetFilePath(getline('.'))
    let l:direction       = a:down ? 'j' : 'k'
    let l:end             = a:down ? '$' : 1

    while l:start_file_path == s:GetFilePath(getline('.')) && getline('.') != getline(l:end)
        execute 'normal! ' . l:direction
    endwhile

    call s:JumpToFirstItemOfFileChunk()
endfunction

function qf#filegroup#PreviousFile() abort
    if exists("b:isLoc")
        call s:JumpFileChunk(0)
    endif
endfunction

function qf#filegroup#NextFile() abort
    if exists("b:isLoc")
        call s:JumpFileChunk(1)
    endif
endfunction

let &cpo = s:save_cpo

finish

" template
function qf#filegroup#FunctionName(argument)
    if exists("b:isLoc")
        if b:isLoc == 1
            " do something if we are in a location list
        else
            " do something else if we are in a quickfix list
        endif
    endif
endfunction
