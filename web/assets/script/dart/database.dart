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
import 'package:json_object/json_object.dart';

final Logger log = new Logger('prototype');

void main() {
	Logger.root.level = Level.ALL;
	Logger.root.onRecord.listen((LogRecord rec) {
		print('[DART][${rec.time}] ${rec.level.name}: ${rec.message}');
	});
	DataBaseConnection db = new DataBaseConnection();
	querySelector('#addStudent').onClick.listen((event) {
		String name = (querySelector('#userAddName') as InputElement).value;
		if (name.length > 0)	{
			db.addUser(name).then((json) {
				querySelector('#userAddName').attributes['disabled'] = "";
				querySelector('#stage-start').style.display = "none";
				querySelector('#stage-end').style.display = "inline";
				querySelector('#userAddReturnCode').text = json.token;
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

	void removeUser(String login) {
		//TODO Remove user
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
		String url = queryPage + "?sql=" + query;
		Completer<String> completer = new Completer();
		HttpRequest req = new HttpRequest();
		req.open("get", url);
		req.onLoadEnd.first.then((e) {
			if(req.status ~/ 100 == 2) {
				completer.complete(req.response as String);
			} else {
				completer.complete('{"error": "Can\'t load url ${url}. Response type ${req.status}"}');
			}
		});
		req.send("");
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
			completer.complete(new JsonList.fromString(json.query.toString()));
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
