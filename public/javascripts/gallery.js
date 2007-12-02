var GallerySortableList = {

	dragged: null,   
	
  create: function(element, url) {
		Sortable.create(element, {
			overlap:'horizontal',
			constraint:'horizontal',
			handle: 'image',
			tag: 'div',
			only: 'item',
			onUpdate:function(){
				if(GallerySortableList.dragged) {
					new Effect.Highlight(GallerySortableList.dragged, {duration:  0.5})
				}
				GallerySortableList.dragged = null;
				new Ajax.Request(url, {asynchronous:true, evalScripts:true, parameters:Sortable.serialize(element)});
			},			
			onChange: function(element) {
				GallerySortableList.dragged = element;
			}
		});
	}
	
};
    

var GalleryImporter = Class.create();
GalleryImporter.prototype = {
	initialize: function() {
		this.options = arguments[0] || {};
		this.files = new Array();		
		this.index = -1;
		GalleryImporter.instance = this;
	},
	
	add: function(path, id) {
		this.files.push({
			path: path,
			id: id 
		});
	},
	
	start: function() {  
		this.import_next();
	},
	
	import_next: function() {
		this.index++;
		if(this.index < this.files.length && this.options.url) {
			this.updateLog("Importing " + (this.index + 1) + " of " + this.files.length + " files...");
			new Ajax.Request(
		    this.options.url + '/' + this.options.gallery_id + '?path=' + this.files[this.index].path,
		    {
		      asynchronous: true,
					evalScripts: true,
					onLoading: function(request) {
	          Element.show($('file-busy-' + this.files[this.index].id)); 					
	        }.bind(this),
	        onComplete: function(request) {
	          Element.hide($('file-item-' + this.files[this.index].id));						
						if(this.index + 1 < this.files.length) {
							this.updateLog("<b>OK</b>", true);
						} else {
							this.updateLog("All files have been imported.");
							Element.hide('import_button');
						}
	        }.bind(this)
				}
		  );
		}
	},
	
	next: function() {
		window.setTimeout(this.import_next.bind(this), 500);
	},
	
	updateLog: function(message, extend) {
		if(this.options.log) {
			if(extend) {
				message = $(this.options.log).innerHTML + message;
			}
			$(this.options.log).innerHTML = message;
		}
	}
	
}


var GalleryTreeItem = Class.create();
GalleryTreeItem.prototype = { 	
	
	initialize: function(id, options) {		
		this.id = id;
		this.options = arguments[1] || {};				
		this.expanded = false;
		this.has_children = false;
		this.children = new Array();
		this.loaded = false;
		this.updating = false;
		this.setup();
	},
	
	setup: function() { 		
		this.row = $('gallery-row-' + this.id);
		this.expander = $('gallery-expander-' + this.id);
		this.busy = $('gallery-busy-' + this.id);
		this.level = this.extractLevel(this.row);
		if(this.expander) {
			this.has_children = true;
			Event.observe(this.expander, 'click', this.toggle.bind(this));
		}		
	},
	
	extractLevel: function(row) {
		if (/level-(\d+)/i.test(row.className))
      return RegExp.$1.toInteger();		
	},
	
	expand: function() {
		this.expander.src = this.expander.src.replace(/expand/, 'collapse');
		if(!this.loaded) {
			this.loadChildren();
		} else {
			this.expandChildren(this);
		}
		this.expanded = true;
	},
	
	collapse: function() {
		this.expander.src = this.expander.src.replace(/collapse/, 'expand');
		this.collapseChildren(this);		
		this.expanded = false;
	},
	
	collapseChildren: function(item) {
		item.children.each(function(child) {
			Element.hide(child.row);
			if(child.has_children) {
				this.collapseChildren(child);
			}
		}.bind(this));		
	},
	
	expandChildren: function(item) {
		item.children.each(function(child) {
			Element.show(child.row);
			if(child.expanded) {
				this.expandChildren(child);
			}
		}.bind(this));		
	},
	
	toggle: function() {
		if(this.updating) return;
		if(!this.expanded) {			
			this.expand();
		} else {			
			this.collapse();
		}
	},
	
	appendChild: function(item) {
		this.children.push(item);
	},
	
	loadChildren: function(id, expander) {
		new Ajax.Updater(
	    this.row,
	    this.options.url + '/' + this.id,
	    {
	      asynchronous: true,
	      insertion: Insertion.After,
				evalScripts: true,
				onLoading: function(request) {
          Element.show(this.busy);
					this.updating = true;										
        }.bind(this),
        onComplete: function(request) {
					this.loaded = true;
					this.updating = false;
          Effect.Fade(this.busy);
        }.bind(this)
			}
	  );
	}
};

var GalleryTree = Class.create();
GalleryTree.prototype = {
	
	initialize: function(options) {
		this.options = arguments[0] || {};
		this.items = {};
	},
	
	createItem: function(id, parent_id) {
		var item = new GalleryTreeItem(id, this.options);
		this.items[id] = item;
		if(parent_id) {
			this.items[parent_id].appendChild(item);
		}
	}
};   
   

