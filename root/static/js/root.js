function redirect2node() {
	if ($('#node').val()) {
		var url = '/node/' + $('#node').val();
		window.location.replace(url);
	}
}

!function( $ ){
	
	"use strict"
	
	/* DROPDOWN PLUGIN DEFINITION
	* ========================== */
	
	$.fn.dropdown = function ( selector ) {
		return this.each(function () {
			$(this).delegate(selector || d, 'click', function (e) {
				var li = $(this).parent('li')
				, isActive = li.hasClass('open')
				
				clearMenus()
				!isActive && li.toggleClass('open')
				return false
			})
		})
	}
	
	/* APPLY TO STANDARD DROPDOWN ELEMENTS
	* =================================== */
	
	var d = 'a.menu, .dropdown-toggle'
	
	function clearMenus() {
		$(d).parent('li').removeClass('open')
	}
	
	$(function () {
		$('html').bind("click", clearMenus)
		$('body').dropdown( '[data-dropdown] a.menu, [data-dropdown] .dropdown-toggle' )
	})
	
}( window.jQuery || window.ender );