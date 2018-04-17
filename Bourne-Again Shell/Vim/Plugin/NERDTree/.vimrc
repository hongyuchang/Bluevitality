map <F3> :NERDTreeMirror<CR> 
map <F3> :NERDTreeToggle<CR>

" NERDTree Setup
let g:NERDTreeShowLineNumbers=0
let g:NERDTreeAutoCenter=1
let g:NERDTreeWinSize=28    "窗口大小
let g:neocomplcache_enable_at_startup=1
let g:NERDTreeShowHidden=1
let g:NERDTreeIgnore=['\.pyc','\~$','\.swp']    "设置忽略文件类型
let g:NERDTreeShowBookmarks=1   "显示书签

" 当打开的文件仅有NERDTree自身时自动离开VIM环境
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" 语法高亮
syntax enable
syntax on

" 语言
set encoding=utf-8
set fileencodings=utf-8,chinese,latin-1
language messages zh_CN.utf-8




