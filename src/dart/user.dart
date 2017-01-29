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
part of Computer_Science_Project;

// TODO Create classes for system to store data to and from the database

class UserManagement {

	DataBaseConnection database;

	UserData currentUser = null;

	ProblemManager problems;

	UserManagement() {
		database = new DataBaseConnection();
		problems = new ProblemManager();
	}

	Future<bool> login(String token) {
		Completer<bool> completer = new Completer();
		database.getStudentFromToken(token).then((json) {
			if (json.containsKey("error")) {
				log.warning(json.error);
				currentUser = null;
				completer.complete(false);
			} else {
				log.info("Found user attempting to log in. ${json}");
				currentUser = new UserData(json.login, json.id, json.name, json['class']);
				completer.complete(true);
			}
		});
		return completer.future;
	}

	bool get loggedIn => currentUser != null;

	String get playerName {
		if (loggedIn) return currentUser.name;
		return "Player";
	}
}

class UserData {
	int _id;
	String _token;
	String _name;
	int _class;

	UserData(this._token, this._id, [String name, int classId]) {
		this._name = name;
		this._class = classId;
	}

	int get id => _id;
	String get name => _name;
	String get token => _token;
	int get classId => _class;
}
