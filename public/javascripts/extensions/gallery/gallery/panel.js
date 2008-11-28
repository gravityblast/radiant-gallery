if (!Gallery) var Gallery = {};

Gallery.Panel = Class.create({
  initialize: function(element, itemListSelector) {        
    this.element = $(element);
    this.setup(itemListSelector);
    this.setupHandlers();
    this.loadItems();
  },    
  
  setup: function(itemListSelector) {
    this.container = this.element.down(itemListSelector);
    this.gallery_id = this.container.getAttribute('id');
    this.authenticity_token = $('authenticity_token').value;
  },
  
  setupHandlers: function() {
    this.element.observe('click', this.handleClick.bind(this));
  },
  
  reloadItems: function() {
    // FIXME
    this.loadItems();
  },
  
  loadItems: function() {
    new Ajax.Updater(this.container, '/admin/galleries/' + this.gallery_id + '/items/', {
      method: 'get',
      onLoading: this.handleLoading.bind(this),
      onComplete: this.handleLoaded.bind(this)
    });
  },
  
  loadItem: function(id) {
    new Ajax.Updater(this.container, '/admin/galleries/' + this.gallery_id + '/items/' + id, {
      method: 'get',
      insertion: 'bottom',
      onLoading: this.handleLoading.bind(this),
      onComplete: this.handleLoaded.bind(this)
    });
  },
  
  handleClick: function(event) {    
    var link = event.findElement('a.action');
    if (link) {
      event.stop();
      this.hadleItemAction(link);      
    }
  },
  
  hadleItemAction: function(link) {
    if (link.hasClassName('destroy')) {
      this.destroyItem(link);
    } else if (link.hasClassName('edit')) {
      this.editItem(link);
    }
  },
  
  destroyItem: function(link) {
    var item = link.up('.item');
    if (confirm('Do you want to delete selected file?')) {
      new Ajax.Request(link.getAttribute('href'), {
        method: 'delete',
        parameters: { authenticity_token: encodeURIComponent(this.authenticity_token) },
        onLoading: function(request) { item.remove(); }
      });
    }
  },
  
  editItem: function(link) {    
    Gallery.EditForm.open(link);
  },
  
  handleLoading: function() {
    this.working = true;
    this.element.down('div.loading').show();
  },
  
  handleLoaded: function() {
    this.working = false;
    this.element.down('div.loading').hide();
    this.makeListSortable();
  },
  
  makeListSortable: function() {    
    if (this.sortable) Sortable.destroy(this.container);
    this.sortable = new LiteSortable(this.container, {
			overlap: 'horizontal', constraint: 'horizontal', handle: 'image', 
			tag: 'div', only: 'item', onUpdate: this.sort.bind(this)
		});
  },
  
  sort: function(list, element, id, old_position, new_position) {
		new Effect.Highlight(element, {duration:  0.5})
		new Ajax.Request('/admin/galleries/' + this.gallery_id + '/items/' + id + '/move' , {
		  method: 'put',
			parameters: {
				id: id, old_position: old_position, new_position: new_position,
				authenticity_token: encodeURIComponent(this.authenticity_token)
			}
		});
	}
  
});

document.observe('dom:loaded', function() {
  Gallery.panel = new Gallery.Panel('gallery_items_panel', '.items');
});