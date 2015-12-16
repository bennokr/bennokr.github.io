---
layout: post
title: "What's Cooking?"
tags:
    - python
    - notebook
--- 
*Can we predict which cuisine a meal is from using its ingredients?*

In the [What's Cooking?](https://www.kaggle.com/c/whats-cooking) Kaggle
challenge, participants are asked to predict the category of a dish's cuisine
given a list of ingredients. In this blog post, I'll show you a quick baseline
built with [scikit-learn](http://scikit-learn.org). You can try it out at the
bottom of the page! 
 
# Loading the data
The dataset consists of the ingredient lists of lots of recipes, and the
corresponding cuisine: 



<div class="execution_count"><a name="1" href="#1">#1</a></div>

```python
import json
recipes = json.load(open('train.json'))
print 'training set size:', len(recipes)
cuisines, ingredients = zip(*[(r['cuisine'], r['ingredients']) for r in recipes])
cuisines[0], ingredients[0]
```






    (u'greek',
     [u'romaine lettuce',
      u'black olives',
      u'grape tomatoes',
      u'garlic',
      u'pepper',
      u'purple onion',
      u'seasoning',
      u'garbanzo beans',
      u'feta cheese crumbles'])


 
As you can see, most recipes contain salt or olive oil. Keep those handy in the kitchen!


<div class="execution_count"><a name="2" href="#2">#2</a></div>

```python
from collections import Counter
ingredient_counter = Counter(i for r in ingredients for i in r)
print 'different ingredients:', len(ingredient_counter)
ingredient_counter.most_common(10)
```






    [(u'salt', 18049),
     (u'olive oil', 7972),
     (u'onions', 7972),
     (u'water', 7457),
     (u'garlic', 7380),
     (u'sugar', 6434),
     (u'garlic cloves', 6237),
     (u'butter', 4848),
     (u'ground black pepper', 4785),
     (u'all-purpose flour', 4632)]


 
# Build an recipe-ingredient matrix
A `MultiLabelBinarizer` converts a list of items into a vector of ones and
zeros. For example, if we had three different ingredients and a recipe only
contained number 2, the vector of that recipe would be `[0,1,0]`. 



<div class="execution_count"><a name="3" href="#3">#3</a></div>

```python
import numpy as np
from sklearn.preprocessing import MultiLabelBinarizer
binarizer = MultiLabelBinarizer(sparse_output=True)
X = binarizer.fit_transform(ingredients)
y = np.array(cuisines)
X
```






    <39774x6714 sparse matrix of type '<type 'numpy.int64'>'
    	with 428249 stored elements in Compressed Sparse Row format>


 
# Cross-validate the model
To see how my model performs, I check the cross-validation score on 5 folds over
the data. That means that I train the model on a random part of the training
data and check the predictions on the rest 5 times. 



<div class="execution_count"><a name="4" href="#4">#4</a></div>

```python
from sklearn.linear_model import LogisticRegression
from sklearn.cross_validation import cross_val_score

lr = LogisticRegression()
print 'cross validation accuracy:', cross_val_score(lr, X, y, cv=5, n_jobs=-1)
```



 
# Submit predictions
Now I need to fit the binarizer on both the training and the test data, because
the test data contains ingredients that are not in the training data. That means
I have more features and the matrix `X` will be wider.

My submission got a score of `0.78339` on the [Kaggle
leaderboard](https://www.kaggle.com/c/whats-cooking/leaderboard), which means
that the cross-validation was very accurate! 



<div class="execution_count"><a name="5" href="#5">#5</a></div>

```python
import csv
test_recipes = json.load(open('test.json'))
test_ids, test_ingredients = zip(*[(r['id'], r['ingredients']) for r in test_recipes])

binarizer.fit(np.hstack([ingredients, test_ingredients]))
X = binarizer.transform(ingredients)
lr.fit(X, y)
test_cuisines = lr.predict(binarizer.transform(test_ingredients))
with open('submission.csv','w') as sub:
    w = csv.writer(sub)
    w.writerow(['id', 'cuisine'])
    w.writerows(zip(test_ids, test_cuisines))
```

 
# Interactive cuisine-predicter
Just for fun, here's the model for you to play around with. 



<div class="execution_count"><a name="6" href="#6">#6</a></div>

```python
from IPython.display import Javascript
js = 'window.ingredients = %s;' % json.dumps(list(binarizer.classes_))
js += 'window.cuisines = %s;' % json.dumps(list(lr.classes_))
js += 'window.coef = %s;' % json.dumps(map(list, lr.coef_.T))
Javascript(js)
```




<p id="js-output-6"></p>
<script type="text/javascript" id="js-6">
element = $("#js-output-6");
</script>
<script src="/resources/whatscooking_files/whatscooking_12_0.js"></script>





<div class="execution_count"><a name="7" href="#7">#7</a></div>

```python
%%HTML
<script src="http://www.numericjs.com/lib/numeric-1.2.6.min.js"></script>
```




<script src="http://www.numericjs.com/lib/numeric-1.2.6.min.js"></script>





<div class="execution_count"><a name="8" href="#8">#8</a></div>

```javascript
var argmax = function(arr) { return arr.indexOf(Math.max.apply(null, arr)); }

function predict_cuisine(ingredient_string) {
    var x = numeric.rep([20],0)
    ingredient_string.split( /,\s*/ ).forEach(function(s) {
        var index = window.ingredients.indexOf(s);
        if (index != -1) {
            numeric.addeq(x, window.coef[ index ]);
        }
    });
    if (numeric.all(numeric.eq(0, x))) {
        return '';
    } else {
        return window.cuisines[argmax(x)];
    }
}
var ingredient_list = $('<input size="100">')
var recipe_prediction = $('<h1>')

ingredient_list.keydown( function(){
    recipe_prediction.text( predict_cuisine(this.value) );
});

element.append('<h1>Cuisine Predicter</h1>')
element.append('<div>Type a comma-separated list of ingredients:</div>')
element.append(ingredient_list)
element.append(recipe_prediction)
```




<p id="js-output-8"></p>
<script type="text/javascript" id="js-8">
element = $("#js-output-8");
</script>
<script src="/resources/whatscooking_files/whatscooking_14_0.js"></script>


