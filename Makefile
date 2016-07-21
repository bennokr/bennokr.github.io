
notebooks = $(wildcard notebooks/*/*.ipynb)
blogposts = $(addsuffix .md, $(basename $(notebooks)))

$(blogposts): %.md: %.ipynb
	ipython nbconvert --config=jekyll.py --template=jekyll.tpl --to markdown --output="$@" "$<"
	cp "$@" "$(addprefix _posts/, $(notdir $@))"
	mkdir -p "resources/$(notdir $(basename $<))"
	cp $(dir $<)* "resources/$(notdir $(basename $<))"
	git add "resources/$(notdir $(basename $<))"

blog: $(blogposts)
	git commit -am "Update blog"
	git push

blocks: