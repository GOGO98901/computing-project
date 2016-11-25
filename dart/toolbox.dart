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

class Util {

	/// Gets the Uri that the system is connected from
	static Uri getUri() {
		return Uri.base;
	}

	/// Returns `true` when not connected to from the local host `127.0.0.1`
	static bool isLive()  {
		String address = getUri().toString().toLowerCase().replaceFirst("http://", "");
		// Helper.notify(Helper.info, address);
		if (address.startsWith('127.0.0.1')) return false;
		return true;
	}
}

class Point {
	int _x, _y;

	Point(this._x, this._y);

	void setX(int x) {
		this._x = x;
	}

	int getX()  {
		return _x;
	}

	void setY(int y) {
		this._y = y;
	}

	int getY()  {
		return _y;
	}

	void set(int x, int y) {
		this._x = x;
		this._y = y;
	}

	operator +(Point other) => new Point(_x + other._x, _y + other._y);
	operator -(Point other) => new Point(_x - other._x, _y - other._y);
	operator *(int factor) => new Point(_x * factor, _y * factor);
	operator /(int factor) => new Point(_x ~/ factor, _y ~/ factor);
}
