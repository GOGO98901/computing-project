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
part of Computer_Science_Project;

// TODO Create classes for system to store data to and ffrom the database

class UserManagement {

	DataBaseConnection database;

	UserManagement() {
		database = new DataBaseConnection();
	}

	UserData _current;

	Future<bool> login(String token) {
		Completer<bool> completer = new Completer();
		database.getStudentFromToken(token).then((json) {
			log.info(json);
			completer.complete(true);
		});
		//completer.complete(false);
		return completer.future;
	}
}

class UserData {
	String _token;
	String _name;

	UserData(this._token, {String name}) {
		this._name = name;
	}

	String getName(){
		return _name;
	}

	String getToken() {
		return _token;
	}
}
