# JSON plugin for VC-MP 0.4 #

## Installation ##

1. The plugin must be placed into the server's `plugins` directory. Choose your version:
    * Windows [**32 bit**](/uploads/40e4f210f4ee509eb5bc7993234a82ca/json04rel32.dll) or [**64 bit**](/uploads/60f0bb17c8ae982a46e0e79421fe72f4/json04rel64.dll)
    * Linux [**32 bit**](/uploads/51f40fa5684ef30435fedd7cdb4026a7/json04rel32.so) or [**64 bit**](/uploads/f65336de168c867c7008831312265099/json04rel64.so)
2. Add the plugin's name to plugins in server.cfg:
```
plugins json04rel64 squirrel04rel64
```

## Functions ##

All functions throw errors on failure, so use `try-catch` to handle those.

The `format` parameter can be:

* `JSON_C_TO_STRING_PLAIN` (plain)
* `JSON_C_TO_STRING_SPACED` (spaced)
* `JSON_C_TO_STRING_PRETTY` (pretty)

to change the outputted JSON string's format.

It'll default to `JSON_C_TO_STRING_PLAIN` if omitted.

### The module provides the following functions: ###
* string `toJSON (mixed variable[, int format = JSON_C_TO_STRING_PLAIN])`
* bool `toJSONFile (string filename, mixed variable[, int format = JSON_C_TO_STRING_PLAIN])`
* mixed `fromJSON (string jsontext)`
* mixed `fromJSONFile (string filename)`

## Examples ##

### Exporting server info to a file named "data.json", using pretty formatting when the server stops: ###
```
function onServerStop() {
    local i = 0, ii = 0, plrveh = null, plrspec = null;
    local players = [];
    if (GetPlayers() > 0) {
        while ((i < GetMaxPlayers()) && (ii < GetPlayers())) {
            local plr = FindPlayer(i++);
            if (!plr) continue;

            if (plr.Vehicle) plrveh = {
                model = plr.Vehicle.Model,
                color = [plr.Vehicle.Colour1, plr.Vehicle.Colour2],
                health = plr.Vehicle.Health
            }
            else plrveh = null;

            plrspec = plr.GetSpectating();
            if (plrspec)
                plrspec = plrspec.ID;

            players.push({
                id = plr.ID,
                name = plr.Name,
                skin = plr.Skin,
                team = plr.Team,
                hp = plr.Health,
                ap = plr.Armour,
                score = plr.Score,
                cash = plr.Cash,
                ping = plr.Ping,
                weapon = plr.Weapon,
                vehicle = plrveh,
                pos = {
                    x = plr.Pos.x,
                    y = plr.Pos.y
                },
                spawned = plr.IsSpawned,
                spectating = plrspec
            });
            ii++;
        }
    }
    local export = {
        hostname = GetServerName(),
        weather = GetWeather(),
        hour = GetHour(),
        minute = GetMinute(),
        numplayers = GetPlayers(),
        maxplayers = GetMaxPlayers(),
        players = players
    }

    try {
        toJSONFile("data.json", export, JSON_C_TO_STRING_PRETTY);
    }
    catch (e) {
        print("Export failed: " + e);
    }
}
```