#!/bin/bash

currentVersion="1.1.8"

OS="$(uname -s)"
case "$OS" in
	Linux*)     os="linux";;
	CYGWIN*)    os="windows";;
	MINGW*)     os="windows";;
	*)          os="UNKNOWN:${OS}"
esac


declare default="\033[1;0m"
declare yellow="\033[1;33m"
declare cyan="\033[1;36m"
declare green="\033[1;32m"
declare red="\033[1;31m"

GITHUB_USER="EvilNick2"
GITHUB_REPO="vencord-installer"
SCRIPT_NAME="vencord-${os}.sh"

checkAndUpdateScript() {
	echo -e "${cyan}Checking for updates...${default}"

	latestRelease=$(curl -s "https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/latest")

	latestVersion=$(echo "$latestRelease" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
	if [[ "$os" = "linux" || "$os" = "windows" ]]; then
		downloadUrl=$(echo "$latestRelease" | grep '"browser_download_url":' | grep "$SCRIPT_NAME" | sed -E 's/.*"([^"]+)".*/\1/')
	else
		echo "Unsupported OS"
		exit 1
	fi

	if [ ! -z "$latestVersion" ] && [ ! -z "$downloadUrl" ] && [ "$latestVersion" != "$currentVersion" ]; then
		echo -e "${yellow}New version available: $latestVersion-$os. Updating...${default}"

		tempScript="temp_$SCRIPT_NAME"
		curl -Lo "$tempScript" "$downloadUrl"

		chmod +x "$tempScript"

		mv "$tempScript" "$SCRIPT_NAME"

		echo -e "${green}Update complete. Please rerun the script.${default}"
		echo -en "${green}Press enter to exit"'!\n'"${default}"

	# pause execution
	read -p "" opt
	case $opt in
		* ) exit;;
	esac
	else
		echo -e "${green}You are running the latest version (${currentVersion}).${default}"
	fi
}

checkAndUpdateScript

downloadPlugins() {
	declare userpluginsRepo=(
		# https://github.com/ImpishMoxxie/SoundBoardLogger.git
		https://github.com/pernydev/DontLeak.git
		https://github.com/nyakowint/vcNarrator-custom.git
		https://github.com/Syncxv/vc-timezones.git
		https://github.com/ethan-davies/ToastNotificationsMerge.git
		https://github.com/nyakowint/replaceActivityTypes.git
		https://github.com/Syncxv/vc-message-logger-enhanced.git
		https://github.com/D3SOX/vc-betterActivities.git
		https://github.com/D3SOX/vc-blockKrisp.git
		https://github.com/D3SOX/vc-followUser.git
		https://github.com/D3SOX/vc-ignoreTerms.git
		https://github.com/D3SOX/vc-mediaPlaybackSpeed.git
		https://github.com/D3SOX/vc-notifyUserChanges.git
		https://github.com/D3SOX/vc-serverProfilesToolbox.git
		https://github.com/D3SOX/vc-silentTypingEnhanced.git
		https://github.com/D3SOX/vc-voiceChatUtilities.git
		https://github.com/hauntii/vencord-steamStatusSync.git
		https://github.com/EvilNick2/keyboardSounds.git
		https://github.com/fres621/vencord-whos-watching.git
	)

	for pkg in ${userpluginsRepo[@]}; do
		repoName=$(basename $pkg .git)
		echo -e "${yellow}\n=================================="
		echo -e " Downloading ${repoName} "
		echo -e "==================================${default}"
		sleep 1
		git clone -q $pkg
	done

	declare userpluginsWget=(
		# https://raw.githubusercontent.com/exhq/uwuifier-vencord/main/uwuifier.ts
	)

	for pkg in ${userpluginsWget[@]}; do
		fileName=$(basename $pkg .ts)
		echo -e "${yellow}\n=================================="
		echo -e " Downloading ${fileName} "
		echo -e "==================================${default}"
		sleep 1
		curl -OSs $pkg
	done
}

installVencord() {
	git clone https://github.com/Vendicated/Vencord.git
	cd Vencord

	sudo npm i -g pnpm
	pnpm install
	pnpm build

	sudo pnpm inject

	cd src
	mkdir userplugins
	cd userplugins
	downloadPlugins
	pnpm build
}

downloadThemes() {
	declare themesRepo=(
		https://raw.githubusercontent.com/EvilNick2/vencord/main/themes/Spotify-Discord-Nick.theme.css
	)

	themesDir="$HOME/.config/Vencord/themes"

  for theme in ${themesRepo[@]}; do
		themeName=$(basename $theme .theme.css)
    echo -e "${yellow}\n=================================="
    echo -e " Downloading ${themeName} "
    echo -e "==================================${default}"
    sleep 1
    mkdir -p "$themesDir"
    curl -o "$themesDir/$themeName.theme.css" -sS "$theme"
  done
}

killProcess() {
	processName="Discord*"

	echo -e "${yellow}\nKilling any found discord processes.${default}"
	pkill -f $processName
}

main() {
	killProcess

	declare installDir="$HOME/Documents"
	cd $installDir

	if [ -d "$installDir/Vencord" ]; then
		echo -en "${red}Vencord folder already exists. Do you wish to reinstall? (Y/N)? ${default}"
		old_stty_cfg=$(stty -g)
		stty raw -echo
		answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
		stty $old_stty_cfg
		if [ "$answer" != "${answer#[Yy]}" ];then
			echo -en "${green}\nReinstalling Vencord!""\n${default}"
			sudo rm -rf "$installDir/Vencord"
			installVencord
			downloadThemes
		else
			echo -e "${red}\nExiting.${default}"
		fi
	else
		installVencord
	fi

	echo -e "${green}\nALL DONE! :)${default}"
	echo -en "${green}Press enter to exit"'!\n'"${default}"
	echo -en "${green}You can now relaunch discord.${default}"

	# pause execution
	read -p "" opt
	case $opt in
		* ) exit;;
	esac
}

echo -e "This file will download Vencord with custom userplugins. Vencord is against Discord TOS, but is rarely enforced."
while true; do
	echo -en 'Do you wish to continue? (Y/N)? '
	old_stty_cfg=$(stty -g)
	stty raw -echo
	answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
	stty $old_stty_cfg
	if [ "$answer" != "${answer#[Yy]}" ];then
		main
	else
		exit
	fi
done