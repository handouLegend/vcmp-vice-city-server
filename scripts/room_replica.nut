// ==================== Hotel interior replica ====================
// Generated from the game data/maps/hotel/hotel.IPL by tools; do not hand edit the table.
//
// The cutscene room sat inside the Ocean View Hotel interior, whose own ambience (Audio/Hotel.mp3)
// starts as soon as the room loads and cannot be stopped, muted or masked from a server script:
// PlaySoundForPlayer has no volume, the client script API has no audio control, and a silent custom
// sound does not hold the stream. Moving the hidden body out of the interior volume does switch the
// ambience to the quiet open air one, but VC then culls the interior's own objects - the room's bar,
// paintings and tables ARE hotel map objects - so the scenery has to become ours. This file carries
// the room (and everything near it) as plain data and roomReplica() rebuilds it anywhere, with
// roomOffset applied to every position. The scene applies the same offset to its cast.
//
// Row layout: [model, x, y, z, qx, qy, qz, qw]

roomOffset <- Vector(0.0, 0.0, 250.0);   // where the replica gets built (open air, above the map)

// ---------------------------------------------------------------- build helpers
// These live here rather than in Main.nut: the room is this family's business, Main only owns "can we
// call the engine". While roomSink is an array every object built lands in it, which is how a caller
// gets the handles it needs to delete the room again.

roomSink <- null;

function rp(x, y, z)          // room space -> world space (roomOffset applied)
{
    return Vector(x + roomOffset.x, y + roomOffset.y, z + roomOffset.z);
}

function mk(model, wd, pos)
{
    // CreateObject is called straight from here on purpose: these overloaded engine functions only
    // resolve from a shallow stack, and Main's roomBuild -> roomReplica -> mk -> CreateObject is the
    // same depth the working code always used. An extra wrapper frame is enough to break it.
    local o = CreateObject(model, wd, pos, 255);
    if(roomSink != null) roomSink.append(o);
    return o;
}

// The shell: the 20 blocks the map tool built, and the only floor the actors have. They have to follow
// roomOffset too - without them the replica is open air and the actors (real clients, with gravity)
// simply fall out of the sky.
function objcrt(wd)
{
    mk(318,wd,rp(219.477,-1282.75,18.1755)).RotateTo(Quaternion(0.515351,0.483811,0.483924,0.515905),0); 
    mk(318,wd,rp(218.232,-1287.21,18.1381)).RotateTo(Quaternion(0.704845,-0.0186311,-0.0202258,0.708828),0); 
    mk(318,wd,rp(214.731,-1289.2,19.5912)).RotateTo(Quaternion(-0.00802745,-0.00120627,0.692122,0.721735),0); 
    mk(318,wd,rp(218.166,-1289.55,18.1631)).RotateTo(Quaternion(0.708734,-0.0176814,-0.0211735,0.704936),0); 
    mk(318,wd,rp(222.246,-1289.52,18.1631)).RotateTo(Quaternion(0.490982,-0.517592,-0.505715,0.485065),0); 
    mk(318,wd,rp(218.04,-1291.52,18.1631)).RotateTo(Quaternion(0.708734,-0.0176814,-0.0211735,0.704936),0); 
    mk(318,wd,rp(214.829,-1295.67,19.4412)).RotateTo(Quaternion(0.0144896,-0.0148729,0.704436,0.709464),0); 
    mk(318,wd,rp(216.113,-1295.77,18.1631)).RotateTo(Quaternion(0.50542,-0.507204,-0.491998,0.49521),0); 
    mk(318,wd,rp(217.378,-1296.02,18.1631)).RotateTo(Quaternion(0.508077,-0.504833,-0.490596,0.496304),0); 
    mk(318,wd,rp(218.664,-1296.04,19.4037)).RotateTo(Quaternion(-0.00056442,0.00267906,0.704564,0.709636),0); 
    mk(318,wd,rp(221.903,-1292.76,19.4162)).RotateTo(Quaternion(-0.0410524,0.00391166,0.998983,-0.0182592),0); 
    mk(318,wd,rp(223.441,-1289.57,19.4037)).RotateTo(Quaternion(-0.000524171,0.00268723,0.69384,0.720124),0); 
    mk(318,wd,rp(224.907,-1285.94,19.4162)).RotateTo(Quaternion(-0.00442892,0.0097334,0.999877,0.0115138),0); 
    mk(318,wd,rp(221.74,-1282.63,19.4162)).RotateTo(Quaternion(-0.0100407,0.00367962,0.710179,-0.703939),0); 
    mk(318,wd,rp(220.672,-1282.68,18.1755)).RotateTo(Quaternion(0.515351,0.483811,0.483924,0.515905),0); 
    mk(318,wd,rp(218.058,-1282.4,19.4162)).RotateTo(Quaternion(-0.00473683,0.00894749,0.708367,-0.705772),0); 
    mk(318,wd,rp(216.385,-1285.8,20.2161)).RotateTo(Quaternion(-0.723532,-0.00212275,0.690273,0.00454486),0); 
    mk(318,wd,rp(218.073,-1298.97,19.4162)).RotateTo(Quaternion(-0.0410524,0.00391166,0.998983,-0.0182592),0); 
    mk(318,wd,rp(219.477,-1282.75,21.3754)).RotateTo(Quaternion(0.515351,0.483811,0.483924,0.515905),0); 
    mk(318,wd,rp(219.868,-1279.52,19.4662)).RotateTo(Quaternion(-0.999399,0.0322933,0.0021453,0.0124026),0); 
}

