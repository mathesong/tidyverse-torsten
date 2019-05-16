# tidyverse-torsten

This is the Dockerfile for the *tidyverse-torsten* docker container. Much of the tricky STAN configuration stuff is copied from Andrew Heiss, and his [tidyverse-stan](https://github.com/andrewheiss/tidyverse-stan), but supplemented with the installation of Torsten for pharmacometric modelling in STAN and a few extra bits and pieces for that.

## Notes

This Docker image is quite bloated in a few ways (below), and can probably be trimmed down quite a bit by anyone who is more concerned with it being leaner. It takes a long time to build, and to do the detective work to figure out what can be removed without breaking it is something I don't really have the time for right now. (maybe later). But below are the parts that could/should be trimmed by anyone with the motivation.

* I found several spatial R packages listed as dependencies someplace (and I'm not quite sure which package they originate from), so there are a bunch of extra Linux dependencies added to allow them to install (copied from the r-spatial docker), but some of these are probably unnecessary.

* I also found rjags and several related packages in here too, so those are also included, and could probably be removed with some detective work of which package requires them.

* The Makefile details for STAN also probably go a little bit overboard. I think some of the flags may be duplicated. And some of the information is probably unnecessary too. But it works, and that was non-trivial :).