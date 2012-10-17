DirTagger
===

A gem saving some frequent used paths and keeping them at hand, both in a very ease and comportable way. The concept is to give your directory a tag, and then store it in '~/.tag_dir_profile'. After that, you can retrieve the path of the directory by a shell command with the tag as parameter.
https://github.com/bom-d-van/dir_tagger

Examples
-
~~~~~ shell
$ dir_tagger -h
# Usage: tagdir tag[,directory] [options]
# 
# SPECIFIC OPTIONS:
#     -a, --add tag[,directory]        Tag a directory, the defaualt directory is the current directory
#     -u, --under tag[,tag2, ..]       Operate tag within parent tags
#     -r, --remove tag,[tag2, ..]      Remove one or more tags
#     -l, --list                       List all the saved paths
#     -t, --tags [pattern1, ..]
#     -d, --dir [pattern1, ..]
#     -v, --version                    List current TagDir Version
#     -h, --help                       Display help message

# Tag a directory
# Assume you are in such a path: ~/path/to/home
$ dir_tagger -a home
# Add Success

# Retrieve directory by the tag
$ dir_tagger home
# ~/path/to/home

# Ruby style regexp support.
$ dir_tagger ho
# ~/path/to/home

# Nested Tagging
$ echo pwd
# ~/path/to/home/code
$ dir_tagger -a code -u home
# Add Success
$ dir_tagger ho co
# ~/path/to/home/code

# Display all the saved tags and directories
$ dir_tagger
# All the saved paths:
#       home    ~/path/to/home
#           home    ~/path/to/home/code
~~~~~

Using dir_tagger in shell
-
~~~~~ shell
# use rcd with cd command
$ cd $(rcd home)

# some powerful shell snippets with dir_tagger
function xto {
    xto_path=$(dir_tagger $*)
    if [[ "$xto_path" != "" ]]; then
        cd "$xto_path"
    else
        echo -e '\033[31mPath Not Existed!\033[0m'
    fi
}

function xmate {
    proj=$(dir_tagger $1)
    proj_name=$(dir_tagger -k $1)
    tmproj=$proj/$proj_name.tmproj
    if [[ -f $tmproj ]]; then
        open "$tmproj"
    elif [[ "$proj" != "" ]]; then
        mate "$proj"
    else
        echo -e '\033[31mPath Not Existed!\033[0m'
    fi
}

function xproj {
    xmate $*
    xto $*
}

$ pwd
# somewhere/else
$ xto ho
# path/to/home

~~~~~

And that's all, hope you enjoy my first ruby gem. :-)
