# Enable non-standard inputs
gsettings set org.gnome.desktop.input-sources show-all-sources true
# Enable Natural Scrolling
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true

gsettings set org.gnome.Terminal.Legacy.Settings headerbar false
gsettings set org.gnome.desktop.wm.preferences button-layout 'minimize,close'

yay -S --noconfirm gnome-shell-extension-Dclipboard-indicator
yay -S --noconfirm gnome-shell-extension-dash-to-dock
yay -S --noconfirm gnome-shell-pomodoro
