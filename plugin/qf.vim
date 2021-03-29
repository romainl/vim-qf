" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	plugin/qf.vim
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

if exists("g:loaded_qf") || v:version < 703 || &compatible
    finish
endif
let g:loaded_qf = 1

let s:save_cpo = &cpo
set cpo&vim

" Kept for backward compatibility
nmap <silent>        <Plug>QfCprevious <Plug>(qf_qf_previous)
nmap <silent>        <Plug>QfCnext     <Plug>(qf_qf_next)
nmap <silent>        <Plug>QfLprevious <Plug>(qf_loc_previous)
nmap <silent>        <Plug>QfLnext     <Plug>(qf_loc_next)
nmap <silent>        <Plug>QfCtoggle   <Plug>(qf_qf_toggle)
nmap <silent>        <Plug>QfLtoggle   <Plug>(qf_loc_toggle)
nmap <silent> <expr> <Plug>QfSwitch    &filetype ==# 'qf' ? '<C-w>p' : '<C-w>b'

" Go up and down quickfix list
nnoremap <silent>        <Plug>(qf_qf_previous)     :<C-u> call qf#wrap#WrapCommand('up', 'c')<CR>
nnoremap <silent>        <Plug>(qf_qf_next)         :<C-u> call qf#wrap#WrapCommand('down', 'c')<CR>

" Go up and down location list
nnoremap <silent>        <Plug>(qf_loc_previous)    :<C-u> call qf#wrap#WrapCommand('up', 'l')<CR>
nnoremap <silent>        <Plug>(qf_loc_next)        :<C-u> call qf#wrap#WrapCommand('down', 'l')<CR>

" Toggle quickfix list
nnoremap <silent>        <Plug>(qf_qf_toggle)       :<C-u> call qf#toggle#ToggleQfWindow(0)<CR>
nnoremap <silent>        <Plug>(qf_qf_toggle_stay)  :<C-u> call qf#toggle#ToggleQfWindow(1)<CR>

" Toggle location list
nnoremap <silent>        <Plug>(qf_loc_toggle)      :<C-u> call qf#toggle#ToggleLocWindow(0)<CR>
nnoremap <silent>        <Plug>(qf_loc_toggle_stay) :<C-u> call qf#toggle#ToggleLocWindow(1)<CR>

" Jump to and from list
nnoremap <silent> <expr> <Plug>(qf_qf_switch)       &filetype ==# 'qf' ? '<C-w>p' : '<C-w>b'

" A list of commands used to trigger the QuickFixCmdPost event is documented in
" `:help QuickFixCmdPre`.
" NOTE: helgrep is excluded because it's a special case (see below).
let s:quickfix_autocmd_trigger_cmds = [
            \ 'make', 'grep', 'grepadd', 'vimgrep', 'vimgrepadd', 'cfile', 'cgetfile', 
            \ 'caddfile', 'cexpr', 'cgetexpr', 'caddexpr', 'cbuffer', 
            \ 'cgetbuffer', 'caddbuffer']

function! s:GetQuickFixCmdsPattern() abort
    return join(s:quickfix_autocmd_trigger_cmds, ',')
endfunction

function! s:GetLocListCmdsPattern() abort
    let l:loclist_cmds = []

    for l:qf_cmd in s:quickfix_autocmd_trigger_cmds
        " If a commands starts with 'c', replace it with 'l'. Otherwise, prepend
        " 'l'. 
        if l:qf_cmd[0] is# 'c'
            let l:cmd = 'l' . l:qf_cmd[1:]
        else
            let l:cmd = 'l' . l:qf_cmd
        endif
        call add(l:loclist_cmds, l:cmd)
    endfor

    return join(l:loclist_cmds, ',')
endfunction

augroup qf
    autocmd!

    " automatically open the location/quickfix window after :make, :grep,
    " :lvimgrep and friends if there are valid locations/errors
    exec printf('autocmd QuickFixCmdPost %s nested call qf#OpenQuickfix()', s:GetQuickFixCmdsPattern())
    exec printf('autocmd QuickFixCmdPost %s nested call qf#OpenLoclist()', s:GetLocListCmdsPattern())

    " special case for :helpgrep and :lhelpgrep since the help window may not
    " be opened yet when QuickFixCmdPost triggers
    if exists('*timer_start')
        autocmd QuickFixCmdPost  helpgrep nested call timer_start(10, { -> execute('call qf#OpenQuickfix()') })
        autocmd QuickFixCmdPost lhelpgrep nested call timer_start(10, { -> execute('call qf#OpenLoclist()') })
    else
        " the window qf is not positioned correctly but at least it's there
        autocmd QuickFixCmdPost helpgrep nested call qf#OpenQuickfix()
        " I can't make it work for :lhelpgrep
    endif

    " spacial case for $ vim -q
    autocmd VimEnter * nested if count(get(v:, 'argv', []), '-q') | call qf#OpenQuickfix() | endif

    " automatically close corresponding loclist when quitting a window
    if exists('##QuitPre')
        autocmd QuitPre * nested if &filetype != 'qf' | silent! lclose | endif
    endif
augroup END

let &cpo = s:save_cpo
