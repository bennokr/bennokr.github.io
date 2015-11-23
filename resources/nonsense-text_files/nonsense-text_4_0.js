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