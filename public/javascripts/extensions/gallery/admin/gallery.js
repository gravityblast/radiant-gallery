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
	    '/admin/galleries/' + this.id + '/children/',
	    {
	      method: 'GET',
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
	
	initialize: function(element, options) {
	  this.element = $(element);
		this.options = arguments[0] || {};
		this.items = {};
		this.setup();
	},
	
	setup: function() {  	  
	  this.element.select('tr.node').each(function(element) {
	    var id = element.id.match(/^gallery\-row\-(\d+)/)[1];
	    this.createItem(id, null)
	  }.bind(this));
	},
	
	createItem: function(id, parent_id) {
		var item = new GalleryTreeItem(id, this.options);
		this.items[id] = item;
		if(parent_id) {
			this.items[parent_id].appendChild(item);
		}
	}
};

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
		if(GalleryItemsPanel.instance) {
		  GalleryItemsPanel.instance.lightwindow._getPageDimensions();
		  $('lightwindow_overlay').setStyle({
		    height: GalleryItemsPanel.instance.lightwindow.pageDimensions.height+'px'
		  });
		}
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

var GalleryItem = Class.create({
  initialize: function(element, panel) {
    this.element = element;
    this.panel = panel;
    this.selected = false;
    this.setup();    
  },
  
  setup: function() {
    this.setupButtons();
    // this.element.observe('click', this.handleSelection.bind(this));
  },
  
  handleSelection: function(event) {
    event.stop();
    this.panel.selectItem(this, event)
  },
  
  select: function() {
    this.element.addClassName('selected');
    this.selected = true;
  },
  
  deselect: function() {
    this.element.removeClassName('selected');
    this.selected = false;
  },
  
  setupButtons: function() {
    this.setupDeleteButton();
  },
  
  setupDeleteButton: function() {
    this.delete_button = this.element.down('div.buttons a.delete_button');
    this.delete_button.removeAttribute('onclick');
    this.delete_button.observe('click', this.handleDeleteButton.bind(this));
  },
  
  handleDeleteButton: function(event) {
    event.stop();
    if (confirm('Do you want to delete selected file?')) {
      var url = this.delete_button.getAttribute('href');
      new Ajax.Request(url, {
        method: 'delete',
        parameters: {
          authenticity_token: encodeURIComponent($('authenticity_token').value)
        },
        onLoading: function(request) {
          var img = event.element();
          img.setAttribute('src', '/images/admin/spinner.gif');
          this.panel.sortable.remove(img.up('div.item'));
        }.bind(this)
      });
    }
  }
});

var GalleryItemsPanel = Class.create({
  initialize: function(element) {
    this.element    = $(element);
    this.list_panel = this.element.down('div.items');
		this.gallery_id = this.list_panel.id;
    this.loadItems();
    this.selectedItems = new Array();
    this.working = false;
    this.setup();
  },      
  
  setup: function() {
    // this.element.observe('mousedown', this.handleClick.bind(this));
  },

  handleClick: function(event) {
    this.deselectAllElements();
  },
  
  deselectAllElements: function() {
    this.selectedItems.each(function(item) {
      item.deselect();        
    });
    this.selectedItems = new Array();
  },
  
  selectItem: function(item, event) {
    if(this.selectedItems.indexOf(item) < 0) {
      if(!event.shiftKey) this.deselectAllElements();       
      this.selectedItems.push(item);
      item.select();
    }
  },
  
  loadItems: function() {
    new Ajax.Updater(this.list_panel, '/admin/galleries/' + this.gallery_id + '/items/', {
      method: 'GET',
      onLoading: function() {
        this.working = true;
        this.element.down('div.loading').show();
      }.bind(this),
      onComplete: function() {        
        this.working = false;
        this.element.down('div.loading').hide();        
        this.setupSortable();
        this.setupItems();
        this.lightwindow = new lightwindow();
      }.bind(this)
    });
  }, 
  
  reloadItems: function() {
    // FIXME
    this.loadItems();
  },
  
  loadItem: function(id) {
    new Ajax.Updater(this.list_panel, '/admin/galleries/' + this.gallery_id + '/items/' + id, {
      method: 'GET',
      insertion: 'bottom',
      onLoading: function() {
        this.working = true;
        this.element.down('div.loading').show();
      }.bind(this),
      onComplete: function(r) {
        this.working = false;
        this.element.down('div.loading').hide();
        this.setupSortable();
        var item = $('item_' + id);
        item.select('a.lightwindow').each(function(link) {
          this.lightwindow._processLink(link);
        }.bind(this));
        this.setupItem(item);
      }.bind(this)
    });
  },
  
  setupItems: function() {    
    this.element.select('div.item').each(function(element) {
      this.setupItem(element)
    }.bind(this));    
  },
  
  setupItem: function(element) {
    new GalleryItem(element, this);
  },
  
  setupSortable: function() {
    this.sortable = new LiteSortable(this.list_panel, {
			overlap: 'horizontal',
			constraint: 'horizontal',
			handle: 'image',
			tag: 'div',
			only: 'item',
      onUpdate: this.sort.bind(this)
		});
  },
  
  removeItem: function(id) {
    var e = $('item_' + id);
		if(e) {
	    Effect.Puff(e, {
				afterFinish: function() {
					e.remove();
				}.bind(this)
			});			
		}
  },
  
  sort: function(list, element, id, old_position, new_position) {
		new Effect.Highlight(element, {duration:  0.5})
		new Ajax.Request('/admin/galleries/' + this.gallery_id + '/items/' + id + '/move' , {
		  method: 'PUT',
			parameters: {
				id: id,
				old_position: old_position,
				new_position: new_position,
				authenticity_token: encodeURIComponent($('authenticity_token').value)
			}
		});
	}
});              

var Gallery = {};
Gallery.openPopup = function(url, name) {
  var width = 500;
  var height = 500;
  var left = window.innerWidth / 2 - width / 2;
  var top  = window.innerHeight / 2 - height / 2;
  window.open(url, name, 'left=' + left + ',top=' + top + ',width=' + width + ',height=' + height + ',resizable=yes,scrollbars=yes');
}

GalleryZoomSlider.init  = function() { new GalleryZoomSlider('handle', 'track', 'gallery_items_panel'); }
GalleryItemsPanel.init  = function() {   
  Event.stopObserving(window, 'load', lightwindowInit, false);
  GalleryItemsPanel.instance = new GalleryItemsPanel('gallery_items_panel');
}
GalleryTree.init        = function() { GalleryTree.instance       = new GalleryTree('gallery_tree'); }

document.observe('dom:loaded', function() {
	when('gallery_items_panel_zoom',  GalleryZoomSlider.init);
	when('gallery_items_panel',       GalleryItemsPanel.init);
	when('gallery_tree',              GalleryTree.init);
});