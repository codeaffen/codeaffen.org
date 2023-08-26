---
layout: post
title: Signal Spellcheck
subtitle: Setting up multiple languages for spell checking
tags: [signal, signal-desktop, desktop, spellcheck, language, locales, configuration]
author: cmeissner
---
Using `Signal` as the messenger of your choice is always a good idea. It provides **State-of-the-art end-to-end encryption**, **Text-**, **Text-** and **Video-Chats**. You can chat 1:1 or in **Groups**. There are no adds in and it is always free for everyone. And finally it provides a desktop client for the main desktop OSes (Windows, OSX and Linux).

Unfortunately Signal Desktop app on Gnome (Fedora 38) does not facilitate `hunspell`, `aspell` or comparable and it does not support setup of spellcheck langues via its UI. So we need to find another solution for getting more than your default desktop locale as a spell checking language setted up.

This guide expect that you have installed Signal Desktop from flatpak but It should work with other kinds of installing. Probably you need to adapt other files but you need to find out on your own, please refer to the documentation of your distribution.

## Language selection

Signal takes advantage of the [local environment variables](https://www.gnu.org/software/gettext/manual/html_node/Locale-Environment-Variables.html){:target="_blank"} to determine the language for UI and/or spell checking.

To use the variable of the highest precedence you can configure `LANGUAGE` with your prefered language. It will setup the UI language as well the language used for spell checking.

To start Signal with the desired Language setting you can use `env` which sets up the environment for a process.

```shell
env LANGUAGE=de_DE /usr/bin/flatpak run org.signal.Signal
```

### Multiple language support

As Signal uses [get_language_names](https://docs.gtk.org/glib/func.get_language_names.html){:target="_blank"} function from `GLib` it is possible to define more than one language to be used.

To define multiple, different languages you need to separate each other by a colon. E.g.

```shell
LANGUAGE=en_US:de_DE:it_IT
```

{: .box-note}
**Note**: The first locale from you language list will be determined as the UI language.

## Setup Language selection

As you don't want to start the app everytime from command line you need to setup your own desktop file. Simply copy the original startup file.

```shell
cp /var/lib/flatpak/app/org.signal.Signal/current/active/export/share/applications/org.signal.Signal.desktop .local/share/applications/
```

And adapt it to meet your needs, in my case I setup English, German and Italian for spell checking.

```ini
[Desktop Entry]
Name=Signal
Exec=env LANGUAGE=en_US:de_DE:it_IT /usr/bin/flatpak run --branch=stable --arch=x86_64 --command=signal-desktop --file-forwarding org.signal.Signal @@u %U @@
Terminal=false
Type=Application
Icon=org.signal.Signal
StartupWMClass=Signal
Comment=Private messaging from your desktop
MimeType=x-scheme-handler/sgnl;x-scheme-handler/signalcaptcha;
Categories=Network;InstantMessaging;Chat;
X-Desktop-File-Install-Version=0.26
X-Flatpak-RenamedFrom=signal-desktop.desktop;
X-Flatpak=org.signal.Signal
```

## Apply language settings

If Signal was already running you need to restart it once. From this moment on your language settings will apply on each and every start of Signal Desktop.
