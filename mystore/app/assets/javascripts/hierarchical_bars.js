/* Wimbledon 2012 - Player Bars */
/* Copyright 2013 Peter Cook (@prcweb); Licensed MIT */

var barHeight = 20, width = 500, numPlayers = 20, parameter = 'matchesWon';
var data = [], yScale = null;
var menu = [
  {id: 'matchesWon', name: 'Matches won'},
  {id: 'setsWon', name: 'Sets won'},
  {id: 'gamesWon', name: 'Games won'},
  {id: 'points', name: 'ATP Ranking'}
];

//// HELPER FUNCTIONS
function px(s) {
  return s + 'px';
}

function fullname(d) {
  var s = d.split(' ');
  return s.length === 3 ? s[2] + ' ' + s[0] + ' ' + s[1] : s[1] + ' ' + s[0];
}


//// DATA FUNCTIONS
function filterPlayers(d) {
  return _.filter(d, function(v) {return +v.matchesWon >= 2;});
}


//// UI
function menuClick(d) {
  if(parameter === d.id)
    return;

  d3.select('#menu').selectAll('div').classed('selected', false);
  d3.select(this).classed('selected', true);

  parameter = d.id;

  updateChart();
}


//// D3
function updateScale() {
  yScale = d3.scale.linear()
    .domain([0, d3.max(data, function(d) { return d[parameter]; })])
    .range([0, width]);  
}

function updateChart() {
  updateScale();

  d3.select('#chart')
    .selectAll('div.bar')
    .transition()
    .duration(1000)
    .style('width', function(d) {
      return px(yScale(d[parameter]));
    });

  d3.select('#chart')
    .selectAll('div.value')
    .transition()
    .duration(1000)
    .tween("text", function(d) {
      // Thanks to http://stackoverflow.com/questions/13454993/increment-svg-text-with-transistion
      var i = d3.interpolate(this.textContent, d[parameter]);
      return function(t) {
          this.textContent = Math.round(i(t));
      };
    });
}

d3.json('dashboard/playergrid.json', function(err, csv) {
  data = filterPlayers(csv);

  updateScale();

  var players = d3.select('#chart')
    .selectAll('div')
    .data(data)
    .enter()
    .append('div')
    .sort(function(a, b) {return d3.descending(a[parameter], b[parameter]);})
    .classed('player', true)
    .style('top', function(d, i) {
      return px(i * barHeight);
    });

  players.append('div')
    .classed('label', true)
    .text(function(d) {return fullname(d.name);});

  players.append('div')
    .classed('bar', true)
    .style('height', px(barHeight * 0.95))
    .style('width', function(d) {
      return px(yScale(d[parameter]));
    }); 

  players.append('div')
    .classed('value', true)
    .text(function(d) {return (d[parameter]);});

  // Menu
  d3.select('#menu')
    .selectAll('div')
    .data(menu)
    .enter()
    .append('div')
    .text(function(d) {return d.name;})
    .classed('selected', function(d, i) {return i==0;})
    .on('click', menuClick);
});