#### Dynamic Choice Parameter
```txt
#通过Groovy脚本来抓取git仓库的所有branch,并作为一个多选项，方便在最终Build前去选择需要的这个产品Branch分支

def gettags = ("git ls-remote -h git@git.showerlee.com:showerlee/phpcms.git").execute()  
gettags.text.readLines().collect { it.split()[1].replaceAll('refs/heads/', '')  }.unique() 
```
