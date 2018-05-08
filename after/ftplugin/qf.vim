" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	after/ftplugin/qf.vim
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

let b:undo_ftplugin = "setl fo< com< ofu<"

" text wrapping is pretty much useless in the quickfix window
" but some users may still want it
execute get(g:, "qf_nowrap", 1) ? "setlocal nowrap" : "setlocal wrap"

" relative line numbers don't make much sense either
" but absolute numbers definitely do
setlocal norelativenumber
setlocal number

" we don't want quickfix buffers to pop up when doing :bn or :bp
set nobuflisted

" are we in a location list or a quickfix list?
let b:qf_isLoc = !empty(getloclist(0))

" customize the statusline
if exists("g:qf_statusline")
    execute "setlocal statusline=" . g:qf_statusline.before . "%{qf#statusline#SetStatusline()}" . g:qf_statusline.after
endif

" inspired by Ack.vim
if exists("g:qf_mapping_ack_style")
    " open entry in a new horizontal window
    nnoremap <silent> <buffer> s <C-w><CR>

    " open entry in a new vertical window.
    if (b:qf_isLoc == 1 && get(g:, 'qf_loclist_window_bottom', 1))
                \ || (b:qf_isLoc == 0 && get(g:, 'qf_window_bottom', 1))
        nnoremap <silent> <expr> <buffer> v &splitright ? "\<C-w>\<CR>\<C-w>L\<C-w>p\<C-w>J\<C-w>p" : "\<C-w>\<CR>\<C-w>H\<C-w>p\<C-w>J\<C-w>p"
    else
        " don't move quickfix to bottom if qf_loclist_window_bottom is 0
        nnoremap <silent> <expr> <buffer> v &splitright ? "\<C-w>\<CR>\<C-w>L" : "\<C-w>\<CR>\<C-w>H"
    endif

    " open entry in a new tab.
    nnoremap <silent> <buffer> t <C-w><CR><C-w>T

    " open entry and come back
    nnoremap <silent> <buffer> o <CR><C-w>p

    " open entry and close the location/quickfix window.
    if b:qf_isLoc == 1
        nnoremap <silent> <buffer> O <CR>:lclose<CR>
    else
        nnoremap <silent> <buffer> O <CR>:cclose<CR>
    endif

    " preview entry under the cursor
    nnoremap <silent> <buffer> p :call qf#preview#PreviewFileUnderCursor()<CR>
endif

" filter the location/quickfix list
" (kept for backward compatibility, use :Keep and :Reject instead)
" usage:
"   :Filter foo     <-- same as :Keep foo
"   :Filter! foo    <-- same as :Reject foo
command! -buffer -range -nargs=1 -bang Filter call qf#filter#FilterList(<q-args>, expand("<bang>") == "!" ? 1 : 0)

" keep entries matching the argument
" usage:
"   :Keep foo
command! -buffer -range -nargs=? Keep call qf#filter#FilterList(<q-args>, 0)

" reject entries matching the argument
" usage:
"   :Reject foo
command! -buffer -range -nargs=? Reject call qf#filter#FilterList(<q-args>, 1)

" restore the location/quickfix list
" usage:
"   :Restore
command! -buffer -bar Restore call qf#filter#RestoreList()

" do something on each line in the location/quickfix list
" usage:
"   :Doline s/^/---
command! -buffer -nargs=1 Doline call qf#do#DoList(1, <q-args>)

" do something on each file in the location/quickfix list
" usage:
"   :Dofile %s/^/---
command! -buffer -nargs=1 Dofile call qf#do#DoList(0, <q-args>)

" save current location/quickfix list and associate it with a given name or the
" last used name
command! -buffer -nargs=? -complete=customlist,qf#namedlist#CompleteList SaveList    call qf#namedlist#SaveList(0, <q-args>)
" like SaveList, but add to a potentially existing named list
command! -buffer -nargs=? -complete=customlist,qf#namedlist#CompleteList SaveListAdd call qf#namedlist#SaveList(1, <q-args>)

" replace location/quickfix list with named lists
command! -buffer -nargs=+ -complete=customlist,qf#namedlist#CompleteList LoadList    call qf#namedlist#LoadList(0, <q-args>)
" like LoadList but append instead of replace
command! -buffer -nargs=+ -complete=customlist,qf#namedlist#CompleteList LoadListAdd call qf#namedlist#LoadList(1, <q-args>)

" list currently saved lists
command! -buffer ListLists call qf#namedlist#ListLists()
" remove given lists or all
command! -buffer -nargs=* -bang -complete=customlist,qf#namedlist#CompleteList RemoveList call qf#namedlist#RemoveList(expand("<bang>") == "!" ? 1 : 0, <q-args>)

" TODO: allow customization
" jump to previous/next file grouping
nnoremap <silent> <buffer> } :call qf#filegroup#NextFile()<CR>
nnoremap <silent> <buffer> { :call qf#filegroup#PreviousFile()<CR>

" quit Vim if the last window is a quickfix window
autocmd qf BufEnter    <buffer> nested if get(g:, 'qf_auto_quit', 1) | if winnr('$') < 2 | q | endif | endif
autocmd qf BufWinEnter <buffer> nested if get(g:, 'qf_auto_quit', 1) | call qf#filter#ReuseTitle() | endif

" decide where to open the location/quickfix window
if (b:qf_isLoc == 1 && get(g:, 'qf_loclist_window_bottom', 1))
            \ || (b:qf_isLoc == 0 && get(g:, 'qf_window_bottom', 1))
    wincmd J
endif

let &cpo = s:save_cpo
