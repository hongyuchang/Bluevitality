map <F3> :NERDTreeMirror<CR>
map <F3> :NERDTreeToggle<CR>

syntax enable
syntax on

set encoding=utf-8
set fileencodings=utf-8,chinese,latin-1
language messages zh_CN.utf-8

autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

let g:NERDTreeShowLineNumbers=0
let g:NERDTreeAutoCenter=1
let g:NERDTreeWinSize=28
let g:neocomplcache_enable_at_startup=1
let g:NERDTreeShowHidden=1
let g:NERDTreeIgnore=['\.pyc','\~$','\.swp']
let g:NERDTreeShowBookmarks=1
