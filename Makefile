DOCKER_IMAGE_NAME=dotfiles
DOCKER_ARCH=x86_64
DOCKER_NUM_CPU=4
DOKCER_RAM_GB=4

#
# Docker
#

.PHONY: docker
docker:
	@if [[ $$(limactl list colima --format "{{.Status}}") == "Stopped" ]]; then \
		colima start \
			--arch $(DOCKER_ARCH) --cpu $(DOCKER_NUM_CPU) --memory $(DOKCER_RAM_GB) \
			--mount "$${HOME}/ghq/:w" --mount "$${HOME}/.local/share/chezmoi/:w"; \
	fi
	@if ! docker inspect $(DOCKER_IMAGE_NAME) &>/dev/null; then \
		docker build -t $(DOCKER_IMAGE_NAME) . --build-arg USERNAME="$$(whoami)"; \
	fi
	docker run -it -v "$$(pwd):/home/$$(whoami)/.local/share/chezmoi" dotfiles /bin/bash --login

#
# Chezmoi
#

.PHONY: update
update:
	chezmoi apply --verbose

.PHONY: watch
watch:
	DOTFILES_DEBUG=1 watchexec -- chezmoi apply --verbose

.PHONY: reset
reset:
	chezmoi init --data=false