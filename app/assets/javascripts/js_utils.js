(function() {
  if (typeof String.prototype.startsWith !== 'function') {
    String.prototype.startsWith = function(str) {
      return this.slice(0, str.length) === str;
    };
  }

  if (typeof String.prototype.endsWith !== 'function') {
    String.prototype.endsWith = function(str) {
      return this.slice(-str.length) === str;
    };
  }

  if (typeof String.prototype.addCommas !== 'function') {
    String.prototype.addCommas = function() {
      var rgx, str, x, x1, x2;
      str = this;
      str += '';
      x = str.split('.');
      x1 = x[0];
      x2 = x.length > 1 ? '.' + x[1] : '';
      rgx = /(\d+)(\d{3})/;
      while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
      }
      return x1 + x2;
    };
  }

  if (typeof String.prototype.lpad !== 'function') {
    String.prototype.lpad = function(padString, length) {
      var str;
      str = this;
      while (str.length < length) {
        str = padString + str;
      }
      return str;
    };
  }

  if (typeof String.prototype.rpad !== 'function') {
    String.prototype.rpad = function(padString, length) {
      var str;
      str = this;
      while (str.length < length) {
        str = str + padString;
      }
      return str;
    };
  }

  if (typeof String.prototype.trim !== 'function') {
    String.prototype.trim = function() {
      return this.replace(/^\s+|\s+$/g, '');
    };
  }

}).call(this);
