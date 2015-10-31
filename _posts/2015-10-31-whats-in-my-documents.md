---
layout: post
title: "What's in my documents"
tags:
    - python
    - notebook
--- 
When you have a huge collection of documents, you can no longer read all of them
yourself. You want to know **what are all these documents about?** and find out
in a glance.

Once you have your documents up in
[DocumentCloud](https://www.documentcloud.org/home), you can make them useful in
all sorts of ways. All text is extracted and downloadable, so it's the perfect
set-up for a visualization! 
 
We're going to need some serious tools here. We need [requests](http://docs
.python-requests.org/en/latest/), a full scientific python stack,
[Gensim](https://radimrehurek.com/gensim/index.html) and
[t-sne](https://github.com/danielfrg/tsne). 



<div class="execution_count"><a name="14" href="#14">#14</a></div>

```python
import json, csv, requests, urllib, os.path
from itertools import islice, count
from gensim.models.word2vec import Word2Vec
import string
from glob import glob
import numpy as np
from tsne import bh_sne
from collections import Counter
```

 
In this post, I'll be visualizing documents that were made public in the
Netherlands as a result of Freedom of Information requests. These documents were
collected from government websites by [OpenState](http://www.openstate.eu). 



<div class="execution_count"><a name="15" href="#15">#15</a></div>

```python
project = '19706-wob-besluiten'
limit = None
```

 
# Downloading all documents as plain text
For convenience, I'm downloading all the documents, but it should be possible to
do this kind of visualization while keeping everything online. 



<div class="execution_count"><a name="16" href="#16">#16</a></div>

```python
def get_docs(project):
    """ Get metadata for all documents for this project """
    cloud_url = ("http://www.documentcloud.org/api/search.json"
            "?q=projectid:{project}&per_page=1000&page={page}")

    for i in count(start=1):
        url = cloud_url.format(page=i, project=project)
        documents_json = requests.get(url)
        wobs = json.loads(documents_json.text)
        if wobs['documents']:
            for doc in wobs['documents']:
                yield doc
        else:
            break
```




<div class="execution_count"><a name="17" href="#17">#17</a></div>

```python
docs = list(get_docs(project))
print 'there are %s documents in this collection.' % len(docs)

def get_fname(doc):
    return '{proj}/{id}.txt'.format(proj=project, id=doc['id'])
docs = [(doc, get_fname(doc)) for doc in docs if not os.path.isfile(get_fname(doc))]
print 'downloading %s new documents.' % len(docs)

for doc, fname in islice(docs, limit):
    urllib.urlretrieve(doc['resources']['text'], fname)
    print 'downloaded', doc['id']
```



 
# Create word vectors
To capture the meaning of these documents, I'm building word vector space. It
creates a vector - which is nothing but a list of numbers - for every word that
occurs more than 5 times in total. The vectors encode what kind of surroundings
a word has. If two words, like 'chair' and 'sofa' occur with the same words
(like 'sit' or 'rest'), their vectors will me similar. 



<div class="execution_count"><a name="5" href="#5">#5</a></div>

```python
%%time
no_numbers = string.maketrans("0123456789","##########")
def tokenize(s):
    return s.translate(no_numbers, string.punctuation).lower().split()

fglob = '19706-wob-besluiten/*.txt'
def get_docs(n):
    return iter(tokenize(open(fname).read()) for fname in glob(fglob)[:n])

model = Word2Vec()
model.build_vocab(get_docs(limit))
model.train(get_docs(limit))
```






<div class="execution_count"><a name="6" href="#6">#6</a></div>

```python
model.most_similar('kosten')
```




    [('materieelaanpassingen', 0.663382351398468),
     ('\xef\x81\x9f\xef\x80\xa0', 0.6463128328323364),
     ('nietaftrekbare', 0.6283468008041382),
     ('productiekosten', 0.6241079568862915),
     ('projectkosten', 0.6230412721633911),
     ('opbrengsten', 0.6218374967575073),
     ('geactiveerde', 0.6178791522979736),
     ('pensioenlasten', 0.6174764037132263),
     ('ingroeijaren', 0.6111212968826294),
     ('exploitatiekosten', 0.6083570718765259)]


 
# Create document vectors and make them 2D
Now we can add all the vectors of words in a document together, to get a
document vector. That will make similar documents have similar vectors! Then we
can reduce the size of those number lists (the vector dimensionality) down to 2,
in a way that keeps nice properties like putting similar documents close
together. 



<div class="execution_count"><a name="7" href="#7">#7</a></div>

```python
def doc_vecs(docs, model):
    for doc in docs:
        total, vec = 0, np.zeros( (model.layer1_size,) )
        for word in doc:
            if word in model:
                vec += model[word]
                total += 1
        if total:
            vec /= total
        yield np.array(vec, dtype='float64')
```




<div class="execution_count"><a name="8" href="#8">#8</a></div>

```python
%%time
X = np.vstack(list(doc_vecs(get_docs(limit), model)))
X_2d = bh_sne(X)
X_2d_norm = X_2d/np.max(X_2d)
```



 
# Extract some interesting words from each document
To get an idea of what a document is about, I thought it would be neat to look
at some of the words that make it special. The words I choose here are the ones
that occur in two of its most similar documents, too. 



<div class="execution_count"><a name="9" href="#9">#9</a></div>

```python
%%time
index2doc = dict(enumerate(glob(fglob)))
doc2index = {v:k for k,v in index2doc.iteritems()}

def neighbors(fname):
    nearest = np.argsort(-np.dot(X, X[doc2index[fname]]))
    return set([fname]+[index2doc[i] for i in nearest[:2]])

def wordlist(fname, model):
    """ Find the most important word for this document and its neighbors """
    counters = [ Counter(tokenize(open(f).read())) for f in neighbors(fname) ]
    counts = reduce(Counter.__add__, counters)
    intersection = reduce(Counter.__and__, counters)
    for word in counts.keys():
        if not (word in model.vocab and word in intersection and len(word)>1):
            counts.pop(word)
        else:
            counts[word] /= float(model.vocab[word].count)        
    return counts.most_common(10)

fnames = glob(fglob)[:X.shape[0]]
important_words = {f: wordlist(f, model) for f in fnames}
```



 
# Make a plot
Finally, some javascript magic plots the documents in an interactive diagram! 



<div class="execution_count"><a name="10" href="#10">#10</a></div>

```python
%%HTML
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script>
```




<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script>





<div class="execution_count"><a name="11" href="#11">#11</a></div>

```python
from IPython.display import Javascript
import json

def visual_data():
    for fname, (x,y) in zip(glob(fglob),X_2d_norm):
        words = [{'word':w, 'size':c} for w,c in important_words[fname]]
        title = fname.split('/')[-1].split('.')[0]
        # round the numbers to prevent js floating point errors
        yield {'x':round(x,5), 'y':round(y,5), 'title':title, 'words':words}
Javascript('window.data = ' + json.dumps( list(visual_data()) ))
```




<p id="js-output-11"></p>
<script type="text/javascript" id="js-11">
element = $("#js-output-11");
</script>
<script src="/resources/whats-in-my-documents_files/whats-in-my-documents_18_0.js"></script>





<div class="execution_count"><a name="12" href="#12">#12</a></div>

```javascript
var w=400;
var h=400;

var svg = d3.select(element[0]).append("svg")
//    .attr("xmlns", "http://www.w3.org/2000/svg")
//    .attr("xmlns:xlink", "http://www.w3.org/1999/xlink")
    .attr("width", w)
    .attr("height", h)
    .style("float", "right");
var info = d3.select(element[0]).append("div");
var title = info.append("input")
    .style("width","300px");
var words = info.append("ul");

function scatter(svg, vertices) {
    var xs = vertices.map(function(v){ return v.x; })
    var ys = vertices.map(function(v){ return v.y; })
    console.log(d3.min(xs), d3.max(xs), d3.min(ys), d3.max(ys));
    
    var scale_x = d3.scale.linear()
        .range([0, svg.attr("width")])
        .domain([d3.min(xs), d3.max(xs)]);
    var scale_y = d3.scale.linear()
        .range([svg.attr("height"), 0])
        .domain([d3.min(ys), d3.max(ys)]);

    var make_voronoi = d3.geom.voronoi()
        .x(function(d) { return scale_x(d.x) })
        .y(function(d) { return scale_y(d.y) });

    var voronoi = make_voronoi(vertices);
    return svg.selectAll("g")
        .data(vertices)
      .enter().append("svg:g")
        .each(function (d,i) {
          if (voronoi[i] != undefined) {
              d3.select(this)
                .append("path")
                .attr("d", "M" + voronoi[i].join(",") + "Z")
                .style('fill-opacity', 0) // set to 0 to 'hide' from view
                .style("stroke", "none"); // set to none to 'hide' from view
              d3.select(this)
                .append("circle")
                .attr("cx", scale_x(d.x) )
                .attr("cy", scale_y(d.y) );
          }
        });
}

scatter(svg, window.data)
    .on('mouseover', function(d) {
      d3.select(this).selectAll("circle").attr("r", 5);
      title.property("value", d.title );
      words.selectAll("li")
          .data(d.words).enter().append("li")
          .text(function(d) { return d.word });
      
    })
    .on('mouseout', function(d) {
      d3.select(this).selectAll("circle").attr("r", 2);
      title.property("value", "");
      words.selectAll("li").remove();
    })
    .selectAll("circle").attr("r", 2);
```




<p id="js-output-12"></p>
<script type="text/javascript" id="js-12">
element = $("#js-output-12");
</script>
<script src="/resources/whats-in-my-documents_files/whats-in-my-documents_19_0.js"></script>





