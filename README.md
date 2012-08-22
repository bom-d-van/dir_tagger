rcd
===

A gem saving some frequent used paths and keeping them at hand, both in a very ease and comportable way.

Examples
-
~~~~~ shell
$ rcd -h
# Usage: rcd path/key [options]
# 
# SPECIFIC OPTIONS:
#     -a [key,new_path]                Add a new target file or direcotry
#     -l                               List all the saved paths
#     -h                               Display help message

# Add a pair of key and path, and then use a key to retrieve you path to some directory
# Assume you are in such a path: ~/path/to/somewhere
$ rcd -a home,$(pwd)
# Add Success

# output the paths save before
$ rcd home
# ~/path/to/somewhere

# Display all the saved paths and keies
$ rcd -l
# All the saved paths:
#       home    ~/path/to/somewhere

# use rcd with cd command
$ cd $(rcd home)
~~~~~

And that's all, hope you enjoy my first ruby gem. :-)
