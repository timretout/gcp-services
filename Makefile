services != awk -F, '{print $$1}' build/gcloud-services-list-available.csv | grep 'googleapis\.com' | sed 's/^/docs\//;s/$$/\/index.md/'

all: build/gcloud-services-list-available.csv $(services)

build/gcloud-services-list-available.csv:
	mkdir -p build
	gcloud services list --available --format='csv(config.name,config.title)' > $@

docs/index.md: build/gcloud-services-list-available.csv generate-index
	./generate-index

docs/%/index.md: build/%/automatically-enabled-services.csv generate-service-overview
	./generate-service-overview $*

build/%/automatically-enabled-services.csv:
	mkdir -p build/$*
	./disable-all-services
	gcloud services enable $*
	gcloud services list --format='value(config.name)' | grep -v $* > $@
	./disable-all-services
