/*global window,console, webkitAudioContext */
var context;
function init() {
  try {
    context = new webkitAudioContext();
  }
  catch(e) {
    console.log('Web Audio API is not supported in this browser');
  }
}

window.addEventListener('load', init, false);
