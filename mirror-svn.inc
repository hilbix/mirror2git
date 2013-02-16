#

autosvn()
{
x git add .
x git stash
x git checkout master
x git svn fetch --all
x git svn rebase
x git remote update --prune
x git for-each-ref --shell --format='[ -z %(upstream:short) ] || git update-ref %(refname) %(upstream:short);' refs/heads | bash
x git push --mirror origin
}
