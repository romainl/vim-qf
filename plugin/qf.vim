" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	plugin/qf.vim
" Website:	https://github.com/romainl/vim-qf

if exists("g:loaded_qf") || v:version < 802 || &compatible
    finish
endif
let g:loaded_qf = 1

let s:save_cpo = &cpo
set cpo&vim

" Go up and down the quickfix list
nnoremap <silent>        <Plug>(qf_qf_previous)     :<C-u> call qf#wrap#WrapCommand('up', 'c')<CR>
nnoremap <silent>        <Plug>(qf_qf_next)         :<C-u> call qf#wrap#WrapCommand('down', 'c')<CR>

" Go up and down the location list
nnoremap <silent>        <Plug>(qf_loc_previous)    :<C-u> call qf#wrap#WrapCommand('up', 'l')<CR>
nnoremap <silent>        <Plug>(qf_loc_next)        :<C-u> call qf#wrap#WrapCommand('down', 'l')<CR>

" Toggle the quickfix window
nnoremap <silent>        <Plug>(qf_qf_toggle)       :<C-u> call qf#toggle#ToggleQfWindow(0)<CR>
nnoremap <silent>        <Plug>(qf_qf_toggle_stay)  :<C-u> call qf#toggle#ToggleQfWindow(1)<CR>

" Toggle the location window
nnoremap <silent>        <Plug>(qf_loc_toggle)      :<C-u> call qf#toggle#ToggleLocWindow(0)<CR>
nnoremap <silent>        <Plug>(qf_loc_toggle_stay) :<C-u> call qf#toggle#ToggleLocWindow(1)<CR>

" Jump to and from a location/quickfix window
nnoremap <silent> <expr> <Plug>(qf_qf_switch)       &filetype ==# 'qf' ? '<C-w>p' : '<C-w>b'

" A list of commands used to trigger the QuickFixCmdPost event is documented in
" `:help QuickFixCmdPre`.
" NOTE: helgrep is excluded because it's a special case (see below).
let s:qf_autocmd_triggers = [
            \ "cbuffer", "cgetbuffer", "caddbuffer",
            \ "cexpr", "cgetexpr", "caddexpr",
            \ "cfile", "cgetfile", "caddfile",
            \ "grep", "grepadd",
            \ "make",
            \ "vimgrep", "vimgrepadd",
            \ ]->join(",")

let s:loc_autocmd_triggers = [
            \ "lbuffer", "lgetbuffer", "laddbuffer",
            \ "lexpr", "lgetexpr", "laddexpr",
            \ "lfile", "lgetfile", "laddfile",
            \ "lgrep", "grepadd",
            \ "lmake",
            \ "lvimgrep", "lvimgrepadd",
            \ ]->join(",")

augroup qf
    autocmd!

    " Automatically open the location/quickfix window after :make, :grep,
    " :lvimgrep and friends if there are valid locations/errors
    execute "autocmd QuickFixCmdPost " .. s:qf_autocmd_triggers .. " nested call qf#OpenQuickfixWindow()"
    execute "autocmd QuickFixCmdPost " .. s:loc_autocmd_triggers .. " nested call qf#OpenLocationWindow()"

    " Special case for :helpgrep and :lhelpgrep since the help window may not
    " be opened yet when QuickFixCmdPost triggers
    if exists('*timer_start')
        autocmd QuickFixCmdPost  helpgrep nested call timer_start(10, { -> execute('call qf#OpenQuickfixWindow()') })
        autocmd QuickFixCmdPost lhelpgrep nested call timer_start(10, { -> execute('call qf#OpenLocationWindow()') })
    else
        " The window qf is not positioned correctly but at least it's there
        autocmd QuickFixCmdPost helpgrep nested call qf#OpenQuickfixWindow()
        " I can't make it work for :lhelpgrep
    endif

    " Special case for $ vim -q
    autocmd VimEnter * nested if get(v:, 'argv', [])->count('-q') | call qf#OpenQuickfixWindow() | endif

    " Automatically close corresponding loclist when quitting a window
    if exists('##QuitPre')
        autocmd QuitPre * nested if &filetype != 'qf' | silent! lclose | endif
    endif
augroup END

" Handle formatting if possible
if exists('+quickfixtextfunc') && get(g:, "qf_shorten_path", 1)
    set quickfixtextfunc=qf#QuickfixTextFunc
endif

let &cpo = s:save_cpo
