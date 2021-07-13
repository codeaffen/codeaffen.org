---
layout: post
title: Oh my zsh walkthrough
subtitle: Get the best out of your Z shell
tags: [development, shell, zsh, ohmyzsh, OMZ, environment, configuration, themes, plugins]
author: cmeissner
---

Configuring your shell to get the best out of it can become a tedious task. Some common tasks are:

* configuring your prompt to give you more useful information as the default
  * display git information if you corresponding directory (e.g. branch, git status, ...)
  * display information for use virtual envs (rvm, pyenv, nvm)
* configure useful aliases
  * writing sophisticated functions for that purpose

Last I was annoyed to do this stuff ever and ever if I get a new computer or so. After digging a bit I found [Oh my zsh](https://ohmyz.sh) (OMZ). The claim on their project homepage say all about it in a single sentence:

{: .box-note}
Oh My Zsh is a delightful, open source, community-driven framework for managing your Zsh configuration. It comes bundled with thousands of helpful functions, helpers, plugins, themes, and a few things that make you shout..."Oh My ZSH!"

Oh wow that's sounds good, lets try!

## Installation

To install this gorgeous framework you simply have to run a single command but I want to go a step back and show you how to install recommanded parts first to start directly in a clean way.

### zsh

To use OMZ you need the `zsh` (Z shell) as a minimum. If you don't have it already you need to install it first with the package manager of your target system.

For `Mac OS X` and `Ubuntu` I can confirm that `zsh` is already installed. On new `Mac OS X` versions it is also the default shell for users. On `Ubuntu` the `bash` (Bourne-Again SHell) is the default shell.

### powerline fonts

As OMZ comes with many themes to change the look of your shell and most of them uses [powerline fonts](https://github.com/powerline/fonts){:target="_blank"} to let the prompt look much more eye candy.

To install `powerline fonts` you only need to run the following commands in your shell.

~~~shell
$ git clone https://github.com/powerline/fonts.git
$ cd fonts
$ ./install.sh
Copying fonts...
Resetting font cache, this may take a moment...
~~~

This will download the `powerline fonts` repository and install the fonts locally.
The install script also refresh the font cache on a linux system.

After installing the fonts you can delete the repository directory.

### oh my zsh

In the easiest case you have to run one single command to install and setup `onmyzsh` on your system.

~~~shell
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
~~~

This will download and run the installer. The install script works interactively and will ask you some simple questions.

{: .box-note}
**Info**: If your use is not configured to use `zsh` as login shell the installer ask to change your login shell. If you want to try OMZ first you can answer the question for changing your shell with `n`.
You can later change your login shell with `chsh <path to zsh>`.

{: .box-warning}
**Warning**: The installer creates a `.zshrc` file. If you already have your own resource file your find backup at `~/.zshrc.pre-oh-my-zsh`.

## Configuration

Congratulations! With the steps we described before you installed OMZ framework on your system and you will use it on the next start of your `zsh`.

But this is not all. Next you should configure OMZ that it meets your needs.

### Themes

To change the look of your shell you can try some of the many themes which come with the framework.

As their come a massive ammount of themes with OMZ it can be difficult to find the right theme for you by trying it all. For that purpose you can take a look on the [Theme list](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes){:target="_blank"} on the OMZ wiki.

The default theme after installation is `robbyrussell` and it can be changed by setting the variable `ZSH_THEME` within your `.zshrc` file.

One of the most famous theme is the [agnoster](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes#agnoster){:target="_blank"} which is also mentioned on the projects readme file.

{: .box-note}
**Note**: If you use a theme which facilitates powerline fonts you also need to adjust the configuration of some tools beside the `.zshrc` file.

***iterm2***

As `iterm2` on OS X does not take care of the font configuration from your shell resource file you need to configure a font that guarantees that the theme is rendered well.

To do so you have to open `Preferences -> Profiles -> <Your Profile> -> Text`. Here you have to tick `Use a different font for non-ASCII text` and select a font in the `non-ASCII Font` dropdown menu.

You can select a Meslo font (e.g. `Meslo LG S for Powerline`).

***Terminal.app***

Also the internal `Terminal.app` in Mac OS X needs to be configured to use a Powerline Font for rendiring the new prompt correctly.
Here you have to open the following click path: `Preferences -> Profiles -> <Your Profile>`. In that pane you need to click the `Change...` button in Font section. In the opening dialog you can select a corresponding font (e.g. `Meslo LG S for Powerline`).

***Visual Studio Code***

To let your theme render correctly in VSCodes internal terminal you need to add the following line to your `settings.json` (Preferences: Open Settings (JSON)):

~~~json
"terminal.integrated.fontFamily": "Meslo LG S for Powerline"
~~~

### Plugins

Plugins are a great way to extend your shell with new functionality, e.g. completion scripts, exported functions or aliases to make the life much easier.

OMZ comes with a bunch of plugins. You should take a look a the [list of plugins](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins){:target="_blank"} in the repository.

Each plugin should have a README which describe what do you get with the plugin.

To use a plugin you only need to add the plugin name to the variable `plugins` in your `.zshrc` file.

~~~shell
plugins=(
  ansible
  gh
  git
  dotenv
)
~~~

## Conclusion

With this little introduction you should be able to install and configure OMZ on your system.

Have fun with that great piece of software.
