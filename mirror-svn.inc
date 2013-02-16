#

autosvn()
{
x git add .
x git stash
x git checkout master
x git svn fetch --all
x git svn rebase
x git push --mirror origin
}

