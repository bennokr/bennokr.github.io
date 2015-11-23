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