/* -*- Mode: Java; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/* vim: set shiftwidth=2 tabstop=2 autoindent cindent expandtab: */

//
// See README for overview
//

'use strict';

var parse_params = function() {
  var i, obj, pair, pairs;
  pairs = window.location.search.substring(1).split("&");
  obj = {};
  for (i in pairs) {
    if (pairs[i] === "") {
      continue;
    }
    pair = pairs[i].split("=");
    obj[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1]);
  }
  return obj;
};


console.log("================");
console.log(parse_params()["pdf"]);
console.log("================");
var pdfPath = parse_params()["pdf"];
if(pdfPath === undefined)
  pdfPath = "iSearch.pdf";

//
// Fetch the PDF document from the URL using promises
//
PDFJS.getDocument(pdfPath).then(function(pdf) {
  // Using promise to fetch the page
  pdf.getPage(1).then(function(page) {
    var scale = 1.5;
    var viewport = page.getViewport(scale);

    //
    // Prepare canvas using PDF page dimensions
    //
    var canvas = document.getElementById('the-canvas');
    var context = canvas.getContext('2d');
    canvas.height = viewport.height;
    canvas.width = viewport.width;

    //
    // Render PDF page into canvas context
    //
    var renderContext = {
      canvasContext: context,
      viewport: viewport
    };
    page.render(renderContext);
  });
});

