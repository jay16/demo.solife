window.onerror = function(err) {
  log('window.onerror: ' + err)
}
window.Pretty = {
  output: function (inp) {
    document.body.appendChild(document.createElement('pre')).innerHTML = Pretty.syntaxHighlight(inp);
  },
  syntaxHighlight: function (json) {
      json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
      return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
          var cls = 'number';
          if (/^"/.test(match)) {
              if (/:$/.test(match)) {
                  cls = 'key';
              } else {
                  cls = 'string';
              }
          } else if (/true|false/.test(match)) {
              cls = 'boolean';
          } else if (/null/.test(match)) {
              cls = 'null';
          }
          return '<span class="' + cls + '">' + match + '</span>';
      });
  }
}
window.IOSBridge = {
  log: function(message, data) {
    var log = document.getElementById('log')
    var el = document.createElement('div')
    el.className = 'logLine'
    el.innerHTML = new Date().toTimeString() + " - " + message + ':<br/><pre>' + Pretty.syntaxHighlight(JSON.stringify(data, undefined, 4)) + '</pre>';
    if (log.children.length) { 
      log.insertBefore(el, log.children[0]) 
    }
    else { 
      log.appendChild(el) 
    }
  },

  connectWebViewJavascriptBridge: function(callback) {
    if (window.WebViewJavascriptBridge) {
      callback(WebViewJavascriptBridge)
    } else {
      document.addEventListener('WebViewJavascriptBridgeReady', function() {
        callback(WebViewJavascriptBridge)
      }, false)
    }
  },

  listDemos: function(bridge) {
    bridge.callHandler('iosCallback', {'action': 'demo-list'}, function(response) {
        var tbody = document.getElementById("demoList")
        tbody.innerHTML = ""
        
        for(var i = 0; i < response.datalist.length; i++) {
          var data = response.datalist[i]
          var tr = document.createElement("tr")
          if(data.isLocal === "1") {
            tr.innerHTML = "<td>" + data.filename + "</td><td>"+data.filesize+"</td><td><a class='btn btn-xs btn-danger' onclick='IOSBridge.removeDemo(\"" + data.filename+"\",\"" + data.filepath + "\",\"" + data.filesize+"\");'>remove<a></td><td><a class='btn btn-xs btn-info' onclick='IOSBridge.viewDemo(\""+data.filepath+"\");'>view</a></td>"
          }
          else {
            tr.innerHTML = "<td>" + data.filename + "</td><td>"+data.filesize+"</td><td><a class='btn btn-xs btn-primary' onclick='IOSBridge.downloadDemo(\"" + data.filepath+"\");'>download<a></td><td>-</td>"
          }
          tbody.insertBefore(tr, tbody.appendChild[0])
        }
    })
    bridge.callHandler('iosCallback', {'action': 'local-logs'}, function(response) {
        var log = document.getElementById('log')
        while (log.hasChildNodes()) {
            log.removeChild(log.lastChild);
        }
        for(var i = 0; i < response.logs.length; i++) {
          var log = response.logs[i]
          IOSBridge.log("", log)
        }
    })
  },

  downloadDemo: function(link) {
    IOSBridge.connectWebViewJavascriptBridge(function(bridge) {
      bridge.callHandler('iosCallback', {'action': 'download-demo', 'link': link}, function(response) {
        IOSBridge.listDemos(bridge)
      })
    })
  },

  removeDemo: function(filename, filepath, filesize) {
    if(confirm("are sure remove "+filename+"("+filesize+")?")) {
      IOSBridge.connectWebViewJavascriptBridge(function(bridge) {
        bridge.callHandler('iosCallback', {'action': 'remove-demo', 'filepath': filepath}, function(response) {
          IOSBridge.listDemos(bridge)
        })
      })
    }
  },
  viewDemo: function(filepath) {
    IOSBridge.connectWebViewJavascriptBridge(function(bridge) {
      bridge.callHandler('iosCallback', {'action': 'view-demo', 'filepath': filepath}, function(response) {
      })
    })
  },
  cleanLog: function() {
      var log = document.getElementById('log')
      while (log.hasChildNodes()) {
          log.removeChild(log.lastChild);
      }
  }
}

IOSBridge.connectWebViewJavascriptBridge(function(bridge) {

  bridge.init(function(message, responseCallback) {
    IOSBridge.log('JS got a message', message)
    var data = { 'Javascript Responds':'Wee!' }
    IOSBridge.log('JS responding with', data)
    responseCallback(data)
  })

  bridge.registerHandler('testJavascriptHandler', function(data, responseCallback) {
    IOSBridge.log('ObjC called testJavascriptHandler with', data)
    alert(data)
    var responseData = { 'Javascript Says':'Right back atcha!' }
    IOSBridge.log('JS responding with', responseData)
    responseCallback(responseData)
  })


  var refreshBtn = document.getElementById('refresh');
  refreshBtn.onclick = function(e) {
    e.preventDefault();
    bridge.callHandler('iosCallback', {'action': 'refresh'}, function(response) {
      IOSBridge.log('JS got response', response);
    });
  }

  var pageSetting = document.getElementById('pageSetting');
  if(pageSetting !== null) {
      IOSBridge.listDemos(bridge)
  }
})