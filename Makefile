SHELL := bash

.PHONY: all
#all: bin usr dotfiles etc ## Installs the bin and etc directory files and the dotfiles.
all: backup bin dotfiles

BINFILES := $(shell find $(CURDIR)/local/bin -type f -not -name ".*.swp")
DOTFILES := $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github" -not -name ".*.swp" -not -name ".gnupg" -not -path '*/backup/*')

BACKUP := $(CURDIR)/backup/$(shell date '+%Y-%m-%d-%H-%M-%S')

.PHONY: mk_backup
mk_backup:
	mkdir -p $(CURDIR)/backup
	# fail if already exists
	mkdir $(BACKUP)

.PHONY: backup
backup: mk_backup
backup: ## Backup files outside ~/local that might get overwritten
	for file in $(DOTFILES); do \
		f=$$(basename $$file); \
		if [ -f $(HOME)/$$f ]; then \
			echo "Backup $(HOME)/$$f ..."; \
			cp -a $(HOME)/$$f $(BACKUP); \
		fi; \
	done; 
	mkdir -p $(BACKUP)/local/bin
	for file in $(BINFILES); do \
		f=$$(basename $$file); \
		if [ -f $(HOME)/local/bin/$$f ]; then \
			echo "Backup $(HOME)/local/bin/$$f ..."; \
			cp -a $(HOME)/local/bin/$$f $(BACKUP)/local/bin; \
		fi; \
	done; 
	echo "Backup done!"

.PHONY: bin
bin: backup
bin: ## Installs the bin directory files in ~/local.
	# add aliases in ~/local/bin
	mkdir -p $(HOME)/local/bin
	for file in $(BINFILES); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/local/bin/$$f; \
	done

.PHONY: clean
clean: ## Clean broken links if dotfiles is removed/moved
	echo "Cleaning ..."
	# recursive in local
	if [ -d $(HOME)/local ]; then \
		find $(HOME)/local -xtype l -print -delete; \
	fi;
	# non-recursive in ~
	find $(HOME) -maxdepth 1 -xtype l -print -delete
	echo "Clean done!"

.PHONY: dotfiles
dotfiles: backup
dotfiles: ## Installs the dotfiles.
	# add aliases for dotfiles
	for file in $(DOTFILES); do \
		f=$$(basename $$file); \
		echo "Install $(HOME)/$$f ..."; \
		ln -sfn $$file $(HOME)/$$f; \
	done; 
#TODO:
#	ln -fn $(CURDIR)/gitignore $(HOME)/.gitignore;
#	git update-index --skip-worktree $(CURDIR)/.gitconfig;
#	mkdir -p $(HOME)/.config;
#	ln -snf $(CURDIR)/.i3 $(HOME)/.config/sway;
#	mkdir -p $(HOME)/.local/share;
#	if [ -f /usr/local/bin/pinentry ]; then \
#		sudo ln -snf /usr/bin/pinentry /usr/local/bin/pinentry; \
#	fi;
#	mkdir -p $(HOME)/Pictures;
#	ln -snf $(CURDIR)/central-park.jpg $(HOME)/Pictures/central-park.jpg;
#	xrdb -merge $(HOME)/.Xdefaults || true
#	xrdb -merge $(HOME)/.Xresources || true
#	fc-cache -f -v || true
#
## Get the laptop's model number so we can generate xorg specific files.
#LAPTOP_XORG_FILE=/etc/X11/xorg.conf.d/10-dell-xps-display.conf
#
#.PHONY: etc
#etc: ## Installs the etc directory files.
#	sudo mkdir -p /etc/docker/seccomp
#	for file in $(shell find $(CURDIR)/etc -type f -not -name ".*.swp"); do \
#		f=$$(echo $$file | sed -e 's|$(CURDIR)||'); \
#		sudo mkdir -p $$(dirname $$f); \
#		sudo ln -f $$file $$f; \
#	done
#	systemctl --user daemon-reload || true
#	sudo systemctl daemon-reload
#	sudo systemctl enable systemd-networkd systemd-resolved
#	sudo systemctl start systemd-networkd systemd-resolved
#	sudo ln -snf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
#	LAPTOP_MODEL_NUMBER=$$(sudo dmidecode | grep "Product Name: XPS 13" | sed "s/Product Name: XPS 13 //" | xargs echo -n); \
#	if [[ "$$LAPTOP_MODEL_NUMBER" == "9300" ]]; then \
#		sudo ln -snf "$(CURDIR)/etc/X11/xorg.conf.d/dell-xps-display-9300" "$(LAPTOP_XORG_FILE)"; \
#	else \
#		sudo ln -snf "$(CURDIR)/etc/X11/xorg.conf.d/dell-xps-display" "$(LAPTOP_XORG_FILE)"; \
#	fi
#
#.PHONY: usr
#usr: ## Installs the usr directory files.
#	for file in $(shell find $(CURDIR)/usr -type f -not -name ".*.swp"); do \
#		f=$$(echo $$file | sed -e 's|$(CURDIR)||'); \
#		sudo mkdir -p $$(dirname $$f); \
#		sudo ln -f $$file $$f; \
#	done
#
.PHONY: test
test: shellcheck ## Runs all the tests on the files in the repository.

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

.PHONY: shellcheck
shellcheck: ## Runs the shellcheck tests on the scripts.
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		ghcr.io/djerz/shellcheck ./test.sh

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %s\n", $$1, $$2}'

