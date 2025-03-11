// JavaScript code for the chart tooltip
function chart() {
  Highcharts.chart('container', {
    title: {
      text: title
    },
    xAxis: {
      type: 'linear',
      labels: {
        format: '{value}%'
      }
    },
    yAxis: {
      title: {
        text: ''
      },
      breaks: y,
      labels: {
        format: '{value}'
      }
    },
    series: [{
      type: 'rect',
      data: data.map(function(d) {
        return {
          xmin: d.ci_lower,
          xmax: d.ci_lower + 2 * d.ci,
          y: d.y,
          fill: d.color
        }
      }),
      fillOpacity: 0.5
    }, {
      type: 'line',
      data: data.map(function(d) {
        return {
          x: d.mean_diff,
          y: d.y
        }
      }),
      color: 'steelblue'
    }],
    plotOptions: {
      rect: {
        fillOpacity: 0.5
      }
    },
    legend: {
      enabled: false
    },
    credits: {
      enabled: false
    },
    exporting: {
      enabled: false
    }
  });
}
