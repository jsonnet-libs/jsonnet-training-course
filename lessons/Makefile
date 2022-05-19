lessons.jsonnet:
	echo "[" > lessons.jsonnet && \
	find ./*/ -type f -name main.jsonnet | \
		sort | \
		xargs --replace echo "  (import '{}')," >> \
		lessons.jsonnet && \
	echo "]" >> lessons.jsonnet
