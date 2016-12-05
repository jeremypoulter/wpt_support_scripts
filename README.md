# wpt_support_scripts
Scripts and other bits to help manage long living forks W3C's web-platform-tests. 

## Auto merge W3C

The ```fork_sync.sh``` script automates the process of merging braches into a repository. This is intended
to be run on [Travis CI](https://travis-ci.org/) or another continuious intergration service but can also 
be used locally if needed.

### Command Line

```
fork_sync.ssh <repository> <to user> <to branch> [<from user> <from branch> ...]
```

```repository```:  
the repository name

```to user```:  
the GitHub account containing the fork to merge to

```to branch```  
the branch to merge to

```from user```  
the GitHub account to merge from

```from branch```  
the branch to merge from

You may specify ```from user``` and ```from branch``` multiple time to merge multiple 
forks/branches.

#### Examples

Merge changes from W3C to w3c_mirror branch;

```
fork_sync.sh web-platform-tests dlna w3c_mirror w3c master
```

Merge changes from W3C and local changes to w3c_tracking branch;

```
fork_sync.sh web-platform-tests dlna w3c_tracking w3c master dlna master
```

### Key generation

If you fork the repository you will need to replace the SSH keys used to push the merged
changes back to the repository.

```
mkdir keys
ssh-keygen -f keys/web-platform-tests.pem -C "Travis CI key"
ssh-keygen -f keys/wpt-tools.pem -C "Travis CI key"
tar cvf keys.tar keys
travis encrypt-file keys.tar
```

Update .travis.yml as indicated in travis encrypt-file output.

Set keys/web-platform-tests.pem.pub as deploy key on web-platform-tests fork and set keys/wpt-tools.pem 
as the deploy key on wpt-tools fork. Make sure you give write access or the changes can not be pushed 
back.

```
git add keys.tar.enc .travis.yml
git commit
git push origin master
```
