## Contribute to translations ##

Please fork this repository and sync with master if you haven't done so.

1. Run `./Message.sh` before modifying `.po` files to ensure they have latest translatable strings.
2.
  - Open `com.librehat.yahooweather.po` file you're going to refine.
  - If you're going to add support for a new language, create two new directories (e.g. `fr/LC_MESSAGES` for French), copy `com.librehat.yahooweather.pot` into it and rename as `com.librehat.yahooweather.po` (a.k.a. dropping `t`)
3. Fill in `msgstr` with translated strings
4. Check if there are any `fuzzy` translations that need your attention.
5. Save
6. Add a git commit and send a pull request.
