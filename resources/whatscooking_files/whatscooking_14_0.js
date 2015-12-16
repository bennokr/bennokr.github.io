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