---
layout: post
title: Using virtual environments for development
subtitle: Isolate your sandbox
tags: [development, python, ruby, node.js]
author: cmeissner
---

If you develop on different project in different languages you can happen that different versions of the respective scriptin languges are used.
To use different versions of your development language nevertheless keep your system clean is the purpose of environment managers. In the following article I'll want to talk about such environment managers I use for my daily work.

My first contact with an environemnt manager was within a python project. So I will start with python here follow by ruby and node.js.

## Python

{: .box-note}
**Note**: As I never use python2 for development I also have no need to use other versions as 3.x for my development. So this article also only covers python3 virtual environments.

***venv***

The simpliest way to install an virtual enviroment with python is to use the `venv` module.

~~~text
nero@matrix:~/Development/venv$ python3 -m venv venv
nero@matrix:~/Development/venv$ source my_venv/bin/activate
(venv) nero@matrix:~/Development/venv$ python --version
Python 3.8.5
~~~

***pyenv***

{: .box-warning}
**Warning**: To use `venv` is a very simple method but it is also the most limited. You are not able to install different python versions with this module.

Therefor I looked around for a better solution and found [pyenv](https://github.com/pyenv/pyenv){:target="_blank"}.
With this manager it is possible to install many different versions of python on your system an create virtual environments from there.

### installing pyenv

To use `pyenv` you can either do all steps by hand as described on the project page but I suggest [pyenv-installer](https://github.com/pyenv/pyenv-installer){:target="_blank"} instead. It installs `pyenv` with a simple curl call.

~~~text
curl https://pyenv.run | bash
~~~

The script clones the pyenv and some plugin repositories. Your have to add the following lines to your `.bash_profile` or `.bashrc` file:

~~~bash
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
~~~

### installing python and using versions of choice

After these small steps the environment manager is ready for each new shell session and you can begint to install python versions of your choice.

~~~text
pyenv install <VERSION>
~~~

Now you can create a virtual environment with it and start working isolated.

~~~text
pyenv virtualenv <VERSION> <VENV>
pyenv activate <VENV>
~~~

From now on you work on the selected version and all pip's are installed in your virtualenv.

### activating pyenv environment automatically

If you place a file named `.python-version` in a directory with the virtualenv inside it will we activated if you enter the directory.
If you leave the direcotry the virtualenv will be deactivated.

## Ruby

With the experiences I collect while programming with python in virtual environments I also started my ruby journey also with an environment manager.

One of my collegues recommended [rvm](http://rvm.io/){:target="_blank"} which seem to be the defacto standard for managing ruby environments.

### installating rvm

To install it you simply have to run the follwing two commands:

~~~text
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable --auto-dotfiles
~~~

### installing ruby and using versions of choice

Now you're able to install and use diffrent ruby versions on your system. First install a ruby version.

~~~text
nero@matrix:~$ rvm install 2.7.1
~~~

After that create a gemset for the given version to separate gems for your environment from your system ruby.

~~~text
rvm use <VERSION>
rvm gemset create <GEMSET>
~~~

### activating rvm environment automatically

To automatically activate a version and gemset you have to place a `.ruby-version` and a `.ruby-gemset` file in your directory. If you enter the directory ruby version and/or gemset will be activated. If you leave the directory it will be also deactivated.

## node.js

Finally I started a few month ago to work with node.js and I want to start with an environ manager too.
I found [nvm](https://github.com/nvm-sh/nvm){:target="_blank"} as the best candidate as my manager of choice.

### installing nvm

A simple command will install all needed commands to your system and put necessary settings to your shell profile file to load the enviroment manager correctly.

~~~text
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
~~~

### installing node and using versions of choice

To use `nvm` for instaling different versions of node you have to do the following:

~~~text
nvm install <VERSION>
nvm use <VERSION>
~~~

### activating nvm environment automatically

To activate npm version like in `pyenv` or `rvm` if you enter a directory you need an extra configuration. I prefer to put the following code in a file like `~/.nvm/autoload.sh` and source it in `.bashrc`.

~~~bash
find-up() {
    path=$(pwd)
    while [[ "$path" != "" && ! -e "$path/$1" ]]; do
        path=${path%/*}
    done
    echo "$path"
}

cdnvm() {
    cd "$@";
    nvm_path=$(find-up .nvmrc | tr -d '\n')

    # If there are no .nvmrc file, use the default nvm version
    if [[ ! $nvm_path = *[^[:space:]]* ]]; then

        declare default_version;
        default_version=$(nvm version default);

        # If there is no default version, set it to `node`
        # This will use the latest version on your machine
        if [[ $default_version == "N/A" ]]; then
            nvm alias default node;
            default_version=$(nvm version default);
        fi

        # If the current version is not the default version, set it to use the default version
        if [[ $(nvm current) != "$default_version" ]]; then
            nvm use default;
        fi

        elif [[ -s $nvm_path/.nvmrc && -r $nvm_path/.nvmrc ]]; then
        declare nvm_version
        nvm_version=$(<"$nvm_path"/.nvmrc)

        declare locally_resolved_nvm_version
        # `nvm ls` will check all locally-available versions
        # If there are multiple matching versions, take the latest one
        # Remove the `->` and `*` characters and spaces
        # `locally_resolved_nvm_version` will be `N/A` if no local versions are found
        locally_resolved_nvm_version=$(nvm ls --no-colors "$nvm_version" | tail -1 | tr -d '\->*' | tr -d '[:space:]')

        # If it is not already installed, install it
        # `nvm install` will implicitly use the newly-installed version
        if [[ "$locally_resolved_nvm_version" == "N/A" ]]; then
            nvm install "$nvm_version";
        elif [[ $(nvm current) != "$locally_resolved_nvm_version" ]]; then
            nvm use "$nvm_version";
        fi
    fi
}
alias cd='cdnvm'
cd $PWD
~~~

Now `nvm` behaves same like the other both tools. You simply need to place a `.nvmrc` file with a installed version string inside in a directory of your choice.
