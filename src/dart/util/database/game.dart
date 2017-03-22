/*
Copyright 2017 Rory Claasen

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

class Task {

    static Task fromItem(JsonObject object) {
        return new Task(object.id, object.question, object.data);
    }

    int _id;
    String _question;
    Object _data;

    bool _used = false;

    Task(this._id, this._question, this._data);

    int get id => _id;
    String get question => _question;
    Object get data => _data;

    bool get used => _used;
    void set used(bool value) {
        _used = value;
    }

    String toString() {
        return {
            "id": id,
            "question": question,
            "data": data,
            "used": used
        }.toString();
    }
}
