" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.0.7
" License:	MIT
" Location:	after/ftplugin/qf.vim
" Website:	https://github.com/romainl/vim-qf
"
" See qf.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help qf

let s:save_cpo = &cpo
set cpo&vim

let b:undo_ftplugin = "setl fo< com< ofu<"

" text wrapping is pretty much useless in the quickfix window
setlocal nowrap

" relative line numbers don't make much sense either
" but absolute numbers do
setlocal norelativenumber
setlocal number

" we don't want quickfix buffers to pop up when doing :bn or :bp
set nobuflisted

" are we in a location list or a quickfix list?
let b:isLoc = len(getloclist(0)) > 0 ? 1 : 0

" customize the statusline
if exists("g:qf_statusline")
    execute "setlocal statusline=" . g:qf_statusline.before . "%{qf#SetStatusline()}" . g:qf_statusline.after
endif

" inspired by Ack.vim
if exists("g:qf_mapping_ack_style")
    " open entry in a new horizontal window
    nnoremap <buffer> s <C-w><CR>
    " open entry in a new vertical window.
    nnoremap <buffer> v <C-w><CR><C-w>L<C-w>p<C-w>J<C-w>p
    " open entry in a new tab.
    nnoremap <buffer> t <C-w><CR><C-w>T
    " open entry and come back
    nnoremap <buffer> o <CR><C-w>p
    " open entry and close the location/quickfix window.
    if b:isLoc == 1
        nnoremap <buffer> O <CR>:lclose<CR>
    else
        nnoremap <buffer> O <CR>:cclose<CR>
    endif
endif

" filter the location/quickfix list
" (kept for backward compatibility)
" usage:
"   :Filter foo     <-- same as :Keep foo
"   :Filter! foo    <-- same as :Reject foo
command! -buffer -nargs=1 -bang Filter call qf#FilterList(<q-args>, expand("<bang>") == "!" ? 1 : 0)

" keep entries matching the argument
" usage:
"   :Keep foo
command! -buffer -nargs=1 Keep call qf#FilterList(<q-args>, 0)

" reject entries matching the argument
" usage:
"   :Reject foo
command! -buffer -nargs=1 Reject call qf#FilterList(<q-args>, 1)

" restore the location/quickfix list
" usage:
"   :Restore
command! -buffer Restore call qf#RestoreList()

" do something on each line in the location/quickfix list
" usage:
"   :Doline s/^/---
command! -buffer -nargs=1 Doline call qf#DoList(1, <q-args>)

" do something on each file in the location/quickfix list
" usage:
"   :Dofile %s/^/---
command! -buffer -nargs=1 Dofile call qf#DoList(0, <q-args>)

" save current loc/qf list and associate it with a given name or the
" last used name
command! -buffer -nargs=? -complete=customlist,qf#CompleteList SaveList    call qf#SaveList(0, <q-args>)
" like SaveList, but add to a potentially existing named list
command! -buffer -nargs=? -complete=customlist,qf#CompleteList SaveListAdd call qf#SaveList(1, <q-args>)

" replace loc/qf list with named lists
command! -buffer -nargs=+ -complete=customlist,qf#CompleteList LoadList    call qf#LoadList(0, <q-args>)
" like LoadList but append instead of replace
command! -buffer -nargs=+ -complete=customlist,qf#CompleteList LoadListAdd call qf#LoadList(1, <q-args>)

" list currently saved lists
command! -buffer ListLists call qf#ListLists()
" remove given lists or all
command! -buffer -nargs=* -bang -complete=customlist,qf#CompleteList RemoveList call qf#RemoveList(expand("<bang>") == "!" ? 1 : 0, <q-args>)

" TODO: allow customization
" jump to previous/next file grouping
nnoremap <silent> <buffer> } :call qf#NextFile()<CR>
nnoremap <silent> <buffer> { :call qf#PreviousFile()<CR>

" quit Vim if the last window is a quickfix window
autocmd qf BufEnter    <buffer> if winnr('$') < 2 | q | endif
autocmd qf BufWinEnter <buffer> call qf#ReuseTitle()

if exists("b:isLoc")
    if b:isLoc == 1
        if get(g:, 'qf_loclist_window_bottom', 1)
            wincmd J
        endif
    else
        if get(g:, 'qf_window_bottom', 1)
            wincmd J
        endif
    endif
endif

let &cpo = s:save_cpo
