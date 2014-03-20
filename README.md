transmerge - Merge yaml translations
=====

transmerge is used to merge yaml translation files. It's build to preserve comments, empty lines and string delimiter.
It uses git's blame data and the Transifex api to determine the most up-to-date version of the strings inside the translation file.
It's my first ruby app, so don't expect good code :)

Usage
-----

Edit your transifex credentials and resource settings in 'transifex_config.yml'.
Make sure your github version is inside a git repository and 'git blame ./github.yml' works.

    ./merge.rb ./transiflex.yml ./github.yml [./english.yml] ./output.yml
    
If an english translation is given, interactive merge process is activated and the english translation is shown to better compare strings. Otherwise the most up-to-date version is used.
While interactive merge choose translation by the keys '1' and '2'.

It preserves the style of the transiflex.yml and adds missing translations from github.yml.

Contributing
-----
Feel free to make a pull request.

License
-----
MIT License. Some subparts of this project may have other licenses.
