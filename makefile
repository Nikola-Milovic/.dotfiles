all:
	stow --verbose --target=$$HOME --restow */

delete:
	stow --verbose --target=$$HOME --delete */

setup/%:
	ln -s $$PWD/sway/.config/sway/$*_config ./sway/.config/sway/env_config
	make all
