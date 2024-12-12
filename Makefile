.DEFAULT_GOAL := create

create:
	@kind create cluster --config /clusters-kind/config.yaml

destroy:
	@kind delete clusters kind 