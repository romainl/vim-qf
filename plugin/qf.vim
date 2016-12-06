" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.1.0
" License:	MIT
" Location:	plugin/qf.vim
" Website:	https://github.com/romainl/vim-qf
"
" See qf.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help qf

if exists("g:loaded_qf") || v:version < 703 || &compatible
    finish
endif
let g:loaded_qf = 1

let s:save_cpo = &cpo
set cpo&vim

" Backwards Compatibility
nnoremap <silent> <Plug>QfCprevious      :<C-u> call qf#WrapCommand('up', 'c')<CR>
nnoremap <silent> <Plug>QfCnext          :<C-u> call qf#WrapCommand('down', 'c')<CR>
nnoremap <silent> <Plug>QfLprevious      :<C-u> call qf#WrapCommand('up', 'l')<CR>
nnoremap <silent> <Plug>QfLnext          :<C-u> call qf#WrapCommand('down', 'l')<CR>
nnoremap <silent> <Plug>QfCtoggle        :<C-u> call qf#ToggleQfWindow(0)<CR>
nnoremap <silent> <Plug>QfLtoggle        :<C-u> call qf#ToggleLocWindow(0)<CR>

" Go up and down quickfix list
nnoremap <silent> <Plug>(qf_qf_previous) :<C-u> call qf#WrapCommand('up', 'c')<CR>
nnoremap <silent> <Plug>(qf_qf_next)     :<C-u> call qf#WrapCommand('down', 'c')<CR>

" Go up and down location list
nnoremap <silent> <Plug>(qf_loc_previous) :<C-u> call qf#WrapCommand('up', 'l')<CR>
nnoremap <silent> <Plug>(qf_loc_next)     :<C-u> call qf#WrapCommand('down', 'l')<CR>

" Toggle quickfix list
nnoremap <silent> <Plug>(qf_qf_toggle)       :<C-u> call qf#ToggleQfWindow(0)<CR>
nnoremap <silent> <Plug>(qf_qf_toggle_stay)  :<C-u> call qf#ToggleQfWindow(1)<CR>

" Toggle location list
nnoremap <silent> <Plug>(qf_loc_toggle)      :<C-u> call qf#ToggleLocWindow(0)<CR>
nnoremap <silent> <Plug>(qf_loc_toggle_stay) :<C-u> call qf#ToggleLocWindow(1)<CR>

" Jump to and from list
nnoremap <expr><silent> <Plug>QfSwitch       &filetype == "qf" ? "<C-w>p" : "<C-w>b"
nnoremap <expr><silent> <Plug>(qf_qf_switch) &filetype == "qf" ? "<C-w>p" : "<C-w>b"

augroup qf
    autocmd!

    " automatically open the location/quickfix window after :make, :grep,
    " :lvimgrep and friends if there are valid locations/errors
    autocmd QuickFixCmdPost [^l]* call qf#OpenQuickfix()
    autocmd QuickFixCmdPost l*    call qf#OpenLoclist()
    autocmd VimEnter        *     call qf#OpenQuickfix()

    " automatically close corresponding loclist when quitting a window
    autocmd QuitPre * if &filetype != 'qf' | silent! lclose | endif
augroup END

let &cpo = s:save_cpo