var Gallery = {
	
	toggle_by_upload_and_by_url: function() {
    ['by-upload', 'by-url', 'open-by-upload', 'open-by-url'].each(function(id) {
      Element.toggle(id);
    });  
  }
	
};

var GalleryItems = {
	
	set_name: function(item_id, name) {
		var element = $('item_' + item_id + '_name');
		if(element) {
		  element.innerHTML = name;
		}
		var view_title = $('item_' + item_id + '_view_title')
		if(view_title) {
		  view_title.title = name;
		}
	},
	
	set_description: function(item_id, description) {
		var element = $('item_' + item_id + '_description');
		if(element) {
		  element.innerHTML = description;
		}
	},
	
	delete_if_confirm: function (item_id, delete_url) {
    if (confirm('Do you want to delete selected file?')) {
      new Ajax.Request(delete_url,
        {
          evalScripts: true,
					onLoading: function(request) {
						$('item_delete_' + item_id).src = '/images/admin/spinner.gif';
					}
        }
      );
    }
  },

	remove: function(id) {
    var e = $('item_' + id);
		if(e) {
	    Effect.Puff(e, {
				afterFinish: function() {
					e.remove();
				}
			});			
		}    
  },

	zoomIn: function() {
		GalleryItems.scale(1.2);
	}, 
	
	zoomOut: function() {
		GalleryItems.scale(0.8);
	},
	
	scale: function(percent) {
		$('list').getElementsBySelector('div[class=image]').each(function(item) {
			[item, item.down()].each(function(e) {
				var w = parseFloat(e.getStyle('width'));
			  var h = parseFloat(e.getStyle('height'));
			  e.setStyle({width: w * percent + 'px', height: h * percent + 'px'});
			});		  
		})
	}

};



var GalleryItemPopup = {		
	
	id: 'update-item-popup',
	
	saved: true,
	
	opened: false,
	
	open: function(item_id) {
		if(GalleryItemPopup.opened) {
			return;			
		}
		GalleryItemPopup.reset();
		var hidden_field = $(GalleryItemPopup.id + '-id-field');
		hidden_field.value = item_id;
		var popup_name_field = $(GalleryItemPopup.id + '-name-field');
		var popup_description_field = $(GalleryItemPopup.id + '-description-field');		
		var name_field = $('item_' + item_id + '_name')
		var description_field = $('item_' + item_id + '_description')
		var name = name_field.innerHTML;
		var description = description_field.innerHTML;
		popup_name_field.value = name;
		popup_description_field.value = description;
		var popup = $(GalleryItemPopup.id);
    GalleryItemPopup.center(popup);
    Element.show($(GalleryItemPopup.id));
    Field.focus(popup_name_field);
		$(GalleryItemPopup.id + '-save-button').disabled = true;
		GalleryItemPopup.observe(true);
		GalleryItemPopup.opened = true;
  },

	reset: function() {
		GalleryItemPopup.saved = true;		
		GalleryItemPopup.reset_button();
	},
	
	reset_button: function() {
		$(GalleryItemPopup.id + '-save-button').disabled = true;
		$(GalleryItemPopup.id + '-save-button').value = 'Save';
	},

	onStartEdit: function(event) {
		if(event.keyCode == 13) return;				
		GalleryItemPopup.saved = false;
		$(GalleryItemPopup.id + '-save-button').disabled = false;
		GalleryItemPopup.observe(false);
	},
	
	observe: function(observe) {
		var elements = [$(GalleryItemPopup.id + '-name-field'), $(GalleryItemPopup.id + '-description-field')];
		if(observe) {
			elements.each(function(element) {
				Event.observe(element, 'keydown', GalleryItemPopup.onStartEdit);
			});
		} else {
			elements.each(function(element) {
				Event.stopObserving(element, 'keydown', GalleryItemPopup.onStartEdit);
			});
		}
	}, 

	center: function(element) {
    var header = $('header');
    var element = $(element);
    element.style.position = 'fixed'
    var dim = Element.getDimensions(element)
    element.style.top = '100px';
    element.style.left = ((header.offsetWidth - dim.width) / 2) + 'px';
  },
	
	closeWithConfirmation: function() {
		if(!GalleryItemPopup.saved) {
			if(!confirm("Do you want to close without save?")) {
				return false;
			}						
		}
		GalleryItemPopup.close();
		return true;
	},
	
	close: function(confirmation) {
		Element.hide($(GalleryItemPopup.id));
		GalleryItemPopup.opened = false;
	}
		
};


var GalleryZoomSlider = Class.create({
	
	initialize: function(handle, track) {
		this.handle = handle;
		this.track = track;
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
	  Element.setContentZoom('list', 200 * this.value + 100);
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
	new GalleryZoomSlider('handle', 'track');
	GallerySortableList.create('list', '/admin/gallery_item/sort')
});