app = angular.module('solife', [])
app.controller 'DemoNxscaeController', ($scope, $http) ->
  listType = "all"
  listType = "simple" if $.inArray('simple', App.params('key')) >= 0

  $http.get('/demo/nxscae/list?list=' + listType).success (result) ->
    $scope.products = result.array
    $scope.orderCurPrice = "cur_price"

    $http.get('/demo/nxscae/focus').success (result) ->
      focus = result.array.reverse()
      console.log("[" + focus.join("],[") + "]")

      $('.fullname').each ->
        index = $.inArray($.trim($(this).html()), focus)
        if index >= 0
          $tr = $(this).parent('tr')
          $tr.addClass 'success'
          $firstTR = $("tbody tr:first")
          $tr.insertBefore($firstTR)
        else
          console.log("[" + $(this).html() + "]")

  $scope.trendChart = (code) ->
    $http.get('/demo/nxscae/' + code + '/data').success((result) ->
      options = 
        'title': 'text': '趋势图表'
        'legend':
          'layout': 'horizontal'
          'align': 'right'
          'verticalAlign': 'top'
          'borderWidth': 0
        'xAxis': 'categories': []
        'yAxis': [
          { 'title':
            'text': '最新价格'
            'margin': 0 }
          {
            'title':
              'text': '涨跌幅'
              'margin': 0
            'opposite': true
          }
        ]
        'tooltip': 'enabled': true
        'credits': 'enabled': false
        'plotOptions': 'areaspline': {}
        'chart':
          'defaultSeriesType': 'line'
          'renderTo': 'highchart_id'
        'subtitle': {}
        'labels': 'items': [ {
          'html': ''
          'style':
            'left': '20px'
            'top': '8px'
            'color': 'black'
        } ]
        'series': [
          {
            'type': 'spline'
            'yAxis': 0
            'name': '最新价格'
            'data': []
          }
          {
            'type': 'spline'
            'yAxis': 1
            'name': '涨跌幅'
            'data': []
          }
        ]
      options.title.text = result.fullname + ' - 趋势图'
      options.xAxis.categories = result.xAxis
      options.series[0].data = result.yAxis1
      options.series[1].data = result.yAxis2
      window.chart_highchart_id = new (Highcharts.Chart)(options)
    ).error ->
      console.log 'error'
