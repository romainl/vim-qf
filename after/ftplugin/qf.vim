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

" text wrapping is pretty much useless in the quickfix window
" but some users may still want it
execute get(g:, "qf_nowrap", 1) ? "setlocal nowrap" : "setlocal wrap"

" relative line numbers don't make much sense either
" but absolute numbers definitely do
setlocal norelativenumber
setlocal number

" we don't want quickfix buffers to pop up when doing :bn or :bp
set nobuflisted

if exists("b:undo_ftplugin")
    let b:undo_ftplugin .= "| setl wrap< rnu< nu< bl<"
else
    let b:undo_ftplugin = "setl wrap< rnu< nu< bl<"
endif

" are we in a location list or a quickfix list?
let b:qf_isLoc = get(get(getwininfo(win_getid()), 0, {}), 'loclist', 0)

" customize the statusline
if exists("g:qf_statusline")
    execute "setlocal statusline=" . g:qf_statusline.before . "%{qf#statusline#SetStatusline()}" . g:qf_statusline.after
endif

" inspired by Ack.vim
if exists("g:qf_mapping_ack_style")
    let qf_at_bottom = (b:qf_isLoc == 1 && get(g:, 'qf_loclist_window_bottom', 1))
                \ || (b:qf_isLoc == 0 && get(g:, 'qf_window_bottom', 1))

    " open entry in a new vertical window.
    if qf_at_bottom
        nnoremap <silent> <expr> <buffer> v &splitright ? "\<C-w>\<CR>\<C-w>L\<C-w>p\<C-w>J\<C-w>p" : "\<C-w>\<CR>\<C-w>H\<C-w>p\<C-w>J\<C-w>p"
    else
        " don't move quickfix to bottom if qf_loclist_window_bottom is 0
        nnoremap <silent> <expr> <buffer> v &splitright ? "\<C-w>\<CR>\<C-w>L" : "\<C-w>\<CR>\<C-w>H"
    endif

    if qf_at_bottom && &splitbelow
        " open entry in a new horizontal window and move quickfix to bottom
        nnoremap <silent> <buffer> s <C-w><CR><C-w>p<C-w>J<C-w>p

        " preview entry under the cursor and move quickfix to bottom
        nnoremap <silent> <buffer> p :call qf#preview#PreviewFileUnderCursor()<CR><C-w>J
    else
        " open entry in a new horizontal window
        nnoremap <silent> <buffer> s <C-w><CR>

        " preview entry under the cursor
        nnoremap <silent> <buffer> p :call qf#preview#PreviewFileUnderCursor()<CR>
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

    let b:undo_ftplugin .= "| execute 'nunmap <buffer> s'"
                \ . "| execute 'nunmap <buffer> v'"
                \ . "| execute 'nunmap <buffer> t'"
                \ . "| execute 'nunmap <buffer> o'"
                \ . "| execute 'nunmap <buffer> O'"
                \ . "| execute 'nunmap <buffer> p'"
endif

" filter the location/quickfix list
" (kept for backward compatibility, use :Keep and :Reject instead)
" usage:
"   :Filter foo     <-- same as :Keep foo
"   :Filter! foo    <-- same as :Reject foo
"   :10,15Filter    <-- same as :10,15Keep
"   :10,15Filter!   <-- same as :10,15Reject
command! -buffer -range -nargs=1 -bang Filter call qf#filter#FilterList(<q-args>, expand("<bang>") == "!" ? 1 : 0, <line1>, <line2>, <count>)

" keep entries matching the argument or range
" usage:
"   :Keep foo
"   :10,15Keep
command! -buffer -range -nargs=? Keep call qf#filter#FilterList(<q-args>, 0, <line1>, <line2>, <count>)

" reject entries matching the argument or range
" usage:
"   :Reject foo
"   :10,15Reject
command! -buffer -range -nargs=? Reject call qf#filter#FilterList(<q-args>, 1, <line1>, <line2>, <count>)

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

" quit Vim if the last window is a quickfix window
autocmd qf BufEnter    <buffer> nested if get(g:, 'qf_auto_quit', 1) | if winnr('$') < 2 | q | endif | endif
autocmd qf BufWinEnter <buffer> nested if get(g:, 'qf_auto_quit', 1) | call qf#filter#ReuseTitle() | endif

" Move forward and backward in list history (in a quickfix or location window)
nnoremap <silent> <buffer> <Plug>(qf_older)         :<C-u>call qf#history#Older()<CR>
nnoremap <silent> <buffer> <Plug>(qf_newer)         :<C-u>call qf#history#Newer()<CR>

" Jump to previous and next file grouping (in a quickfix or location window)
nnoremap <silent> <buffer> <Plug>(qf_previous_file) :<C-u>call qf#filegroup#PreviousFile()<CR>
nnoremap <silent> <buffer> <Plug>(qf_next_file)     :<C-u>call qf#filegroup#NextFile()<CR>

let b:undo_ftplugin .= "| delcommand Filter"
            \ . "| delcommand Keep"
            \ . "| delcommand Reject"
            \ . "| delcommand Restore"
            \ . "| delcommand Doline"
            \ . "| delcommand Dofile"
            \ . "| delcommand SaveList"
            \ . "| delcommand SaveListAdd"
            \ . "| delcommand LoadList"
            \ . "| delcommand LoadListAdd"
            \ . "| delcommand ListLists"
            \ . "| delcommand RemoveList"
            \ . "| execute 'nunmap <buffer> <Plug>(qf_older)'"
            \ . "| execute 'nunmap <buffer> <Plug>(qf_newer)'"
            \ . "| execute 'nunmap <buffer> <Plug>(qf_previous_file)'"
            \ . "| execute 'nunmap <buffer> <Plug>(qf_next_file)'"
            \ . "| unlet! b:qf_isLoc"

" decide where to open the location/quickfix window
if (b:qf_isLoc == 1 && get(g:, 'qf_loclist_window_bottom', 1))
            \ || (b:qf_isLoc == 0 && get(g:, 'qf_window_bottom', 1))
    wincmd J
endif

let &cpo = s:save_cpo
