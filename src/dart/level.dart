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

    Random _random = new Random();

    SpaceStation _baseStation;
    List<Asteroid> _asteroids = new List<Asteroid>();

    UserData _userData;

    double _time = 0.0;
    double _spawnTime = 2.3;
    int _level = 0;

    GameLevel() {
        _baseStation = new SpaceStation();
    }

    /// Renders the Level
    void render(CanvasRenderingContext2D context) {
        _asteroids.forEach((enemy) {
            enemy.render(context);
        });
        _baseStation.render(context);
    }

    /// Updates the Level
    void update(final double delta) {
        List<Asteroid> toRemove = new List<Asteroid>();
        _asteroids.forEach((ship) {
            ship.update(delta);
            if (ship.isRemoved()) toRemove.add(ship);
        });
        toRemove.forEach((ship) {
            _asteroids.remove(ship);
        });
        _baseStation.update(delta);

        _updateShips(delta);
    }

    void _updateShips(final double delta) {
        if (_time == 0.0) {
            Asteroid asteroid = new Asteroid(_baseStation);
            int side = _random.nextInt(3);
            int x, y;
            if (side % 2 == 0) y = _random.nextInt(GameHost.height);
            else x = _random.nextInt(GameHost.width);

            int offset = 50;
            if (side == 0) x = -offset;
            if (side == 1) y = -offset;
            if (side == 2) x = GameHost.width + offset;
            // if (side == 3) y = GameHost.height + offset;

            asteroid.setX(x);
            asteroid.setY(y);
            log.info("Spawned new asteroid");
            _asteroids.add(asteroid);
        }
        _time += delta;
        if (_time > _spawnTime - (_level * 0.5)) _time = 0.0;
    }

    void _setUser(UserData data) {
        this._userData = data;
    }
}
