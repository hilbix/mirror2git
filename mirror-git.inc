#

autogit()
{
x git checkout -q "`git rev-parse HEAD`" || return
x git remote update --prune || err
x git for-each-ref --shell --format='[ -z %(upstream:short) ] || git update-ref %(refname) %(upstream:short);' refs/heads | bash
x git push --mirror origin
}
