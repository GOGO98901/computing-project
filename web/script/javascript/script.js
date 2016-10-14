$(document).ready(function() {

});
$(window).bind('scroll', function () {
	if ($(window).scrollTop() > 24) {
		$('#navigation').addClass('fixed');
		$('div.content').addClass('offset');
	} else {
		$('#navigation').removeClass('fixed');
		$('div.content').removeClass('offset');
	}
});
