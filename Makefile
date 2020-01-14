.PHONY: terraform
terraform:
	docker run --rm -ti \
	-v $$PWD/$(PLATFORM):/home/terraform \
	-w /home/terraform \
	hashicorp/terraform \
	$(COMMAND)

.PHONY: init
init:
	COMMAND="init" \
	make terraform

.PHONY: apply
apply: init
	COMMAND="apply" \
	make terraform

.PHONY: destroy
destroy: init
	COMMAND="destroy" \
	make terraform

.PHONY: digitalocean
digitalocean:
	PLATFORM="digitalocean" \
	make apply

.PHONY: digitalocean-destroy
digitalocean-destroy:
	PLATFORM="digitalocean" \
	make destroy