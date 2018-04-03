#### Dynamic Choice Parameter
```txt
#通过Groovy脚本来抓取Git仓库的所有Branch并作为一个多选项，方便在最终Build前去选择需要的产品Branch

def gettags = ("git ls-remote -h git@git.showerlee.com:showerlee/phpcms.git").execute()  
gettags.text.readLines().collect { it.split()[1].replaceAll('refs/heads/', '')  }.unique() 
```
