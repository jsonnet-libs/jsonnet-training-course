examples.jsonnet:
	@echo "local example = (import 'coursonnet.libsonnet').example;" > \
		examples.jsonnet && \
	echo "[" >> examples.jsonnet && \
	find . -type f -name \*.jsonnet | \
		grep -v main.jsonnet | \
		grep -v examples.jsonnet | \
		sort | \
		xargs --replace echo "  example.new('{}'[2:], import '{}', importstr '{}')," >> \
		examples.jsonnet && \
	echo "]" >> examples.jsonnet

.PHONY: test
test: examples.jsonnet
	@jsonnet -J ../../ examples.jsonnet > /dev/null && \
		echo "Success!"
