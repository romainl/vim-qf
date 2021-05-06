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
    let winview = winsaveview()

    let current_item        = qf#GetListItems(b:->get("qf_isLoc", 0), line('.'))[0]
    let current_file_name   = current_item["bufnr"]->bufname()
    let current_file_line   = current_item->get('lnum', 0)
    let current_file_column = current_item->get('col', 0)

    if current_file_line && current_file_column
        execute "pedit +" .. current_file_line .. " " .. current_file_name .. "|normal! " .. current_file_column .. "G"
    elseif current_file_line && !current_file_column
        execute "pedit +" .. current_file_line .. " " .. current_file_name
    else
        execute "pedit " .. current_file_name
    endif

    call winrestview(winview)
endfunction

let &cpo = s:save_cpo
