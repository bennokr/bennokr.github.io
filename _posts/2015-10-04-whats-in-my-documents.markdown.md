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


(malfunctioning)