" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/statusline.vim
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

" used to inject the current title into the current status line
" TODO (Nelo-T. Wallus): This is pretty heavy spaghetti code. I'll take
" a close look at it and try to break it up into smaller portions
function! qf#statusline#SetStatusline()
    if exists("b:qf_isLoc")
        if b:qf_isLoc == 1
            let titles = getwinvar(winnr("#"), "qf_location_titles", [])
        else
            let titles = get(g:, 'qf_quickfix_titles', [])
        endif

        if len(titles) > 0
            return titles[-1]
        endif

        return get(w:, 'quickfix_title', '')
    endif
endfunction

let &cpo = s:save_cpo
