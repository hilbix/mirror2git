Automate mirroring to GIT
=========================

Scripts to keep always up-to-date copies of other repositories via `cron`.


Status:
-------

The GIT mirroring is proven, the SVN mirroing is a bit experimental.  This all here has been rewriten to make it easy to add more VCSses which can act as source for GIT.


Usage:
------

```bash
cd
git clone https://github.com/hilbix/mirror2git
crontab -e
```
`mm hh * * * mirror2git/mirror2git.sh`
where `hh:mm` is some time.


GIT:
----

The GIT mirroring is able to combine several different repositories to one combined repository.  If, like HaProxy, the development and stable branches are kept in different repositories, you can join them together again this way.

1a) Prepare the repo:
```bash
cd ~/mirror2git/git/
git clone UPSTREAM-GIT-URL somerepo1
cd somerepo1
git remote rename origin upstream
```

1b) Another way to prepare a repo:
```bash
cd ~/mirror2git/git/
mkdir somerepo1
cd somerepo1
git init
git remote add upstream UPSTREAM-GIT-URL
```

2) Add the GIT server to mirror to.  This is your server or, perhaps, GitHub:
```bash
cd ~/mirror2git/git/somerepo1
git remote add origin GIT-SERVER-URL-TO-PUSH-TO
```

3*) Possibly add more repositories to pull information from:
```bash
cd ~/mirror2git/git/somerepo1
git remote add upstream2 ANOTHERGITURL
git branch somebranch upstream2/master
```


SVN:
----

You need `git-svn` module.  It is part of Debian etc., see `apt-get install git-svn`

1) Prepare the repo:
```bash
cd ~/mirror2git/svn/
git svn clone [--stdlayout] --username=pub SVNURL [somerepo2]
```

2) Add the GIT server to mirror to.  This is your server or, perhaps, GitHub:
```bash
cd ~/mirror2git/svn/somerepo2
git remote add origin GIT-SERVER-URL-TO-PUSH-TO
```

3*) Possibly add more repositories to pull information from:
```bash
cd ~/mirror2git/git/somerepo2
git remote add upstream2 ANOTHERGITURL
git branch somebranch upstream2/master
```

Notes:

- It is unknown if this works in case `git-svn clone -s` option is used.
- The SVN branch always is on "master"
- Multiple different SVN branches are unsupported.  There is no plan to support this.
- If you ever need to change the SVN URL, see https://git.wiki.kernel.org/index.php/GitSvnSwitch


CVS:
----

> **CVS IS NOT READY YET!**

You need the `git-cvs` module.  It is part of Debian etc., see `apt-get install git-cvs`

1) Prepare the repo
```bash
cd ~/mirror2git/cvs
cvs -d :pserver:anonymous@CVSHOST:/cvsroot/CVSREPO login

git cvsimport -d :pserver:anonymous@CVSHOST:/cvsroot/CVSREPO -A CVSREPO.authors -C CVSREPO -r cvs -k CVSREPO
```



License
-------

This Works is placed under the terms of the Copyright Less License,
see file COPYRIGHT.CLL.  USE AT OWN RISK, ABSOLUTELY NO WARRANTY.


Notes
-----

If you happen to add a suitable script for another VCS, please send me a pull request on GitHub.  License to use must be CLL or PD.  Thanks.

- Where is CVS?  There is a git-cvs module, but it is a bit heuristic.  So tracking a CVS repository is not always straight forward.  Perhaps when the need arises it will be added.

- Where is BZR?  There is no standard git-bzr module yet.  Perhaps it can be done with bzr-git, but that might be difficult even for standard cases.

- Where is HG or other not mentioned VCSses?  Not looked into that, yet, sorry.

