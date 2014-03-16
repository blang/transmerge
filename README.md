transmerge - Merge yaml translations
=====

transmerge is used to merge yaml translation files. It's build to preserve comments, empty lines and string delimiter.
Written quick & dirty in around an hour so don't expect good code :)

Usage
-----

    npm install
    node merge.js ./transiflex.yml ./github.yml ./output.yml

It preserves the style of the transiflex.yml and adds missing translations from github.yml.

Contributing
-----
Feel free to make a pull request.

License
-----
MIT License. Some subparts of this project may have other licenses.
