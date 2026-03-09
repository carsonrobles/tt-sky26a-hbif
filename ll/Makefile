.PHONY: all
.PHONY: view
.PHONY: shell
.PHONY: clean

all:
	@echo "run librelane"
	nix-shell --pure ~/tools/librelane/shell.nix --run "librelane --pdk sky130 ./config.yaml"

view:
	nix-shell --pure ~/tools/librelane/shell.nix --run "librelane --pdk sky130 ./config.yaml --last-run --flow OpenInOpenROAD"

shell:
	nix-shell --pure ~/tools/librelane/shell.nix --run "librelane --pdk sky130 ./config.yaml --last-run --interactive"

clean:
	rm -rf ./runs