// A whole room: shell + furniture + floor. Returns every object of this copy; the caller deletes them.
// Every viewer gets one in his own world, and world 0 keeps a permanent one - that copy is the floor
// the actors' own npcclient processes stand on (they live in world 0 whatever the viewer is in).
function roomBuild(off, wd)
{
    roomSink = [];
    roomReplica(off, wd);
    objcrt(wd);
    local list = roomSink;
    roomSink = null;
    return list;
}

roomProps <- [
    [4590, 228.1128693, -1266.723877, 19.06917191, 0, 0, 0, 1],   // hot_room317
    [4591, 228.3385468, -1260.84082, 19.0687294, 0, 0, 0.1132032052, 0.9935718775],   // hot_drawers1_01
    [4592, 231.379425, -1274.292725, 18.68613815, 0, 0, 0.1088668779, 0.994056344],   // hot_bar1_01
    [4593, 226.2657318, -1267.393311, 19.48874283, 0, 0, 0.7880107164, 0.6156615019],   // nt_wassily1_02
    [4594, 230.9316254, -1268.031128, 19.48408318, 0, 0, 0.1045284644, 0.9945219159],   // nt_couch_1
    [4595, 227.6501465, -1263.227417, 19.39101219, 0, 0, 0.1088668779, 0.994056344],   // nt_bed1_01
    [4596, 228.3385468, -1260.84082, 19.0687294, 0, 0, 0.1132031977, 0.9935718775],   // hot_trans1
    [4597, 226.2657318, -1267.393311, 19.48874283, 0, 0, 0.7880107164, 0.6156615019],   // hot_mags1
    [4598, 220.1283722, -1285.954834, 19.14044571, 0, 0, 4.371138829e-008, 1],   // mob_door2
    [4599, 219.8560333, -1282.852295, 18.23122978, 0, 0, 0, 1],   // mob_mobroom2
    [4600, 218.5437775, -1285.954834, 19.14044571, 0, 0, 4.371138829e-008, 1],   // mob_door3
    [4601, 219.9134369, -1291.02417, 18.69469643, 0, 0, 0, 1],   // mob_detailsb
    [4761, 217.1263885, -1284.751953, 12.07163143, 0, 0, -0.9378889203, 0.3469357789],   // cl_tablesetlrg
    [4761, 220.4385376, -1283.837402, 12.07163143, 0, 0, -0.9378889203, 0.3469357789],   // cl_tablesetlrg
    [4761, 223.1632233, -1285.896362, 12.07163143, 0, 0, -0.9378889203, 0.3469357789],   // cl_tablesetlrg
    [4761, 220.1324615, -1287.654785, 12.07163143, 0, 0, -0.9378889203, 0.3469357789],   // cl_tablesetlrg
    [4761, 216.9534912, -1290.03479, 12.07163143, 0, 0, -0.9378889203, 0.3469357789],   // cl_tablesetlrg
    [4761, 218.6683655, -1292.907959, 12.07163143, 0, 0, -0.9378889203, 0.3469357789],   // cl_tablesetlrg
    [4761, 222.332077, -1290.991699, 12.07163143, 0, 0, -0.9378889203, 0.3469357789],   // cl_tablesetlrg
    [4602, 219.2742615, -1284.379883, 11.26794147, 0, 0, 0, 1],   // ht_veg04_nt
    [4603, 222.2004852, -1280.150024, 12.1456728, 0, 0, 0, 1],   // ht_veg02_nt
    [4604, 222.3291626, -1284.370972, 12.08570766, 0, 0, 0, 1],   // ht_veg01_nt
    [4605, 218.5762939, -1284.356079, 11.67983627, 0, 0, 0, 1],   // ht_fans_nt
    [4606, 224.2023163, -1273.921753, 11.03123379, 0, 0, 0, 1],   // ht_kb_couch1_nt
    [4607, 218.5349579, -1284.176636, 11.56140614, 0, 0, 0, 1],   // htl_maintiles_nt
    [4608, 211.313324, -1279.656982, 11.03122997, 0, 0, 0, 1],   // htl_lftdoor1_nt
    [4609, 232.135376, -1279.658325, 13.36298656, 0, 0, 0.1088668779, 0.994056344],   // htl_exterior03_nt
    [4610, 218.9933624, -1283.65271, 8.781049728, 0, 0, 0, 1],   // ht_mainfloor2_nt
    [4611, 224.7962494, -1291.723267, 13.13979053, 0, 0, 0, 1],   // htl_gls_3_nt
    [4612, 226.8217621, -1283.599365, 13.13979053, 0, 0, 0, 1],   // htl_gls_1_nt
    [4613, 225.8090057, -1287.661377, 13.13979053, 0, 0, 0, 1],   // htl_gls_2_nt
    [4614, 219.2742615, -1284.379883, 11.26794147, 0, 0, 0, 1],   // ht_veg04_dy
    [4615, 222.2004852, -1280.150024, 12.1456728, 0, 0, 0, 1],   // ht_veg02_dy
    [4616, 222.3291626, -1284.370972, 12.08570766, 0, 0, 0, 1],   // ht_veg01_dy
    [4617, 218.5762939, -1284.356079, 11.67983627, 0, 0, 0, 1],   // ht_fans_dy
    [4618, 224.2023163, -1273.921753, 11.03123379, 0, 0, 0, 1],   // ht_kb_couch1_dy
    [4619, 218.9933624, -1283.65271, 11.11576939, 0, 0, 0, 1],   // ht_mainfloor_dy
    [4620, 215.0361328, -1278.651367, 16.50287437, 0, 0, 0, 1],   // ht_upstairs
    [4621, 218.5349579, -1284.176636, 11.56140614, 0, 0, 0, 1],   // htl_maintiles_dy
    [4622, 211.313324, -1279.656982, 11.03122997, 0, 0, 0, 1],   // htl_lftdoor1_dy
    [4623, 232.135376, -1279.658325, 13.36298656, 0, 0, 0.1088668779, 0.994056344],   // htl_exterior03_dy
    [4624, 218.9933624, -1283.65271, 8.781049728, 0, 0, 0, 1],   // ht_mainfloor2_dy
    [4625, 224.7962494, -1291.723267, 13.13979053, 0, 0, 0, 1],   // htl_gls_3_dy
    [4626, 226.8217621, -1283.599365, 13.13979053, 0, 0, 0, 1],   // htl_gls_1_dy
    [4627, 225.8090057, -1287.661377, 13.13979053, 0, 0, 0, 1],   // htl_gls_2_dy
    [4628, 217.4566803, -1284.520996, 11.03278732, 0, 0, 0, 1],   // htl_dco_chair03_dy
    [4629, 217.4566803, -1284.520996, 11.03278732, 0, 0, 0, 1],   // htl_dco_chair03_nt
    [4629, 220.759552, -1283.589233, 11.03278732, 0, 0, -0.04361938685, 0.999048233],   // htl_dco_chair03_nt
    [4628, 220.759552, -1283.589233, 11.03278732, 0, 0, -0.04361938685, 0.999048233],   // htl_dco_chair03_dy
    [4629, 223.4906006, -1285.681396, 11.03278732, 0, 0, -0.04361938685, 0.999048233],   // htl_dco_chair03_nt
    [4628, 223.4906006, -1285.681396, 11.03278732, 0, 0, -0.04361938685, 0.999048233],   // htl_dco_chair03_dy
    [4629, 220.4624023, -1287.392456, 11.03278732, 0, 0, -0.04361938685, 0.999048233],   // htl_dco_chair03_nt
    [4628, 220.4624023, -1287.392456, 11.03278732, 0, 0, -0.04361938685, 0.999048233],   // htl_dco_chair03_dy
    [4629, 222.6569672, -1290.72998, 11.03278732, 0, 0, -0.04361938685, 0.999048233],   // htl_dco_chair03_nt
    [4628, 222.6569672, -1290.72998, 11.03278732, 0, 0, -0.04361938685, 0.999048233],   // htl_dco_chair03_dy
    [4629, 217.2770386, -1289.772461, 11.03278732, 0, 0, -0.04361938685, 0.999048233],   // htl_dco_chair03_nt
    [4628, 217.2770386, -1289.772461, 11.03278732, 0, 0, -0.04361938685, 0.999048233],   // htl_dco_chair03_dy
    [4629, 218.9900665, -1292.646729, 11.03278732, 0, 0, -0.04361938685, 0.999048233],   // htl_dco_chair03_nt
    [4628, 218.9900665, -1292.646729, 11.03278732, 0, 0, -0.04361938685, 0.999048233],   // htl_dco_chair03_dy
    [585, 212.3721313, -1290.880127, 14.99667645, 0, 0, 0, 1],   // htl_fan_rotate_nt
    [586, 212.3721313, -1290.880127, 14.98123074, 0, 0, 0, 1],   // htl_fan_static_nt
    [587, 212.3721313, -1290.880127, 14.98123074, 0, 0, 0, 1],   // htl_fan_static_dy
    [589, 212.3721313, -1290.880127, 14.99667645, 0, 0, 0, 1],   // htl_fan_rotate_dy
    [589, 220.5480194, -1293.057007, 14.99667645, 0, 0, 0, 1],   // htl_fan_rotate_dy
    [585, 220.5480194, -1293.057007, 14.99667645, 0, 0, 0, 1],   // htl_fan_rotate_nt
    [587, 220.5480194, -1293.057007, 14.98123074, 0, 0, 0, 1],   // htl_fan_static_dy
    [586, 220.5480194, -1293.057007, 14.98123074, 0, 0, 0, 1],   // htl_fan_static_nt
    [589, 222.1404572, -1287.385254, 14.9966774, 0, 0, 0, 1],   // htl_fan_rotate_dy
    [585, 222.1404572, -1287.385254, 14.9966774, 0, 0, 0, 1],   // htl_fan_rotate_nt
    [587, 222.1404572, -1287.385254, 14.98123169, 0, 0, 0, 1],   // htl_fan_static_dy
    [586, 222.1404572, -1287.385254, 14.98123169, 0, 0, 0, 1],   // htl_fan_static_nt
    [589, 214.035141, -1284.668335, 14.9966774, 0, 0, 0, 1],   // htl_fan_rotate_dy
    [585, 214.035141, -1284.668335, 14.9966774, 0, 0, 0, 1],   // htl_fan_rotate_nt
    [587, 214.035141, -1284.668335, 14.98123169, 0, 0, 0, 1],   // htl_fan_static_dy
    [586, 214.035141, -1284.668335, 14.98123169, 0, 0, 0, 1],   // htl_fan_static_nt
    [589, 216.2579193, -1275.119507, 14.99667835, 0, 0, 0, 1],   // htl_fan_rotate_dy
    [585, 216.2579193, -1275.119507, 14.99667835, 0, 0, 0, 1],   // htl_fan_rotate_nt
    [587, 216.2579193, -1275.119507, 14.98123264, 0, 0, 0, 1],   // htl_fan_static_dy
    [586, 216.2579193, -1275.119507, 14.98123264, 0, 0, 0, 1],   // htl_fan_static_nt
    [589, 223.9583435, -1276.908081, 14.99667835, 0, 0, 0, 1],   // htl_fan_rotate_dy
    [585, 223.9583435, -1276.908081, 14.99667835, 0, 0, 0, 1],   // htl_fan_rotate_nt
    [587, 223.9583435, -1276.908081, 14.98123264, 0, 0, 0, 1],   // htl_fan_static_dy
    [586, 223.9583435, -1276.908081, 14.98123264, 0, 0, 0, 1],   // htl_fan_static_nt
    [4630, 228.1128693, -1266.723877, 19.01170158, 0, 0, 0, 1],   // hotshad1
    [4631, 228.9060059, -1268.219238, 22.61333656, 0, 0, 0.7402182817, 0.6723666787],   // hotroomfan
    [4631, 230.0313568, -1263.24939, 22.61333656, 0, 0, 0.7402182817, 0.6723666787],   // hotroomfan
    [475, 233.2629852, -1265.594727, 20.46360397, 0, 0, 0, 1],   // veg_palmkb14
    [475, 232.2869568, -1269.51709, 20.46360397, 0, 0, 0, 1],   // veg_palmkb14
    [475, 223.3877411, -1274.462524, 19.64633369, 0, 0, -0.8386706114, 0.5446389914],   // veg_palmkb14
    [475, 224.5502319, -1271.701904, 19.64633369, 0, 0, -0.6427876353, 0.7660444379],   // veg_palmkb14
    [4639, 227.7472382, -1277.805176, 12.63202667, 0, 0, 0.1088668779, 0.994056344],   // ht_doors
    [4640, 218.9933624, -1283.65271, 11.11576939, 0, 0, 0, 1],   // ht_mainfloor_nt
    [4641, 230.5574799, -1279.781006, 20.13978958, 0, 0, 0, 1],   // htl_gls_lobby
];

function roomReplica(off, wd)
{
    foreach(o in roomProps)
        mk(o[0], wd, Vector(o[1] + off.x, o[2] + off.y, o[3] + off.z))
            .RotateTo(Quaternion(o[4], o[5], o[6], o[7]), 0);
}
