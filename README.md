# Toolbox
## Description
This is a collection of useful programming tools mainly written in and for [janet](https://github.com/janet-lang/janet), managed using its package manager [jpm](https://github.com/janet-lang/jpm).  
It contains a few useful functions, libraries and utilities that I use for personal computing in the shell, in small competitive programming tasks and some more.  
This project should only depend on a working janet installation with an C99 compiler and jpm set up. As well as a git + git-lfs install.  

## State
Large parts of the repo are still a work in progress and are highly unstable, if anyone wants to rely on some code of mine please open a [github issue](https://github.com/tionis/toolbox) and I will extract the code into a more stable sublibrary in it's own repo. (You can also always contact some other way, my contact details are over at [tionis.dev](https://tionis.dev))
Currently the project has all dependencies embedded, but in the future I might split them up using subtrees/submodules/jpm deps.  

## Plans
I have some bigger plans for this project that are as of this moment not realized yet, consisting of:
- Some setup scripts for different OSs to bootstrap the build environment needed for this repo.
- Embedding a small minimal shell with embedded coreutils. (Maybe a mix of busybox and my own utils?)
- Embedding a small fallback editor (Will probably embed vis for this, with some lua plugins bundled).
