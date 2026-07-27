.PHONY: test lint manifest
test:
	bash tests/run-all.sh
lint:
	shellcheck -x installer/install.sh installer/lib/*.sh scripts/*.sh
manifest:
	bash scripts/gen-payload-manifest.sh
