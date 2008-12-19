# Mirror Mirror 

Mirror Mirror intends to be a service for mirroring SVN repositories to GitHub
in a reliable enough fashion that they can be considered authoritative mirrors
within the GitHub community.

## Getting Started

Clone it:

    $ git clone git://github.com/mirror/mirror.git

Import an existing SVN repository (e.g. `libxml-ruby`):

    $ mkdir -p $HOME/Documents/Projects/mirrors
    $ cd $HOME/Documents/Projects/mirrors
    $ git svn clone http://libxml.rubyforge.org/svn -s libxml-ruby

Create a GitHub repository to contain your mirror.

Add a GitHub remote:

    $ git remote add origin git@github.com:mirror/libxml-ruby.git

Run the mirroring script:

    $ /path/to/mirror.rb

Push:

    $ git push --mirror origin master


## (Un)known Issues

* Tags should be copied over as git tags, although their authorship will be
  lost
* Branches should be copied over, but this may not work properly.
* This should either be run out of cron or as a daemon in order to keep
  repositories in sync.
