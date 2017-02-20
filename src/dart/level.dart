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

    int _score;

    SpaceStation _baseStation;

    EntityHandler<Asteroid> _asteroids;
    EntityHandler<Shape> _shapes;
    EntityHandler<Mob> _currentMob;

    // ignore: unused_field
    UserData _userData;

    bool _freeze = false;

    double _time = 0.0;
    double _spawnTime = 2.3;
    int _level = 0;

    GameLevel() {
        _baseStation = new SpaceStation();
        _score = 0;

        _asteroids = new EntityHandler<Asteroid>(2.0, () {
            Asteroid asteroid = new Asteroid(_baseStation);
            asteroid.vector2 = genericSpawnLocation();
            return asteroid;
        });
        _asteroids.delay = _spawnTime - (_level * 0.5);

        _shapes = new EntityHandler<Shape>(5.0, () {
            Shape shape = new Shape();
            int spawnSide = _random.nextInt(4), oppositeSide = -1;
            shape.vector2 = genericSpawnLocation(side: spawnSide);
            if (spawnSide == 0) oppositeSide = 2;
            if (spawnSide == 1) oppositeSide = 3;
            if (spawnSide == 2) oppositeSide = 0;
            if (spawnSide == 3) oppositeSide = 1;
            shape.target = genericSpawnLocation(side: oppositeSide);
            return shape;
        });

        _currentMob = _shapes;
    }

    /// Renders the Level
    void render(CanvasRenderingContext2D context) {
        _currentMob.render(context);
        _baseStation.render(context);
    }

    /// Updates the Level
    void update(final double delta) {
        if (!_freeze) _currentMob.update(delta);

        _baseStation.update(delta);
    }

    Asteroid getNearestAsteroid() {
        Asteroid nearest;
        double distance = 0.0;
        _asteroids.entities.forEach((asteroid) {
            double d = getDistanceFromEntity(asteroid);
            if (d > distance) {
                d = distance;
                nearest = asteroid;
            }
        });
        return nearest;
    }

    double getNearestAsteroidDistance() {
        double distance = 0.0;
        _asteroids.entities.forEach((asteroid) {
            double d = getDistanceFromEntity(asteroid);
            if (d > distance) {
                d = distance;
            }
        });
        return distance;
    }

    double getDistanceFromEntity(Entity goal, [Entity start]) {
        if (start == null) start = _baseStation;
        return start.vector2.distanceTo(goal.vector2);
    }

    int get score => _score;
    String get formattedScore => _score.toString().padLeft(5, '0');

    void _setUser(UserData data) {
        this._userData = data;
    }

    Vector2 genericSpawnLocation({int side}) {
        if (side == null) side = _random.nextInt(4);
        int x, y;
        int margins = 200;
        if (side % 2 == 0) y = _random.nextInt(GameHost.height - margins);
        else {
            int xP = _random.nextInt(margins);
            if (_random.nextInt(2) == 0) x = xP;
            else x = GameHost.width - margins + xP;
        }

        int offset = 50;
        if (side == 0) x = -offset;
        if (side == 1) y = -offset;
        if (side == 2) x = GameHost.width + offset;
        if (side == 3) y = GameHost.height + offset;

        return new Vector2(0.0 + x, 0.0 + y);
    }
}

typedef Entity SpawnEntity();

class EntityHandler<T> {
    final Random _random = new Random();

    double _time = 0.0, _delay =0.0;

    List<T> _entities;

    SpawnEntity _spawn;

    EntityHandler(this._delay, this._spawn) {
        _entities = new List<T>();
    }

    void forceSpawn() {
        if (_spawn != null) {
            Entity entity = _spawn();
            if (entity is T) {
                _entities.add(entity as T);
                log.info("Spawned new $T");
            } else log.warning('Entity is not type $T');
        } else log.severe("Spawn is null!");
    }

    void render(CanvasRenderingContext2D context) {
        _entities.forEach((entity) {
            entity.render(context);
        });
    }

    void update(final double delta) {
        if (_time == 0.0) forceSpawn();
        _time += delta;
        if (_time >= _delay) {
            _time = 0.0;
        }

        List<T> removed = new List<T>();
        _entities.forEach((entity) {
            entity.update(delta);
            if (entity.isRemoved()) removed.add(entity);
        });

        removed.forEach((entity) => _entities.remove(entity));
    }

    double get delay => _delay;
    void set delay(double new_delay) {
        _delay = new_delay;
    }

    List<T> get entities => _entities;
}
