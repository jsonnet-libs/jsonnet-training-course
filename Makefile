default: generate html

generate:
	@rm -rf _gen && mkdir -p _gen && \
	jsonnet -J . -m _gen -S main.jsonnet

html:
	@./html/run.sh docs

generate: lessons/lesson1/examples.jsonnet
lessons/lesson1/examples.jsonnet:
	@echo "Generating lessons/lesson1/examples.jsonnet..."
	@cd lessons/lesson1 && \
	echo "local example = (import 'coursonnet.libsonnet').example;" > \
		examples.jsonnet && \
	echo "[" >> examples.jsonnet && \
	find . -type f -name \*.jsonnet | \
		grep -v main.jsonnet | \
		grep -v examples.jsonnet | \
		sort | \
		xargs --replace echo "  example.new('{}'[2:], importstr '{}', import '{}')+example.withLink()," >> \
		examples.jsonnet && \
	echo "]" >> examples.jsonnet

generate: lessons/lesson5/examples.jsonnet
lessons/lesson5/examples.jsonnet:
	@echo "Generating lessons/lesson5/examples.jsonnet..."
	@cd lessons/lesson5 && \
	echo "local example = (import 'coursonnet.libsonnet').example;" > \
		examples.jsonnet && \
	echo "[" >> examples.jsonnet && \
	find ./example1 -type f -name example\*.jsonnet | \
		sort | \
		xargs --replace echo "  example.new('{}'[2:], importstr '{}', import '{}')," >> \
		examples.jsonnet && \
	echo "]" >> examples.jsonnet

generate: lessons/lesson5/example1/docs/README.md
lessons/lesson5/example1/docs/README.md:
	@cd lessons/lesson5/example1 && \
	make docs

test: lessons/lesson1/examples.jsonnet
	@jsonnet -J . lessons/lesson1/examples.jsonnet > /dev/null && \
		echo "Success!"

generate: lessons/lessons.jsonnet
lessons/lessons.jsonnet:
	@echo "Generating lessons/lessons.jsonnet..."
	@cd lessons && \
	echo "[" > lessons.jsonnet && \
	find ./*/ -type f -name main.jsonnet | \
		sort | \
		xargs --replace echo "  (import '{}')," >> \
		lessons.jsonnet && \
	echo "]" >> lessons.jsonnet

.PHONY: generate html test
