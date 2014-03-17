transmerge - Merge yaml translations
=====

transmerge is used to merge yaml translation files. It's build to preserve comments, empty lines and string delimiter.
Written quick & dirty in around an hour (my first ruby app) so don't expect good code :)

Usage
-----

    ./merge.rb ./transiflex.yml ./github.yml [./english.yml] ./output.yml
    

If an english translation is given, interactive merge process is activated. Otherwise transiflex.yml translation is used in case of conflict.
While interactive merge choose translation by the keys '1' and '2'.

It preserves the style of the transiflex.yml and adds missing translations from github.yml.

Contributing
-----
Feel free to make a pull request.

License
-----
MIT License. Some subparts of this project may have other licenses.
