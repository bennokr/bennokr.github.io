
notebooks = $(wildcard notebooks/*/*.ipynb)
blogposts = $(addsuffix .md, $(basename $(notebooks)))
blocks = $(basename $(notebooks))

$(blogposts): %.md: %.ipynb
	git submodule foreach git pull origin main

	# Make blog post
	jupyter nbconvert --config=jekyll.py --template=jekyll.tpl --to markdown --output-dir="$(addprefix _posts/, $(notdir $@))" "$<"

	# Make resources
	mkdir -p "resources/$(notdir $(basename $<))"
	cp "$(dir $<)"* "resources/$(notdir $(basename $<))"
	# Remove blocks
	rm "resources/$(notdir $(basename $<))"/index.html
	rm "resources/$(notdir $(basename $<))"/README.md
	git add "resources/$(notdir $(basename $<))"

blog: $(blogposts)


$(blocks): %: %.ipynb
	git submodule foreach git pull origin main

	# Readme
	jq -r '[.cells[] | select(.cell_type=="markdown")][0].source | add' "$<" > "$(addsuffix README.md, $(dir $@))"

	# Index
	jupyter nbconvert --to html --output="index.html" "$<"

blocks: $(blocks)