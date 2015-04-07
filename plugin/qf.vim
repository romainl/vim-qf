" qf.vim - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.0.1
" License:	Vim License (see :help license)
" Location:	plugin/qf.vim
" Website:	https://github.com/romainl/vim-qf

if exists("g:loaded_qf") || v:version < 703 || &compatible
  finish
endif
let g:loaded_qf = 1

let s:save_cpo = &cpo
set cpo&vim

" <Home> and <End> go up and down the quickfix list and wrap around
if exists("g:qf_mapping_cprevious")
    execute "nnoremap <silent> " . g:qf_mapping_cprevious . " :call qf#WrapCommand('up', 'c')<CR>"
else
    nnoremap <silent> <Home> :call qf#WrapCommand('up', 'c')<CR>
endif

if exists("g:qf_mapping_cnext")
    execute "nnoremap <silent> " . g:qf_mapping_cnext . " :call qf#WrapCommand('down', 'c')<CR>"
else
    nnoremap <silent> <End> :call qf#WrapCommand('down', 'c')<CR>
endif

" <C-Home> and <C-End> go up and down the location list and wrap around
if exists("g:qf_mapping_lnext")
    execute "nnoremap <silent> " . g:qf_mapping_lnext . " :call qf#WrapCommand('down', 'l')<CR>"
else
    nnoremap <silent> <C-End>  :call qf#WrapCommand('down', 'l')<CR>
endif

if exists("g:qf_mapping_lprevious")
    execute "nnoremap <silent> " . g:qf_mapping_lprevious . " :call qf#WrapCommand('up', 'l')<CR>"
else
    nnoremap <silent> <C-Home> :call qf#WrapCommand('up', 'l')<CR>
endif

" jump to and from the quickfix window
if exists("g:qf_mapping_switch")
    execute 'nnoremap <expr> ' . g:qf_mapping_switch . ' &filetype == "qf" ? "<C-w>p" : "<C-w>b"'
else
    nnoremap <expr> ç &filetype == "qf" ? "<C-w>p" : "<C-w>b"
endif

" automatically open the quickfix/location window after :make, :grep,
" :lvimgrep and friends if there are valid errors/locations
augroup qf
    autocmd!
    autocmd QuickFixCmdPost grep,make,grepadd,vimgrep,vimgrepadd,cscope,cfile,cgetfile,caddfile,helpgrep cwindow
    autocmd QuickFixCmdPost lgrep,lmake,lgrepadd,lvimgrep,lvimgrepadd,lfile,lgetfile,laddfile lwindow
augroup END

let &cpo = s:save_cpo
