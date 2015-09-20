---
layout: post
title: "Jupyter to Javascript"
tags:
    - python
    - notebook
--- 
I like doing experiments in IPython notebook, or [Jupyter](http://jupyter.org)
as it's known these days. But why would I keep all the fun to myself? I want to
show my results to the world!

I'd like to use run an experiment, and then use the data to make cool
interactive visualizations. Then I want to publish them to the web. Let's see if
it works! 
 
# Running code in the browser
Here's a script that adds some text to the output cell: 

<a name="1" ></a>



```javascript
element.append('Hello World!')
```



<p id="js-output-1"></p>
<script type="text/javascript" id="js-1">
element = $("#js-output-1");
element.append('Hello World!')
</script>


 
# Using data from an old run
Now I'm running some Python code that sets a Javascript variable in its output. 

<a name="2" ></a>



```python
from IPython.display import Javascript
import json

dutch_cities_population = {
    'Amsterdam': 826659,
    'Rotterdam': 619879,
    'Den Haag': 510909,
    'Utrecht': 330772
}

Javascript("window.populations=" + json.dumps(dutch_cities_population))
```





<p id="js-output-2"></p>
<script type="text/javascript" id="js-2">
element = $("#js-output-2");
window.populations={"Amsterdam": 826659, "Rotterdam": 619879, "Utrecht": 330772, "Den Haag": 510909}
</script>




<a name="7" ></a>



```javascript
$.each(populations, function( key, value ) {
    var button = $('<button></button>');
    button.text(key);
    button.click(function() { alert(key + '\'s population is ' + value); }  );
    element.append(button);
});
```



<p id="js-output-7"></p>
<script type="text/javascript" id="js-7">
element = $("#js-output-7");
$.each(populations, function( key, value ) {
    var button = $('<button></button>');
    button.text(key);
    button.click(function() { alert(key + '\'s population is ' + value); }  );
    element.append(button);
});
</script>


 
# Blogging
The configuration that I use to turn it into a Jekyll blog post is in [this
gist](https://gist.github.com/bennokr/13293234eaf57bac887a). 
