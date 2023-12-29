services != awk -F, '{print $$1}' build/gcloud-services-list-available.csv | grep 'googleapis\.com' | sed 's/^/docs\//;s/$$/\/index.md/'

all: build/gcloud-services-list-available.csv $(services) docs/index.md

build/gcloud-services-list-available.csv:
	mkdir -p build
	gcloud services list --available --format='csv(config.name,config.title)' > $@

docs/index.md: build/gcloud-services-list-available.csv generate-index
	./generate-index

docs/%/index.md: build/%/automatically-enabled-services.csv build/%/apis.tsv generate-service-overview
	./generate-service-overview $*

build/%/automatically-enabled-services.csv:
	mkdir -p build/$*
	./disable-all-services
	gcloud services enable $*
	gcloud services list --format='value(config.name)' | grep -v $* > $@
	./disable-all-services

build/google-api-discovery-service.json:
	curl https://discovery.googleapis.com/discovery/v1/apis > $@

build/%/apis.tsv: build/google-api-discovery-service.json
	jq --arg pattern "https://$*|/apis/$(subst .googleapis.com,,$*)/" -r '.items[] | select(.discoveryRestUrl | test($$pattern)) | [.id, .discoveryRestUrl, .documentationLink, .description] | @tsv'  build/google-api-discovery-service.json > $@
