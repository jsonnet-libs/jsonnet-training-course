.PHONY: generate
generate:
	@mkdir -p _gen
	@jsonnet -J . -m _gen -S main.jsonnet
