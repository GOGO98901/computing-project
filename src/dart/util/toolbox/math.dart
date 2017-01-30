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
part of Computer_Science_Project_Utilities;

class PointSmart {
	int _x, _y;

	PointSmart(this._x, this._y);

	void setX(int x) {
		this._x = x;
	}

	void setY(int y) {
		this._y = y;
	}

	int get x => _x;
	int get y => _y;

	void set(int x, int y) {
		this._x = x;
		this._y = y;
	}

	Vector2 get vector2 => new Vector2(0.0 + _x, 0.0 + _y);

	Point toPoint() {
		return new Point(_x, _y);
	}

	operator +(PointSmart other) => new PointSmart(_x + other._x, _y + other._y);
	operator -(PointSmart other) => new PointSmart(_x - other._x, _y - other._y);
	operator *(int factor) => new PointSmart(_x * factor, _y * factor);
	operator /(int factor) => new PointSmart(_x ~/ factor, _y ~/ factor);
}
