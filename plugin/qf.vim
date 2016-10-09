" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.0.9
" License:	MIT
" Location:	plugin/qf.vim
" Website:	https://github.com/romainl/vim-qf
"
" See :help qf for help.
"
" If this doesn't work and you installed vim-qf manually, use the following
" command to index vim-qf's documentation:
"
" :helptags ~/.vim/doc
"
" If this doesn't work and you use a runtimepath/plugin manager, consult its
" documentation.

if exists("g:loaded_qf") || v:version < 703 || &compatible
    finish
endif
let g:loaded_qf = 1

let s:save_cpo = &cpo
set cpo&vim

" <Plug>QfCprevious and <Plug>QfCnext go up and down the quickfix list and wrap around
nnoremap <silent> <Plug>QfCprevious :call qf#wrap#WrapCommand('up', 'c')<CR>
nnoremap <silent> <Plug>QfCnext     :call qf#wrap#WrapCommand('down', 'c')<CR>

" <Plug>QfLprevious and <Plug>QfLnext go up and down the location list and wrap around
nnoremap <silent> <Plug>QfLprevious :call qf#wrap#WrapCommand('down', 'l')<CR>
nnoremap <silent> <Plug>QfLnext     :call qf#wrap#WrapCommand('up', 'l')<CR>

" <Plug>QfCtoggle toggles the quickfix window
" <Plug>QfLtoggle toggles the location window
nnoremap <silent> <Plug>QfCtoggle   :call qf#toggle#ToggleQfWindow()<CR>
nnoremap <silent> <Plug>QfLtoggle   :call qf#toggle#ToggleLocWindow()<CR>

" jump to and from the location/quickfix window
nnoremap <expr> <silent> <Plug>QfSwitch &filetype == "qf" ? "<C-w>p" : "<C-w>b"

augroup qf
    autocmd!

    " automatically open the location/quickfix window after :make, :grep,
    " :lvimgrep and friends if there are valid locations/errors
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l*    lwindow
    autocmd VimEnter        *     cwindow

    " automatically close corresponding loclist when quitting a window
    autocmd QuitPre * if &filetype != 'qf' | silent! lclose | endif
augroup END

let &cpo = s:save_cpo
