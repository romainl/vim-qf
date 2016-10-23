" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.1.1
" License:	MIT
" Location:	autoload/do.vim
" Website:	https://github.com/romainl/vim-qf
"
" See :help qf for help.
"
" If this doesn't work and you installed vim-qf manually, use the following
" command to index vim-qf's documentation:
"
" :helptags ~/.vim/doc
"
" If you use a runtimepath/plugin manager, read its documentation.

let s:save_cpo = &cpo
set cpo&vim

" do something with each entry
" a single function for :Doline and :Dofile both in a quickfix list and
" a location list
" falls back to :cdo, :cfdo, :ldo, :lfdo when possible
function qf#do#DoList(line, cmd)
    if exists("b:isLoc")
        let prefix = b:isLoc == 1 ? "l" : "c"
    else
        let prefix = "c"
    endif

    if v:version >= 705 || v:version == 704 && has("patch858")
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

finish

" template
function qf#do#FunctionName(argument)
    if exists("b:isLoc")
        if b:isLoc == 1
            " do something if we are in a location list
        else
            " do something else if we are in a quickfix list
        endif
    endif
endfunction
