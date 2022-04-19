"colors torte
color elflord

" ignore strict vi compatibility
set nocompatible

" prevent sounds on mistakes
set noerrorbells

" shows current mode and other cursor stats
set modeline
set showmode
set ruler

" default text managing stuff
set expandtab
set autoindent
set tabstop=4

"backspace over everything 
set backspace=indent,eol,start

" textwidth stuff
setlocal textwidth=78
set nowrap

" show tabs
" tabs = >--
set list
set listchars=tab:>-
highlight SpecialKey guifg=#5f5f5f

" c tabs use two spaces
au BufRead,BufNewFile *.{c,h,java} set expandtab
au BufRead,BufNewFile *.{c,h,java} set shiftwidth=2
au BufRead,BufNewFile *.{c,h,java} set tabstop=2

" Do not expand tabs in assembly file.  Make them 8 chars wide.
au BufRead,BufNewFile *.s set noexpandtab
au BufRead,BufNewFile *.s set shiftwidth=8
au BufRead,BufNewFile *.s set tabstop=8

" show syntax highlights
syntax on

" Java specific stuff
let java_highlight_all=1
let java_highlight_debug=1

let java_ignore_javadoc=1
let java_highlight_functions=1
let java_mark_braces_in_parens_as_errors=1

" highlight strings inside C comments
let c_comment_strings=1

" Python use tabs
au BufRead,BufNewFile *.{py} set noexpandtab

" Auto-add asterisks in multiline comments
filetype plugin indent on
set formatoptions+=r


