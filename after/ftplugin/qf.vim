" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	after/ftplugin/qf.vim
" Website:	https://github.com/romainl/vim-qf

let s:save_cpo = &cpo
set cpo&vim

" Text wrapping is pretty much useless in the quickfix window
" but some users may still want it
execute get(g:, "qf_nowrap", 1) ? "setlocal nowrap" : "setlocal wrap"

" Relative line numbers don't make much sense either
" but absolute numbers definitely do
setlocal norelativenumber
setlocal number

" We don't want quickfix buffers to pop up when doing :bn or :bp
set nobuflisted

if exists("b:undo_ftplugin")
    let b:undo_ftplugin .= "| setl wrap< rnu< nu< bl<"
else
    let b:undo_ftplugin = "setl wrap< rnu< nu< bl<"
endif

" Are we in a location window or a quickfix window?
"   0 -> quickfix window
"   1 -> location window
let b:qf_isLoc = win_getid()
            \ ->getwininfo()
            \ ->get(0, {})
            \ ->get("loclist", 0)

" Customize the statusline
if exists("g:qf_statusline")
    execute "setlocal statusline=" . g:qf_statusline.before . "%{qf#statusline#SetStatusline()}" . g:qf_statusline.after
endif

" Mappings inspired by Ack.vim
if get(g:, "qf_mapping_ack_style", 0)
    let qf_at_bottom = (get(b:, "qf_isLoc", 0) && get(g:, "qf_loclist_window_bottom", 1))
                \ || (!get(b:, "qf_isLoc", 0) && get(g:, "qf_window_bottom", 1))

    " Open entry in a new vertical window
    if qf_at_bottom
        nnoremap <silent> <expr> <buffer> v &splitright ? "\<C-w>\<CR>\<C-w>L\<C-w>p\<C-w>J\<C-w>p" : "\<C-w>\<CR>\<C-w>H\<C-w>p\<C-w>J\<C-w>p"
    else
        " Don't move quickfix to bottom if qf_loclist_window_bottom is 0
        nnoremap <silent> <expr> <buffer> v &splitright ? "\<C-w>\<CR>\<C-w>L" : "\<C-w>\<CR>\<C-w>H"
    endif

    if qf_at_bottom && &splitbelow
        " Open entry in a new horizontal window and move quickfix to bottom
        nnoremap <silent> <buffer> s <C-w><CR><C-w>p<C-w>J<C-w>p

        " Preview entry under the cursor and move quickfix to bottom
        nnoremap <silent> <buffer> p :call qf#preview#PreviewFileUnderCursor()<CR><C-w>J
    else
        " Open entry in a new horizontal window
        nnoremap <silent> <buffer> s <C-w><CR>

        " Preview entry under the cursor
        nnoremap <silent> <buffer> p :call qf#preview#PreviewFileUnderCursor()<CR>
    endif

    " Open entry and close the location/quickfix window
    if get(b:, "qf_isLoc", 0)
        nnoremap <silent> <buffer> O <CR>:lclose<CR>
    else
        nnoremap <silent> <buffer> O <CR>:cclose<CR>
    endif

    " Open entry in a new tab
    nnoremap <silent> <buffer> t <C-w><CR><C-w>T

    " Open entry and come back
    nnoremap <silent> <buffer> o <CR><C-w>p

    let b:undo_ftplugin .= "| execute 'nunmap <buffer> s'"
                \ . "| execute 'nunmap <buffer> v'"
                \ . "| execute 'nunmap <buffer> t'"
                \ . "| execute 'nunmap <buffer> o'"
                \ . "| execute 'nunmap <buffer> O'"
                \ . "| execute 'nunmap <buffer> p'"
endif

" Keep entries matching the argument or range
" Usage:
"   :Keep foo
"   :10,15Keep
command! -buffer -range -nargs=? Keep call qf#filter#FilterList(<q-args>, 0, <line1>, <line2>, <count>)

" Reject entries matching the argument or range
" Usage:
"   :Reject foo
"   :10,15Reject
command! -buffer -range -nargs=? Reject call qf#filter#FilterList(<q-args>, 1, <line1>, <line2>, <count>)

" Restore the location/quickfix list
" Usage:
"   :Restore
command! -buffer -bar Restore call qf#filter#RestoreList()

" Save current location/quickfix list and associate it with a given name or the
" last used name
" Usage:
"   :SaveList foobar
"   :SaveList
command! -buffer -nargs=? -complete=customlist,qf#namedlist#CompleteList SaveList    call qf#namedlist#SaveList(0, <q-args>)
" Like SaveList, but add to a potentially existing named list
" Usage:
"   :SaveListAdd foobar
"   :SaveListAdd
command! -buffer -nargs=? -complete=customlist,qf#namedlist#CompleteList SaveListAdd call qf#namedlist#SaveList(1, <q-args>)

" Replace location/quickfix list with named lists
" Usage:
"   :LoadList foobar
command! -buffer -nargs=+ -complete=customlist,qf#namedlist#CompleteList LoadList    call qf#namedlist#LoadList(0, <q-args>)
" Like LoadList but append instead of replace
" Usage:
"   :LoadListAdd foobar
command! -buffer -nargs=+ -complete=customlist,qf#namedlist#CompleteList LoadListAdd call qf#namedlist#LoadList(1, <q-args>)

" List currently saved lists
" Usage:
"   :ListLists
command! -buffer ListLists call qf#namedlist#ListLists()
" Remove given lists or all
" Usage:
"   :RemoveList foobar
"   :RemoveList!
command! -buffer -nargs=* -bang -complete=customlist,qf#namedlist#CompleteList RemoveList call qf#namedlist#RemoveList(expand("<bang>") == "!" ? 1 : 0, <q-args>)

" Quit Vim if the last window is a quickfix window
autocmd qf BufEnter    <buffer> nested if get(g:, "qf_auto_quit", 1) | if winnr('$') < 2 | q | endif | endif
autocmd qf BufWinEnter <buffer> nested if get(g:, "qf_auto_quit", 1) | call qf#filter#ReuseTitle() | endif

" Move forward and backward in list history (in a location/quickfix window)
nnoremap <silent> <buffer> <Plug>(qf_older)         :<C-u>call qf#history#Older()<CR>
nnoremap <silent> <buffer> <Plug>(qf_newer)         :<C-u>call qf#history#Newer()<CR>

" Jump to previous and next file grouping (in a location/quickfix window)
nnoremap <silent> <buffer> <Plug>(qf_previous_file) :<C-u>call qf#filegroup#PreviousFile()<CR>
nnoremap <silent> <buffer> <Plug>(qf_next_file)     :<C-u>call qf#filegroup#NextFile()<CR>

" Decide where to open the location/quickfix window
if (get(b:, "qf_isLoc", 0) && get(g:, "qf_loclist_window_bottom", 1))
            \ || (!get(b:, "qf_isLoc", 0) && get(g:, "qf_window_bottom", 1))
    wincmd J
endif

let b:undo_ftplugin .= "| delcommand Keep"
            \ . "| delcommand Reject"
            \ . "| delcommand Restore"
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

let &cpo = s:save_cpo
