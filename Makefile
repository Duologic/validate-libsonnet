README.md: main.libsonnet
	jsonnet -J vendor -S -c -m . \
			--exec "(import 'doc-util/main.libsonnet').render(import 'main.libsonnet')"
