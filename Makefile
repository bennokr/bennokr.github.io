
notebooks = $(wildcard notebooks/*/*.ipynb)
blogposts = $(addsuffix .md, $(basename $(notebooks)))
blocks = $(basename $(notebooks))

$(blogposts): %.md: %.ipynb
	# Make blog post
	ipython nbconvert --config=jekyll.py --template=jekyll.tpl --to markdown --output="$(addprefix _posts/, $(notdir $@))" "$<"

	# Make resources
	mkdir -p "resources/$(notdir $(basename $<))"
	cp "$(dir $<)"* "resources/$(notdir $(basename $<))"
	# Remove blocks
	rm "resources/$(notdir $(basename $<))"/index.html
	rm "resources/$(notdir $(basename $<))"/README.md
	git add "resources/$(notdir $(basename $<))"

blog: $(blogposts)


$(blocks): %: %.ipynb
	# Readme
	jq -r '[.cells[] | select(.cell_type=="markdown")][0].source | add' "$<" > "$(addsuffix README.md, $(dir $@))"

	# Index
	ipython nbconvert --template=blocks.tpl --to html --output="$(addsuffix index.html, $(dir $@))" "$<"

blocks: $(blocks)