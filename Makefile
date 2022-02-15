.PHONY: help

genico: ## help
	cd assets; convert icon.png -scale 16 16.png && convert icon.png -scale 32 32.png && convert icon.png -scale 48 48.png && convert icon.png -scale 128 128.png && convert icon.png -scale 256 256.png
	cd assets; convert 16.png 32.png 48.png 128.png 256.png icon.ico
	cd assets; rm 16.png 32.png 48.png 128.png 256.png
