# What is recursive-search-references.el ?
Sometimes I want to know if an Elisp extension I installed is used? Delete it if it is not used

So we open extension file, find every function name, then use ripgrep search it in my Emacs config directory, over and over again, if there are many functions define in extension, this process will be very, very painful.

recursive-search-references help you do those process automatically:
1. Use treesit list all functions in current extension
2. Use ripgrep search every functions in you special directory (usually is your emacs configuration directory), but except the directory that contain current extension
3. It will notify you "remove current extension safely" if no any reference found in directory

## Installation
1. Install Emacs 29 or above to support treesit
2. Install [ripgrep](https://github.com/BurntSushi/ripgrep)
3. Clone or download this repository (path of the folder is the `<path-to-recursive-search-references>` used below).

In your `~/.emacs`, add the following two lines:
```Elisp
(add-to-list 'load-path "<path-to-recursive-search-references>") ; add recursive-search-references to your load-path
(require 'recursive-search-references)
```

## Usage
* recursive-search-references : find function references in directory
