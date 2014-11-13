set t_Co=256
syntax enable
set background=dark
colorscheme solarized

inoremap jj <ESC>
inoremap jk <ESC>

nnoremap ; :
nnoremap : ;

highlight BadWhitespace ctermbg=red guibg=red

" Display tabs at the beginning of a line in Python mode as bad.
au BufRead,BufNewFile *.py,*.pyw match BadWhitespace /^\t\+/
" Make trailing whitespace be flagged as bad.
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

au BufNewFile *.py,*.pyw,*.c,*.h set fileformat=unix

let python_highlight_all=1
syntax on

au BufRead,BufNewFile *.py,*.py match ErrorMsg '\%>80v.\+'

" This rewires n and N to do the highlighing...
nnoremap <silent> n nzz:call HLNext(0.2)<cr>
nnoremap <silent> N Nzz:call HLNext(0.2)<cr>

" Better tabs
set expandtab       " tabs are converted to spaces
set tabstop=4       " numbers of spaces of tab character
set shiftwidth=4    " numbers of spaces to (auto)indent

" Treat JSON files like javascript
au BufNewFile,BufRead *.json set ft=javascript

function! HLNext (blinktime)
	highlight WhiteOnRed ctermfg=white ctermbg=red
	let [bufnum, lnum, col, off] = getpos('.')
	let matchlen = strlen(matchstr(strpart(getline('.'),col-1),@/))
	let target_pat = '\c\%#'.@/
	let ring = matchadd('WhiteOnRed', target_pat, 101)
	redraw
	exec 'sleep ' . float2nr(a:blinktime * 1000) . 'm'
	call matchdelete(ring)
	redraw
endfunction
