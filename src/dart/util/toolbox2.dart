/*
Copyright 2016-2017 Rory Claasen

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
part of Computer_Science_Project_database;

class Notify {
	static final String keyInfo = "info";
	static final String keySuccess = "success";
	static final String keyWarn = "warning";
	static final String keyError = "error";

	static void info(String title, [String message]) {
		notify(keyInfo, title, message);
	}

	static void success(String title, [String message]) {
		notify(keySuccess, title, message);
	}

	static void warn(String title, [String message]) {
		notify(keyWarn, title, message);
	}

	static void error(String title, [String message]) {
		notify(keyError, title, message);
	}

	static void notify(String type, String title, [String message]) {
		if (message == null) message = '';
		js.context.callMethod('notif', [type, title, message]);
	}
}

class JsonList extends JsonObject implements List {
	JsonList();

	factory JsonList.fromString(String jsonString) {
		return new JsonObject.fromJsonString(jsonString, new JsonList());
	}
}

class Regex {
	RegExp get vars => new RegExp(r'\$([^0]\d+|[1-9])');
	RegExp get token => new RegExp(r'(\b\w{3,4}\B|admin)\d+');
}
