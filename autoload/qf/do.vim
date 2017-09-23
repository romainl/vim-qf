" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/do.vim
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

" do something with each entry
" a single function for :Doline and :Dofile both in a quickfix list and
" a location list
" falls back to :cdo, :cfdo, :ldo, :lfdo when possible
function! qf#do#DoList(line, cmd)
    if exists("b:qf_isLoc")
        let prefix = b:qf_isLoc == 1 ? "l" : "c"
    else
        let prefix = "c"
    endif

    if v:version >= 705
                \ || v:version == 704 && has("patch858")
        if a:line == 1
            let modifier = ""
        else
            let modifier = "f"
        endif

        try
            execute prefix . modifier . "do " . a:cmd
        catch /^Vim\%((\a\+)\)\=:E\%(553\|42\):/
        endtry
    else
        try
            silent execute prefix . "first"
            while 1
                execute a:cmd

                silent execute a:line == 1 ? prefix . "next" : prefix . "nfile"
            endwhile
        catch /^Vim\%((\a\+)\)\=:E\%(553\|42\):/
        endtry
    endif
endfunction

let &cpo = s:save_cpo
