---
layout: post
title: "Jupyter to javascript"
tags:
    - python
    - notebook
---
I like doing experiments in IPython notebook, or [Jupyter](http://jupyter.org) as it's known these days. But why would I keep all the fun to myself? I want to show my results to the world!

I'd like to use run an experiment, and then use the data to make cool interactive visualizations. Then I want to publish them to the web. Let's see if it works!

# Running code in the browser
Here's a script that adds some text to the output cell:

<a name="2" ></a>



```javascript
element.append('Hello World!')
```

<div id="js-output-2"></div>
<div class="output_subarea output_javascript ">
<script type="text/javascript">
var element = $('#js-output-2');
element.append('Hello World!')
</script>
</div>

# Using data from an old run
Now I'm running some Python code that sets a Javascript variable in its output.

<a name="7" ></a>



```python
from IPython.display import Javascript
import json

dutch_cities_population = {
    'Amsterdam': 826659,
    'Rotterdam': 619879,
    'Den Haag': 510909,
    'Utrecht': 330772
}

json.dump(dutch_cities_population, open('dutch_cities_population.json', 'w'))
```



<a name="11" ></a>



```python
%%HTML
<script>
var populations = $.parseJSON(dutch_cities_population.json');
$.each(populations, function( key, value ) {
    var button = $('<button></button>');
    button.text(key);
    button.click(function() { alert(key + '\'s population is ' + value); }  );
    element.append(button);
});
```



# Blogging
The configuration that I use to turn it into a Jekyll blog post is in [this gist](https://gist.github.com/bennokr/13293234eaf57bac887a).
