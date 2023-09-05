all:
	stow --verbose --target=$$HOME --restow */ 
	
delete:
	stow --verbose --target=$$HOME --delete */
	rm $$PWD/personal/.gitconfig.env
	rm $$PWD/sway/.config/sway/env_config

# TODO add check if its setup/work then use .gitconfig.work
setup/%:
	cp $$PWD/personal/.gitconfig.personal $$PWD/personal/.gitconfig.env
	cp $$PWD/sway/.config/sway/$*_config $$PWD/sway/.config/sway/env_config
	make all 
