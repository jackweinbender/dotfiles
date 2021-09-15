#! /bin/bash

# Make  the project
echo "Restarting Gnome shell!"
if bash -c 'xprop -root &> /dev/null'; then \
    busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting Gnome...")'; \
else \
    gnome-session-quit --logout; \
fi
sleep 3