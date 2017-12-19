set encoding=utf-8          " 编码
set cursorline              " 突出显示当前行
set tabstop=4               " 制表符4个空格
set incsearch               " 输入搜索内容时就显示搜索结果

" 按 "F5" 自动运行并分屏输出，本段在写入 ~/.vimrc 前要先创建文件： mkdir ~/.vim
function! Setup_ExecNDisplay()
    execute "w"
    execute "silent !chmod +x %:p"
    let n=expand('%:t')
    execute "silent !%:p 2>&1 | tee ~/.vim/output_".n
    " I prefer vsplit"
    execute "split ~/.vim/output_".n
    execute "vsplit ~/.vim/output_".n
    execute "redraw!"
    set autoread                                                                                                         
endfunction

:nmap <F5> :call Setup_ExecNDisplay()
