.PHONY: all
.PHONY: view
.PHONY: clean

all:
	@echo "run librelane"
	nix-shell --pure ~/tools/librelane/shell.nix --run "librelane --pdk sky130 ./config.yaml"

view:
	nix-shell --pure ~/tools/librelane/shell.nix --run "librelane --pdk sky130 ./config.yaml --last-run --flow OpenInOpenROAD"

clean:
	rm -rf ./runs
