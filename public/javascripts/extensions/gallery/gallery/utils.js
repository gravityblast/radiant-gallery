if (!Gallery) var Gallery = {};

Gallery.openPopup = function(url, name) {
  var width = 500;
  var height = 500;
  var left = window.innerWidth / 2 - width / 2;
  var top  = window.innerHeight / 2 - height / 2;
  window.open(url, name, 'left=' + left + ',top=' + top + ',width=' + width + ',height=' + height + ',resizable=yes,scrollbars=yes');
}