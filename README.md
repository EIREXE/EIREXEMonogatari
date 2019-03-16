# EIREXEMonogatari

EIREXEMonogatari is a series of tools written in GDScript to make creating a visual-novel style game simple.

# Usage

When the game is run in debugging mode, developers tools are made available by pressing F10, the JSON editor is then used for editing basically every file in the game.

Depending on the file, the game automatically switches to the correct editor, for example, for unknown JSON files it just gives you a text editor, however for scene files it presents a proper scene editor.

JSON files that follow a schema (ones with a __format key in them), are validated from files found in res://system/validation