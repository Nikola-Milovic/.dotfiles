all:
	stow --verbose --target=$$HOME --restow */

delete:
	stow --verbose --target=$$HOME --delete */

# TODO add check if its setup/work then use .gitconfig.work
setup/%:
	ln -s $$PWD/personal/.gitconfig.personal ~/.gitconfig.env
	ln -s $$PWD/sway/.config/sway/$*_config ./sway/.config/sway/env_config
	make all
