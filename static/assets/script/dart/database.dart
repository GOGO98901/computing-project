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
library Computer_Science_Project_database;

import 'dart:html';
import 'dart:math';
import 'package:logging/logging.dart';
import 'dart:async';
// import 'dart:convert';
import 'dart:js' as js;
import 'package:json_object/json_object.dart';

final Logger log = new Logger('prototype');

void main() {
	Logger.root.level = Level.ALL;
	Logger.root.onRecord.listen((LogRecord rec) {
		print('[DART][${rec.time}] ${rec.level.name}: ${rec.message}');
	});
	DataBaseConnection db = new DataBaseConnection();

	// ADD USER
	querySelector('#addStudent').onClick.listen((event) {
		String name = (querySelector('#userAddName') as InputElement).value;
		if (name.length > 0)	{
			db.addUser(name).then((json) {
				querySelector('#userAddName').attributes['disabled'] = "";
				querySelector('#stage-start').style.display = "none";
				querySelector('#stage-end').style.display = "inline";
				querySelector('#userAddReturnCode').text = json.token;

				js.context.callMethod('notif', ['success', 'Added Student', name]);
			});
		} else {
			querySelector('#userAddForm').classes.add('has-error');
		}
	});
	querySelector('#userAddName').onInput.listen((event) {
		querySelector('#userAddForm').classes.remove('has-error');
	});
	querySelector('#addStudentClose').onClick.listen((event) {
		querySelector('#userAddName').attributes.remove('disabled');
		querySelector('#stage-start').style.display = "inline";
		querySelector('#stage-end').style.display = "none";
		querySelector('#userAddReturnCode').text = "";
		(querySelector('#userAddName') as InputElement).value = "";
	});

	// REMOVE USER
	querySelector('#modelUserRemoveBtn').onClick.listen((event) {
		db.getStudentList().then((list) {
			SelectElement element = querySelector('#userRemoveSelect') as SelectElement;
			element.attributes.remove('disabled');
			element.children.clear();
			OptionElement option = new OptionElement();
			option.text = "Select a Student";
			option.attributes['id'] = "-1";
			element.children.add(option);
			for (JsonObject json in list) {
				OptionElement option = new OptionElement();
				option.text = json.name + " (" + json.login + ")";
				option.attributes['id'] = json.id;
				option.attributes['name'] = json.name;
				option.attributes['login'] = json.login;
				element.children.add(option);
			}
		});
	});

	SelectElement rmSelector = querySelector('#userRemoveSelect') as SelectElement;
	querySelector('#removeStudentWarning').onClick.listen((event) {
		if (rmSelector.selectedIndex > 0) {
			db.getStudent(int.parse(rmSelector.item(rmSelector.selectedIndex).attributes['id'])).then((json) {
				querySelector('#userRemoveConfirmName').text = json.name;
				querySelector('#userRemoveConfirmToken').text = json.login;
			});
			js.context.callMethod(r'$', ['#modelUserRemoveConfirm']).callMethod('modal', ['show']);
		}
	});
	querySelector('#removeStudentConfirm').onClick.listen((event) {
		var name = rmSelector.item(rmSelector.selectedIndex).attributes['name'];
		db.removeUser(int.parse(rmSelector.item(rmSelector.selectedIndex).attributes['id'])).then((json) {
			log.info(json);
			js.context.callMethod(r'$', ['#modelUserRemove']).callMethod('modal', ['hide']);
			js.context.callMethod(r'$', ['#modelUserRemoveConfirm']).callMethod('modal', ['hide']);

			js.context.callMethod('notif', ['warning', 'Removed student', name]);
		});
	});
}

class DataBaseConnection {
	final String queryPage = "http://database.roryclaasen.me/query.php";

	DataBaseConnection() {
		log.info('Database connection setting up with url [${queryPage}]');
	}

	Future<JsonObject> addUser(String name) {
		Completer<JsonObject> completer = new Completer();
		_getNextId().then((id) {
			String login = _randomLogin(id, 4);
			log.info("New login token " + login);
			_getQueryResult("INSERT INTO `cp_students`(`name`, `login`) VALUES ('${name}', '${login}')").then((json) {
				json.isExtendable = true;
				json.name = name;
				json.token = login;
				json.isExtendable = false;
				completer.complete(json);
			});
		});
		return completer.future;
	}

	Future<JsonObject> removeUser(int id) {
		Completer<JsonObject> completer = new Completer();
		_getQueryResult("DELETE FROM `cp_students` WHERE `id` = ${id}").then((json) {
			completer.complete(json);
		});
		return completer.future;
	}

	Future<JsonObject> getStudent(int id) {
		Completer<JsonObject> completer = new Completer();
		_getQueryResultAsQueryList("SELECT * FROM `cp_students` WHERE `id` = ${id}").then((list) {
			completer.complete(list[0]);
		});
		return completer.future;
	}

	Future<List> getStudentList() {
		Completer<List> completer = new Completer();
		_getQueryResultAsQueryList("SELECT * FROM `cp_students` WHERE 1").then((list) {
			List<JsonObject> userList = new List<JsonObject>();
			for(var iter = list.iterator; iter.moveNext();) {
				JsonObject current = iter.current;
				userList.add(current);
			}
			completer.complete(userList);
		});
		return completer.future;
	}

	Future<int> _getNextId() {
		Completer<int> completer = new Completer();
		_getQueryResultAsQueryList("SHOW TABLE STATUS LIKE 'cp_students'").then((list) {
			int id = 0;
			try  {
				id = int.parse(list[0].Auto_increment);
			} catch(error) {
				log.warning(error);
			}
			completer.complete(id);
		});
		return completer.future;
	}

	String _randomLogin(int id, int length) {
		var rand = new Random();
		var codeUnits = new List.generate(
			length,
			(index) {
				return rand.nextInt(26) + 97;
			}
		);
		return new String.fromCharCodes(codeUnits) + id.toString();
	}

	Future<String> _getQueryResultAsString(String query) {
		log.info('Sending query "' + query + '"');
		Completer<String> completer = new Completer();
		HttpRequest req = new HttpRequest();
		req.open("POST", queryPage);
		req.onLoadEnd.first.then((e) {
			if(req.status == 200 || req.status == 0) {
				completer.complete(req.response as String);
			} else {
				completer.complete('{"error": "Can\'t load url ${queryPage}. Response type ${req.status}"}');
			}
		});
		req.send('{"query": "${query}"}');
		return completer.future;
	}

	Future<JsonObject> _getQueryResult(String query) {
		Completer<JsonObject> completer = new Completer();
		_getQueryResultAsString(query).then((json) {
			completer.complete(new JsonObject.fromJsonString(json));
		});
		return completer.future;
	}

	Future<JsonList> _getQueryResultAsQueryList(String query) {
		Completer<JsonList> completer = new Completer();
		_getQueryResult(query).then((json) {
			completer.complete(new JsonList.fromString(json.output.toString()));
		});
		return completer.future;
	}
}

class JsonList extends JsonObject implements List {
	JsonList();

	factory JsonList.fromString(String jsonString) {
		return new JsonObject.fromJsonString(jsonString, new JsonList());
	}
}
