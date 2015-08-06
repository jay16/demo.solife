(function() {
  var app;

  app = angular.module('solife', []);

  app.controller('DemoNxscaeController', function($scope, $http) {
    var listType;
    listType = "all";
    if ($.inArray('simple', App.params('key')) >= 0) {
      listType = "simple";
    }
    $http.get('/demo/nxscae/list?list=' + listType).success(function(result) {
      $scope.products = result.array;
      $scope.orderCurPrice = "cur_price";
      return $http.get('/demo/nxscae/focus').success(function(result) {
        var focus;
        focus = result.array;
        return $('.fullname').each(function() {
          var index;
          if (!focus.length) {
            return;
          }
          index = $.inArray($(this).html(), focus);
          if (index >= 0) {
            $(this).parent('tr').addClass('success');
            return focus.slice(index, 1);
          }
        });
      });
    });
    return $scope.trendChart = function(code) {
      return $http.get('/demo/nxscae/' + code + '/data').success(function(result) {
        var options;
        options = {
          'title': {
            'text': '趋势图表'
          },
          'legend': {
            'layout': 'horizontal',
            'align': 'right',
            'verticalAlign': 'top',
            'borderWidth': 0
          },
          'xAxis': {
            'categories': []
          },
          'yAxis': [
            {
              'title': {
                'text': '最新价格',
                'margin': 0
              }
            }, {
              'title': {
                'text': '涨跌幅',
                'margin': 0
              },
              'opposite': true
            }
          ],
          'tooltip': {
            'enabled': true
          },
          'credits': {
            'enabled': false
          },
          'plotOptions': {
            'areaspline': {}
          },
          'chart': {
            'defaultSeriesType': 'line',
            'renderTo': 'highchart_id'
          },
          'subtitle': {},
          'labels': {
            'items': [
              {
                'html': '',
                'style': {
                  'left': '20px',
                  'top': '8px',
                  'color': 'black'
                }
              }
            ]
          },
          'series': [
            {
              'type': 'spline',
              'yAxis': 0,
              'name': '最新价格',
              'data': []
            }, {
              'type': 'spline',
              'yAxis': 1,
              'name': '涨跌幅',
              'data': []
            }
          ]
        };
        options.title.text = result.fullname + ' - 趋势图';
        options.xAxis.categories = result.xAxis;
        options.series[0].data = result.yAxis1;
        options.series[1].data = result.yAxis2;
        return window.chart_highchart_id = new Highcharts.Chart(options);
      }).error(function() {
        return console.log('error');
      });
    };
  });

}).call(this);
