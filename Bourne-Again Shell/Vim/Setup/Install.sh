#!/bin/bash


unzip nerdtree.zip
mkdir -p ~/.vim/{plugin,doc}

cp plugin/NERD_tree.vim ~/.vim/plugin/
cp doc/NERD_tree.txt ~/.vim/doc/


cat >> /dev/stdout <<eof
> " 设置NerdTree
> map <F3> :NERDTreeMirror<CR>
> map <F3> :NERDTreeToggle<CR>
按F3即可显示或隐藏NerdTree区域了
> eof
