var GalleryZoomSlider = Class.create({
	
	initialize: function(handle, track, panel) {
		this.handle = handle;
		this.track  = track;
		this.panel  = panel;
		this.setup();
		this.readZoomCookie();
	},
	
	setup: function() {
		this.slider = new Control.Slider(this.handle, this.track, {
	    onChange: this.onChange.bind(this),
	    onSlide: 	this.onSlide.bind(this)
	  });
	},
	
	onChange: function(value) {		
		this.value = value;
		this.saveZoomCookie();
		this.zoom();		
	},
	
	onSlide: function(value) {
		this.value = value;
		this.zoom();
	},
	
	zoom: function(perc) {
	  Element.setContentZoom(this.panel, 200 * this.value + 100);
	},
	
	readZoomCookie: function() {
    var matches = document.cookie.match(/gallery_zoom=(.+?);/);
    this.value = matches ? matches[1] : 0;
		this.slider.setValue(this.value);
  },

	saveZoomCookie: function() {
		document.cookie = "gallery_zoom=" + this.value + "; path=/admin";
	}	
	
});

document.observe('dom:loaded', function() {
  new GalleryZoomSlider('handle', 'track', 'gallery_items_panel');
});
