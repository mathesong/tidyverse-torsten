FROM rocker/tidyverse:3.5.3
MAINTAINER Granville J Matheson mathesong@gmail.com

# Mostly copied from andrewheiss/tidyverse-stan, but modified to get Torsten


# Install ed, since nloptr needs it to compile
# Install clang and ccache to speed up Stan installation
# Install libxt-dev for Cairo 
# This list is too long, and should be trimmed, but contains
#   a bunch of geographical packages because there's an 
#   sf, sp etc dependency someplace in the R packages.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       apt-utils \
       ed \
       libnlopt-dev \
       clang \
       ccache \
	   cargo \
	   curl \
       libxt-dev \
	   lbzip2 \
	   libfftw3-dev \
	   libgdal-dev \
	   libgeos-dev \
	   libgsl0-dev \
	   libgl1-mesa-dev \
	   libglu1-mesa-dev \
	   libhdf4-alt-dev \
	   libhdf5-dev \
	   libjq-dev \
	   liblwgeom-dev \
	   libpq-dev \
	   libproj-dev \
	   libprotobuf-dev \
	   libnetcdf-dev \
	   libsqlite3-dev \
	   libssl-dev \
	   libudunits2-dev \
	   netcdf-bin \
	   postgis \
	   protobuf-compiler \
	   sqlite3 \
	   tk-dev \
	   unixodbc-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/


# Special stuff for JAGs because its a dependency of something
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
  jags \
  mercurial gdal-bin libgdal-dev gsl-bin libgsl-dev \ 
  libc6-i386
  
# rjags 
RUN install2.r --error --deps TRUE \
  --repos "http://cran.rstudio.com/" \
  rjags \
  R2jags	

RUN mkdir -p $HOME/.R \
    # Add global configuration files
    # Docker chokes on memory issues when compiling with gcc, so use ccache and clang++ instead
    && echo '\n \
        \nCC=/usr/bin/ccache clang \
        \n \
        \nCXX=/usr/bin/ccache clang++ -Qunused-arguments  \
        \n \
        \nCXXFLAGS=-g -O3 -std=c++1y -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2 -g -pedantic -g0 \
        \n \
		\nCXXFLAGS += -DBOOST_MPL_CFG_NO_PREPROCESSED_HEADERS -DBOOST_MPL_LIMIT_LIST_SIZE=30 \
		\n \
        \nCXXFLAGS += -O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -Wno-macro-redefined \
		\n \
        \nCXX14 = clang++ -fPIC \
		\n \
		\nCXX14FLAGS=-O3 -std=c++1y -march=native -mtune=native -Wno-unused-variable -Wno-unused-function \
		\n \
		\nCXX14FLAGS += -DBOOST_MPL_CFG_NO_PREPROCESSED_HEADERS -DBOOST_MPL_LIMIT_LIST_SIZE=30 \
		\n \
        \nCXX14FLAGS += -fPIC \
        \n' >> $HOME/.R/Makevars \
    # Make R use ccache correctly: http://dirk.eddelbuettel.com/blog/2017/11/27/
    && mkdir -p $HOME/.ccache/ \
    && echo "max_size = 5.0G \
        \nsloppiness = include_file_ctime \
        \nhash_dir = false \
        \n" >> $HOME/.ccache/ccache.conf \
    # Add configuration files for RStudio user
    && mkdir -p /home/rstudio/.R/ \
    && echo '\n \
        \nCXXFLAGS=-g -O3 -std=c++1y -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2 -g -pedantic -g0 \
        \n \
		\nCXXFLAGS += -DBOOST_MPL_CFG_NO_PREPROCESSED_HEADERS -DBOOST_MPL_LIMIT_LIST_SIZE=30 \
		\n \
        \nCXXFLAGS += -O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -Wno-macro-redefined \
		\n \
        \nCXX14 = clang++ -fPIC \
		\n \
		\nCXX14FLAGS=-O3 -std=c++1y -march=native -mtune=native -Wno-unused-variable -Wno-unused-function \
		\n \
		\nCXX14FLAGS += -DBOOST_MPL_CFG_NO_PREPROCESSED_HEADERS -DBOOST_MPL_LIMIT_LIST_SIZE=30 \
		\n \
        \nCXX14FLAGS += -fPIC \
        \n' >> /home/rstudio/.R/Makevars \
    && echo "rstan::rstan_options(auto_write = TRUE)\n" >> /home/rstudio/.Rprofile \
    && echo "options(mc.cores = parallel::detectCores())\n" >> /home/rstudio/.Rprofile

# Install rstanarm, brms, and friends
RUN install2.r --error --deps TRUE \
        StanHeaders rstan loo bayesplot rstantools brms ggmcmc  \
		lme4 nlme tidybayes \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
	
# download Torsten
RUN mkdir -p /home/Torsten \
	&& git clone https://github.com/metrumresearchgroup/Torsten.git /home/Torsten \
	&& export TORSTEN_PATH=/home/Torsten
	
# Install Torsten
RUN install2.r --error --deps TRUE \
        remotes here \
    && R -e "setwd('/home/Torsten'); source('install.R')"