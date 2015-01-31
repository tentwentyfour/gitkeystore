# gitkeystore

Gitkeystore is a set of scripts that allow to encrypt and decrypt files in a git repository using GNU Privacy Guard (GPG).

At [TenTwentyFour](http://www.1024.lu) we use these scripts as a replacement for cloud-based password storage tools.

## Todo

* Before decrypting a file for editing (-e), make sure the latest changes have been pulled from origin. (Since it's quite hard to merge ASCII armor in case of merge conflicts ;) )
