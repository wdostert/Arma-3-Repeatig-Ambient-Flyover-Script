plane_classes = ["B_Plane_Fighter_01_F", "B_Plane_CAS_01_dynamicLoadout_F"];
flyover_height = 250;       // ATL
spawn_radius = 5000;
arc_start = 330;
arc_end = 390;              // Do not loop back to zero, keep adding to 360
interval_min = 10;
interval_max = 20;



flyover_enabled = true;
if (isServer) then {
    0 spawn {
        while { flyover_enabled } do {
            spawn_angle = [arc_start, arc_end] call BIS_fnc_randomInt;
            interval = [interval_min, interval_max] call BIS_fnc_randomInt;
            plane_to_select = [0, count plane_classes - 1] call BIS_fnc_randomInt;
            plane_class = plane_classes select plane_to_select;
            
            xPos = [];
            yPos = [];
            {
                xPos pushBack (getPos _x select 0);
                yPos pushBack (getPos _x select 1);
            } forEach allPlayers;
            
            xPos sort true;
            yPos sort true;
            
            _xCount = count xPos;
            _yCount = count yPos;
            
            if (_xCount % 2 == 0) then {
                _xIndex1 = (_xCount / 2) - 1;
                _xIndex2 = _xCount / 2;
                xAvg = ((xPos select _xIndex1) + (xPos select _xIndex2)) / 2;
            } else {
                _xIndex = floor(_xCount / 2);
                xAvg = xPos select _xIndex;
            };
            
            if (_yCount % 2 == 0) then {
                _yIndex1 = (_yCount / 2) - 1;
                _yIndex2 = _yCount / 2;
                yAvg = ((yPos select _yIndex1) + (yPos select _yIndex2)) / 2;
            } else {
                _yIndex = floor(_yCount / 2);
                yAvg = yPos select _yIndex;
            };
            
            arc_spawn_x = spawn_radius * sin(spawn_angle);
            arc_spawn_y = spawn_radius * cos(spawn_angle);
            arc_delete_x = spawn_radius * sin(spawn_angle + 180);
            arc_delete_y = spawn_radius * cos(spawn_angle + 180);
            
            _plane = createVehicle [plane_class, [(xAvg + arc_spawn_x), (yAvg + arc_spawn_y), flyover_height], [], 0, "NONE"];
            _plane setDir spawn_angle + 180;
            createVehicleCrew _plane;
            _plane setBehaviour "CARELESS";
            _plane engineOn true;
            
            arc_velocity_x = 200 * sin(spawn_angle + 180);
            arc_velocity_y = 200 * cos(spawn_angle + 180);
            _plane setVelocity [arc_velocity_x, arc_velocity_y, 0];
            
            _wp = group _plane addWaypoint [[(xAvg + arc_delete_x), (yAvg + arc_delete_y), flyover_height], -1];
            _plane flyInHeight flyover_height;
            
            _wp setWaypointStatements ["true", "cleanUpveh = vehicle leader this; {deleteVehicle _x} forEach crew cleanUpveh + [cleanUpveh];"];
            
            waitUntil {!alive _plane};
            sleep interval;
        };
    };
};