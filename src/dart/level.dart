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
part of Computer_Science_Project;

class GameLevel {
    static GameLevel newLevel([UserData data]) {
        GameLevel level = new GameLevel();
        if (data != null) level._setUser(data);
        return level;
    }

    SpaceStation _baseStation;
    List<SpaceShip> _enemyShips = new List<SpaceShip>();

    UserData _userData;

    GameLevel() {
        _baseStation = new SpaceStation();
    }

    /// Renders the Level
    void render(CanvasRenderingContext2D context) {
        _enemyShips.forEach((enemy) {
            enemy.render(context);
        });
        _baseStation.render(context);
    }

    /// Updates the Level
    void update(final double delta) {
        List<SpaceShip> toRemove = new List<SpaceShip>();
        _enemyShips.forEach((ship) {
            ship.update(delta);
            if (ship.isRemoved()) toRemove.add(ship);
        });
        toRemove.forEach((ship) {
            _enemyShips.remove(ship);
        });
        _baseStation.update(delta);
    }

    void _setUser(UserData data) {
        this._userData = data;
    }
}
