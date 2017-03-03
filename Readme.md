### Purpose

Enable subgit shared-daemon feature on existing git repositories translated

More information about svn/git translation :
https://subgit.com/

### Use / Configuration

`git clone git@github.com:Webelys/subgit_shareddaemon.git`

Update **convertSharedDaemon.conf** file with :
* git repositories
* git user GID/UID value

Run `bash ./convertSharedDaemon.sh`