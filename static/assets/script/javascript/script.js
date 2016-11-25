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
	pingDatabase();
});

function pingDatabaseForce() {
	Cookies.remove('database-ping');
	pingDatabase();
}

function pingDatabase() {
	if (Cookies.get('database-ping') == undefined || Cookies.get('database-ping') == 'false' || Cookies.get('database-ping') == 'sent') {
		notif('info', 'Database', 'Ping!');
		setTimeout(function() {
			console.log("[JAVASCRIPT] Server ping sending, will be waking up from idle");
			Cookies.set('database-ping', 'sent', { expires: 1 });
			$.ajax({
				url: "http://database.roryclaasen.me/ping.php",
				dataType: "text",
				statusCode: {
					200: function (response) {
						Cookies.set('database-ping', 'true', { expires: 1 });
						console.log("[JAVASCRIPT] Server pong received");
						// iziToast.destroy();
						notif('success', 'Database', 'Received');
					},
					404: function (response) {
						Cookies.set('database-ping', 'false', { expires: 1 });
						console.log("[JAVASCRIPT] Server pong NOT received");
						// iziToast.destroy();
						notif('warning', 'Database', 'Failed');
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

function notif(type, title, message) {
	var defaultMap = {
		position: 'bottomLeft',
		title: title,
		message: message,
		zindex: 99999,
		transitionIn: 'flipInX',
	};
	console.log("[JAVASCRIPT] Showing notification");
	console.log(defaultMap);
	switch(type) {
		case "success": {
			iziToast.success(defaultMap);
			break;
		}
		case "warning": {
			iziToast.warning(defaultMap);
			break;
		}
		case "error": {
			iziToast.error(defaultMap);
			break;
		}
		default: {
			iziToast.info(defaultMap);
			break;
		}
	}
}
