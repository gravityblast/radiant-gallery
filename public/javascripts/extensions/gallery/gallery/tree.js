if (!Gallery) var Gallery = {};

Gallery.TreeItem = Class.create({ 	
	
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
});


Gallery.Tree = Class.create({
	
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
		var item = new Gallery.TreeItem(id, this.options);
		this.items[id] = item;
		if(parent_id) {
			this.items[parent_id].appendChild(item);
		}
	}
});

document.observe('dom:loaded', function() {
  Gallery.tree = new Gallery.Tree('gallery_tree');
});