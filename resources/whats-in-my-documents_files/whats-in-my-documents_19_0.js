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