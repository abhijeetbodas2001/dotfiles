for file in\
    ".bashrc"\
    ".bash_aliases"\
    ".bash_profile"\
    ".inputrc"\
    ".gitconfig"\
    ".vimrc"
do
    echo $file
    cp $FROM/$file $TO/
done

mkdir -p $TO/.config/nvim
cp $FROM/.config/nvim/init.lua $TO/.config/nvim
cp -R $FROM/.config/nvim/autoload/ $TO/.config/nvim

mkdir -p $TO/.config/Code/User/
cp $FROM/.config/Code/User/{settings.json,keybindings.json} $TO/.config/Code/User/

dconf dump / > ./gnome_settings # to restore, dconf load / < ./gnome_settings

mkdir -p $TO/.config/mpv
cp $FROM/.config/mpv/* $TO/.config/mpv/

mkdir -p $TO/.config/ptpython
cp $FROM/.config/ptpython/* $TO/.config/ptpython

