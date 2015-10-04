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



<div class="execution_count"><a name="169" href="#169">#169</a></div>

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



<div class="execution_count"><a name="170" href="#170">#170</a></div>

```python
project = '19706-wob-besluiten'
limit = 1000
```

 
# Downloading all documents as plain text
For convenience, I'm downloading all the documents, but it should be possible to
do this kind of visualization while keeping everything online. 



<div class="execution_count"><a name="171" href="#171">#171</a></div>

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




<div class="execution_count"><a name="173" href="#173">#173</a></div>

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


    there are 11407 documents in this collection.
    downloading 0 new documents.

 
# Create word vectors
To capture the meaning of these documents, I'm building word vector space. It
creates a vector - which is nothing but a list of numbers - for every word that
occurs more than 5 times in total. The vectors encode what kind of surroundings
a word has. If two words, like 'chair' and 'sofa' occur with the same words
(like 'sit' or 'rest'), their vectors will me similar. 



<div class="execution_count"><a name="28" href="#28">#28</a></div>

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


    CPU times: user 31.4 s, sys: 825 ms, total: 32.2 s
    Wall time: 31.7 s




<div class="execution_count"><a name="162" href="#162">#162</a></div>

```python
model.most_similar('londen')
```



    [('geneve', 0.6877090930938721),
     ('paris', 0.6521526575088501),
     ('petersburg', 0.6325381398200989),
     ('kco', 0.6321488618850708),
     ('stallestraat', 0.6314813494682312),
     ('cura\xc3\x87ao', 0.6202374696731567),
     ('varcdpcdp', 0.6190001964569092),
     ('bikker', 0.6130961179733276),
     ('adam', 0.6066200733184814),
     ('kelen', 0.6047987937927246)]



 
# Create document vectors and make them 2D
Now we can add all the vectors of words in a document together, to get a
document vector. That will make similar documents have similar vectors! Then we
can reduce the size of those number lists (the vector dimensionality) down to 2,
in a way that keeps nice properties like putting similar documents close
together. 



<div class="execution_count"><a name="40" href="#40">#40</a></div>

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




<div class="execution_count"><a name="48" href="#48">#48</a></div>

```python
%%time
X = np.vstack(list(doc_vecs(get_docs(limit), model)))
X_2d = bh_sne(X)
X_2d_norm = X_2d/np.max(X_2d)
```


    CPU times: user 26.3 s, sys: 327 ms, total: 26.6 s
    Wall time: 27.1 s

 
# Extract some interesting words from each document
To get an idea of what a document is about, I thought it would be neat to look
at some of the words that make it special. The words I choose here are the ones
that occur in two of its most similar documents, too. 



<div class="execution_count"><a name="146" href="#146">#146</a></div>

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


    CPU times: user 24.1 s, sys: 658 ms, total: 24.8 s
    Wall time: 26 s

 
# Make a plot
Finally, some javascript magic plots the documents in an interactive diagram! 

(malfunctioning)