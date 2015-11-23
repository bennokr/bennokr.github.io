---
layout: post
title: "Nonsense text"
tags:
    - python
    - notebook
--- 
# Nonsense Text
You can make funny nonsense text by counting words. For every word in a text,
you count how often it follows the previous word. Then you generate text by
choosing a next word according to how often you counted it!

This is called a **markov chain**. It's not really useful until you start
tracking words further back. If you keep track of not just the previous word but
two or more words back, the text you can generate is a little less *nonsense*
and a little more *sense*. But you need a lot of text to get reliable counts of
word sequences. That's why many people *smooth* those counts.

But that's a whole different subject. **For now, press the button at the bottom
of the page!** 



<div class="execution_count"><a name="1" href="#1">#1</a></div>

```python
from IPython.display import Javascript
import json, requests, re
url = 'http://www.gutenberg.org/cache/epub/1524/pg1524.txt'
text = filter(None, re.split(r'\s+|([\W])', requests.get(url).content[12891:]))
Javascript('document.text='+json.dumps(text))
```




<p id="js-output-1"></p>
<script type="text/javascript" id="js-1">
element = $("#js-output-1");
</script>
<script src="/resources/nonsense-text_files/nonsense-text_1_0.js"></script>





<div class="execution_count"><a name="2" href="#2">#2</a></div>

```javascript
document.make_counts = function(text) {
    var previous_word = null;
    var counts = {null: {null: 0}};
    for (var i=0; i<text.length; i++) {
        counts[previous_word] = counts[previous_word] || {null: 0};
        counts[previous_word][null]++;
        counts[previous_word][text[i]] = counts[previous_word][text[i]]+1 || 1;
        counts[null][text[i]] = counts[null][text[i]]+1 | 1;
        counts[null][null]++;
        previous_word = text[i];
    }
    return counts;
}
document.counts = document.make_counts(document.text);
```




<p id="js-output-2"></p>
<script type="text/javascript" id="js-2">
element = $("#js-output-2");
</script>
<script src="/resources/nonsense-text_files/nonsense-text_2_0.js"></script>





<div class="execution_count"><a name="3" href="#3">#3</a></div>

```python
%%html
<script type="text/javascript">
function setupReader(file) {
    var name = file.name;
    console.log(name);
    var reader = new FileReader();  
    reader.onload = function(e) {  
        var text = e.target.result.split(/\s+|([\W])/).filter(Boolean); 
        document.counts = document.make_counts(text);
        console.log(document.counts[null][null]);
    }
    reader.readAsText(file, "UTF-8");
}

function handleFiles(fileList) {
    for (var i = 0; i < fileList.length; i++) {
        setupReader(fileList[i]);
    }
}
</script>
<input type="file" id="input" onchange="handleFiles(this.files)" style="padding:100px;">
```




<script type="text/javascript">
function setupReader(file) {
    var name = file.name;
    console.log(name);
    var reader = new FileReader();  
    reader.onload = function(e) {  
        var text = e.target.result.split(/\s+|([\W])/).filter(Boolean); 
        document.counts = document.make_counts(text);
        console.log(document.counts[null][null]);
    }
    reader.readAsText(file, "UTF-8");
}

function handleFiles(fileList) {
    for (var i = 0; i < fileList.length; i++) {
        setupReader(fileList[i]);
    }
}
</script>
<input type="file" id="input" onchange="handleFiles(this.files)" style="padding:100px;">





<div class="execution_count"><a name="4" href="#4">#4</a></div>

```javascript
function weighted_choice(choices) {
    var total = choices['null'];
    var r = Math.random() * total;
    var upto = 0;
    for (var w in choices) {
        if (w!=='null') {
            if (upto + choices[w] > r) {
                return w;
            }
            upto += choices[w];
        }
    }
}

document.sample = function() {
    var previous_word = 'null';
    var text = '';
    for (var i=0; i<100; i++) {
        var word = weighted_choice(document.counts[previous_word]);
        text += word + ' ';
        previous_word = word;
    }
    return text;
}
```




<p id="js-output-4"></p>
<script type="text/javascript" id="js-4">
element = $("#js-output-4");
</script>
<script src="/resources/nonsense-text_files/nonsense-text_4_0.js"></script>





<div class="execution_count"><a name="5" href="#5">#5</a></div>

```python
%%html
<button onclick="document.getElementById('sample').innerHTML = document.sample()">
    Sample
</button>
<div id="sample"></div>
```




<button onclick="document.getElementById('sample').innerHTML = document.sample()">
    Sample
</button>
<div id="sample"></div>


