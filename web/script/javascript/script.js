/*
Copyright 2016 Rory Claasen

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
$(document).ready(function() {
	console.log(Cookies.get('database-ping'));
	pingDatabase();
});

function pingDatabaseForce() {
	Cookies.remove('database-ping');
	pingDatabase();
}
function pingDatabase() {
	if (Cookies.get('database-ping') == undefined || Cookies.get('database-ping') == 'false') {
		$('#server-ping').removeClass('green');
		$('#server-ping').removeClass('red');
		$('#server-ping').slideDown();
		setTimeout(function() {
			console.log("[JAVASCRIPT] Server ping sending, will be waking up from idle")
			Cookies.set('database-ping', 'sent', { expires: 1 });
			$.ajax({
				url: "http://database.roryclaasen.me/ping",
				dataType: "jsonp",
				statusCode: {
					200: function (response) {
						Cookies.set('database-ping', 'true', { expires: 1 });
						console.log("[JAVASCRIPT] Server pong received")
						$('#server-ping').addClass('green');
						setTimeout(function() {
							$('#server-ping').slideUp('slow');
						}, 1000);
					},
					404: function (response) {
						Cookies.set('database-ping', 'false', { expires: 1 });
						console.log("[JAVASCRIPT] Server pong NOT received")
						$('#server-ping').addClass('red');
						setTimeout(function() {
							$('#server-ping').slideUp('slow');
						}, 1000);
					}
				}
			});
		}, 1000);
	}
}

$(window).bind('scroll', function () {
	if ($(window).scrollTop() > 24) {
		$('#navigation').addClass('fixed');
		$('div.content').addClass('offset');
	} else {
		$('#navigation').removeClass('fixed');
		$('div.content').removeClass('offset');
	}
});
