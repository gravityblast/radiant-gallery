/* LiteSortable version 0.1.1
 * (c) 2007 Andrea Franz (http://gravityblast.com) 
 *
 * LiteSortable is freely distributable under the terms of an MIT-style license.
 */

var LiteSortable = Class.create({
	initialize: function(element) {		
		this.element = $(element);
		this.options = Object.extend({ 
      tag: 'li',
			format: Sortable.SERIALIZE_RULE
    }, arguments[1] || { });
		this.dragged = null;		
		this.adjustOptions();
		Sortable.create(this.element, this.options);
		this.updateOrder();
	},
		
 	updateOrder: function() {
		this.elements = new Array();
		Sortable.findElements(this.element, this.options).each(function(e) {
			this.elements.push(e.id);
		}.bind(this));		
	},
	
	adjustOptions: function() {
		this.options._onChange = this.options.onChange;
		this.options._onUpdate = this.options.onUpdate;
		this.options.onChange = this.onChange.bind(this);
		this.options.onUpdate = this.onUpdate.bind(this);
	},		
	
	onChange: function(element) {
		var position = this.getElementPosition(element);
		if(!this.dragged || element != this.dragged.element) {
			this.dragged = {
				element: element,
				old_position: this.elements.indexOf(element.id) + 1
			};
		}
		this.dragged.position = position;
		var id = element.id.match(this.options.format) ? element.id.match(this.options.format)[1] : '';
		if(this.options._onChange) this.options._onChange(element, id, this.dragged.old_position, this.dragged.position);
	},
	
	onUpdate: function(list) {
		var id = this.dragged.element.id.match(this.options.format) ? this.dragged.element.id.match(this.options.format)[1] : '';
		if(this.options._onUpdate) this.options._onUpdate(list, this.dragged.element, id, this.dragged.old_position, this.dragged.position);		
		this.dragged = null;		
		this.updateOrder();
	},
	
	getElementPosition: function(element) {
		var position = 1;
		var current_element = element;
		while(current_element = current_element.previous()) position++;
		return position;
	},
	
	remove: function(element) {
		this.elements.splice(this.elements.indexOf(element.id), 1);
	  if(this.dragged) this.dragged.old_position = this.elements.indexOf(this.dragged.element.id) + 1;
	}
	
});

LiteSortable.create = function(element) {
	new LiteSortable(element, arguments[1])
}