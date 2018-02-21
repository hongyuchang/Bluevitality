#!/bin/bash


unzip nerdtree.zip
mkdir -p ~/.vim/{plugin,doc}

cp plugin/NERD_tree.vim ~/.vim/plugin/
cp doc/NERD_tree.txt ~/.vim/doc/

#设置NerdTree快捷键
echo 'map <F3> :NERDTreeMirror<CR>' >> ~/.vimrc
echo 'map <F3> :NERDTreeToggle<CR>' >> ~/.vimrc

cat >> /dev/stdout <<eof
按F3即可显示或隐藏NerdTree区域
在VIM中进入当前目录的树形界面，通过小键盘上下键，能移动选中的目录或文件
ctr+w+h   光标focus左侧树形目录
ctrl+w+l  光标focus右侧文件显示窗口
ctrl+w    光标自动在左右侧窗口切换(多次摁c+w)
o   打开关闭文件或者目录
t   在标签页中打开
T   在后台标签页中打开
!   执行此文件
p   到上层目录
P   到根目录
K   到第一个节点
J   到最后一个节点
u   打开上层目录
m   显示文件系统菜单（添加、删除、移动操作）
?   帮助
q   关闭
eof
