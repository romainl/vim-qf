" vim-qf - Tame the quickfix window
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.2.0
" License:	MIT
" Location:	autoload/qf/format.vim
" Website:	https://github.com/romainl/vim-qf

let s:save_cpo = &cpo
set cpo&vim

function! qf#format#FormatItem(item)
    return [
                \ a:item-><SID>FormatFilename(),
                \ a:item-><SID>FormatLocation(),
                \ a:item-><SID>FormatText(),
                \ ]->join('|')
endfunction

function! s:FormatFilename(item)
    let filename = a:item["bufnr"]->bufname()

    if has('patch-8.2.1741')
        return pathshorten(filename, g:->get("qf_shorten_path", 1))
    else
        return pathshorten(filename)
    endif
endfunction

function! s:FormatLocation(item)
    return [
                \ a:item->get("lnum", 0)-><SID>FormatLineNumber(),
                \ a:item->get("col", 0)-><SID>FormatColumn(),
                \ a:item->get("type", '')-><SID>FormatType(),
                \ a:item->get("nr", 0)-><SID>FormatErrorNumber(),
                \ ]->join('')
endfunction

function! s:FormatText(item)
    return ' ' .. a:item->get("text", '')
endfunction

function! s:FormatLineNumber(lnum)
    return a:lnum != 0 ? a:lnum : '-'
endfunction

function! s:FormatColumn(col)
    return a:col > 0 ? ' col ' .. a:col : ''
endfunction

function! s:FormatType(type)
    return {
                \ 'e': ' error',
                \ 'i': ' info',
                \ 'n': ' note',
                \ 'w': ' warning'
                \ }->get(a:type, '')
endfunction

function! s:FormatErrorNumber(nr)
    if a:nr > 0
        return printf("%4d", a:nr)
    else
        return ''
    endif
endfunction

let &cpo = s:save_cpo
