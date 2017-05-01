(function( $ ){
	
	// globals
	var mobileWidth = 300; 
	var tabletWidth = 716;
	var duration = 300; // duration of animation (time)
	var delay = duration - 50; // delay between animations
	
	// helper functions
	function hideListItems(filterClass, galleryObj){
		
		var marginHeight = parseInt(galleryObj.listItems[0].css('marginTop'));
		var itemHeight = galleryObj.listItems[0].height( );
		var ulListHeight = 0;
		var numItemsToShow = 0;
		var columns = 3;
		
		if(galleryObj.wrapperWidth <= mobileWidth){
			columns = 2;
		}
		
		for(var i=0; i < galleryObj.listSize; i++){
			galleryObj.listItems[i].removeClass('is-visible');
			galleryObj.listItems[i].fadeOut(duration, "easeOutQuart");
			
			if(galleryObj.listItems[i].hasClass(filterClass) || filterClass == 'all'){
				numItemsToShow++;
			}
		}
		
		ulListHeight = Math.ceil(numItemsToShow / columns) * (itemHeight + marginHeight);
		
		galleryObj.ulList.animate({height: ulListHeight .toString()+'px'}, duration, "easeOutQuart");
		
		setTimeout(function( ) { showObj(filterClass, galleryObj); }, 500);
	}
	
	function showObj(filterClass, galleryObj){

		if(galleryObj.counter < galleryObj.listSize){
			
			if(galleryObj.listItems[galleryObj.counter].hasClass(filterClass) || filterClass == 'all'){
				galleryObj.listItems[galleryObj.counter].addClass('is-visible');
				galleryObj.listItems[galleryObj.counter].show(duration, "easeOutQuart"); 
					setTimeout(function( ) {
						galleryObj.counter++;
						showObj(filterClass, galleryObj);
					}, delay );
			}else{
				galleryObj.counter++;
				showObj(filterClass, galleryObj);
			}		
		}else{
			galleryObj.counter = 0;
			galleryObj.isAnimating = false;
		}
	}
		
	var methods = {
		init : function( ) { 
			return this.each(function(i){
				
				var wrapper = $(this); // gallery wrapper
				
				if(wrapper.data('initialized') === undefined)
				{	
					wrapper.data('initialized', true);
					
					var filterClass = '';
					var listItemMargin = 0;
					var listItemWidth = 0;
					var numCols = 0;
					var margins = 0;
					var ulWidth = 0;
					var listMargin = 0;
					var currentItemClass = 'tf-current-menu-item';
					var galleryData = {};
					
					galleryData.wrapperWidth = wrapper.width( );
					galleryData.ulList = wrapper.find('ul.tf-gallery-list');
					galleryData.listItems = [];
					// populate galleryData.ulMenuItems
					galleryData.ulList.find('li.tf-gallery-list-item').each(function( ) { galleryData.listItems.push($(this).addClass('is-visible')) });
					galleryData.listSize = galleryData.listItems.length;
					galleryData.ulMenu = wrapper.find('ul.tf-filter-menu');
					galleryData.menuItems = [];
					// populate galleryData.ulMenuItems
					galleryData.ulMenu.find('li.tf-filter-menu-item').each(function( ) { galleryData.menuItems.push($(this)) });
					galleryData.menuSize = galleryData.menuItems.length;
					galleryData.lastClickedMenuItem = galleryData.menuItems[0];
					galleryData.lastClickedMenuItem.addClass(currentItemClass);
					galleryData.counter = 0;
					galleryData.isAnimating = false;
			
					// apply class based on device
					if(galleryData.wrapperWidth <= mobileWidth){
						galleryData.ulList.addClass('tf-gallery-mobile-size');
					}else if(galleryData.wrapperWidth <= tabletWidth){
						galleryData.ulList.addClass('tf-gallery-tablet-size');
					}
					
					// calc dimensions
					listItemMargin = parseInt(galleryData.listItems[0].css('marginLeft'));
					listItemWidth = galleryData.listItems[0].width( );
					numCols = Math.floor(galleryData.wrapperWidth / listItemWidth);
					margins = numCols * listItemMargin;
					ulWidth = numCols * listItemWidth + margins;
					listMargin = Math.floor((galleryData.wrapperWidth - ulWidth - listItemMargin) / 2);
					
					galleryData.ulList.css({'width' : ulWidth, 'margin-left' : listMargin, 'margin-top' : -listItemMargin});
					
					wrapper.data('galleryData', galleryData);
					
					for(var i=0; i < galleryData.menuSize; i++){
						galleryData.menuItems[i].click(function( ){
							var galleryObj = wrapper.data('galleryData');
							if(!galleryObj.isAnimating){
								galleryObj.isAnimating = true;
								galleryObj.lastClickedMenuItem.removeClass(currentItemClass);
								galleryObj.lastClickedMenuItem = $(this);
								filterClass = $(this).find('a').attr("class");
								$(this).addClass(currentItemClass);
								hideListItems(filterClass, galleryObj);
							}
						});
					}
					
				}
			});
		},
		refresh : function( ) {
			return this.each(function(){
				
				var wrapper = $(this); // slideshow wrapper
				
				if(wrapper.data('initialized') !== undefined)
				{
					var galleryObj = wrapper.data('galleryData');
					var currentWrapperWidth = wrapper.width( );
					var listItemMargin = 0;
					var listItemWidth = 0;
					var numCols = 0;
					var margins = 0;
					var ulWidth = 0;
					var listMargin = 0;
					
					// prevent unnecessary resize
					if(currentWrapperWidth != galleryObj.wrapperWidth){
						galleryObj.wrapperWidth = currentWrapperWidth;
			
						// apply class based on device
						if(currentWrapperWidth <= mobileWidth){
							galleryObj.ulList.addClass('tf-gallery-mobile-size');
							galleryObj.ulList.removeClass('tf-gallery-tablet-size');
						}else if (currentWrapperWidth <= tabletWidth){
							galleryObj.ulList.removeClass('tf-gallery-mobile-size');
							galleryObj.ulList.addClass('tf-gallery-tablet-size');
						}else{
							galleryObj.ulList.removeClass('tf-gallery-tablet-size');
							galleryObj.ulList.removeClass('tf-gallery-mobile-size');
						}
						
						listItemMargin = parseInt(galleryObj.listItems[0].css('marginLeft'));
						listItemWidth = galleryObj.listItems[0].width( );
						numCols = Math.floor(currentWrapperWidth / listItemWidth);
						margins = numCols * listItemMargin;
						ulWidth = numCols * listItemWidth + margins;
						listMargin = Math.floor((currentWrapperWidth - ulWidth - listItemMargin) / 2);
						
						galleryObj.ulList.css({'width' : ulWidth, 'margin-left' : listMargin, 'margin-top' : -listItemMargin});
						
						if(wrapper.hasClass('tf-filter')){
							var marginHeight = parseInt(galleryObj.listItems[0].css('marginTop'));
							var itemHeight = galleryObj.listItems[0].height( );
							var ulListHeight = 0;
							var numItemsToShow = 0;
							var columns = 3;
		
							if(galleryObj.wrapperWidth <= mobileWidth){
								columns = 2;
							}
							
							for(var i=0; i < galleryObj.listSize; i++){
								if(galleryObj.listItems[i].hasClass('is-visible')){
									numItemsToShow++;
								}
							}
							
							ulListHeight = Math.ceil(numItemsToShow / columns) * (itemHeight + marginHeight);
							
							galleryObj.ulList.css({height: ulListHeight .toString()+'px'});
						}
					}
				}
			});
		}
	};

	$.fn.themefitgallery = function( method ) {
		if ( methods[method] ) {
		  return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
		} else if ( typeof method === 'object' || ! method ) {
		  return methods.init.apply( this, arguments );
		} else {
		  $.error( 'Method ' +  method + ' does not exist in themefitgallery' );
		} 
	};
	
})( jQuery );