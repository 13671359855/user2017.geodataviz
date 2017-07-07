.PHONY: all knit install check build publish clean

# All Markdowns except notebooks
RMD_FILES=$(shell find . -path ./inst/notebooks -prune -o -name '*.Rmd' -print)
# Corresponding HTMLs, cache & figures dirs.
HTML_FILES=$(RMD_FILES:%.Rmd=%.html)
FIGURE_DIRS=$(RMD_FILES:%.Rmd=%_files)
CACHE_DIRS=$(RMD_FILES:%.Rmd=%_cache)

# R notebooks and corresponding outputs, and cache & figures dirs.
RMD_NOTEBOOK_FILES=$(shell find inst/notebooks -name '*.Rmd')
NBHTML_FILES=$(RMD_NOTEBOOK_FILES:%.Rmd=%.nb.html)
NBHTML_FIGURE_DIRS=$(RMD_NOTEBOOK_FILES:%.Rmd=%_files)
NBHTML_CACHE_DIRS=$(RMD_NOTEBOOK_FILES:%.Rmd=%_cache)

# Command to knit Rmds
RENDER = Rscript -e "devtools::load_all();suppressMessages(library(rmarkdown)); render('$<', quiet=TRUE)"

# For all Rmds sans R notebooks.
%.html: %.Rmd
	@echo "\033[35m$< ==> $@\033[0m"
	$(RENDER)

# For all R notebooks
%.nb.html: %.Rmd
	@echo "\033[35m$< ==> $@\033[0m"
	$(RENDER)

all: knit publish

knit: knit.done

knit.done: $(HTML_FILES) $(NBHTML_FILES)
	@echo "\033[35mBuilding Package\033[0m"
	touch $@

build: knit
	Rscript -e 'devtools::build()'

check: knit
	Rscript -e 'devtools::check()'

install: knit
	Rscript -e 'devtools::install(local=F, upgrade_dependencies=F, dependencies=F, quick=T)'

# This requires a gh-pages worktree setup to sync with gh-pages branch.
publish:
	@echo "\033[35mSyncing with gh-pages\033[0m"
	if [ -d "./gh-pages" ]; then \
		rsync -av  --exclude '*_cache' --exclude '*.Rmd' --exclude extdata \
		--exclude 'notebooks/*.R' --exclude 'notebooks/rosm.cache'  inst/ ./gh-pages; \
	fi;

clean:
	@echo "\033[35mCleaning ...\033[0m"
	rm -rf knit.done $(HTML_FILES) $(CACHE_DIRS) $(FIGURE_DIRS) $(NBHTML_FILES) $(NBHTML_CACHE_DIRS) $(NBHTML_FIGURE_DIRS)
