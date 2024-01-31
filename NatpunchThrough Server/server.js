// Imports
var net = require("net");
var udp = require('dgram');

// Server creation
var port = 3000;
//var server = net.createServer();
var UDPserver = udp.createSocket({type:'udp4',reuseAddr: true});

// Setup Base Server Logic variables
var CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
var CLIENTS = new Map();
var HOSTS = new Map();
var HOSTS_TO_IP = new Map();
CLIENT_COUNT = 0;



//#region UDP Server
UDPserver.on('listening',function(){
    var port = address.port;
    console.log('Server is listening at port' + port);
});

UDPserver.on('message',(data,info) => setImmediate(() => {
    var data_stream = "";
    var start_stream = false;
    try{
        var str = data.toString('utf-8')
    }
    catch
    {
        if(HOSTS[info.address] != undefined)
        {

            
        }
        else if(){}

    }
    // if we have a start header start appending any data
    if (str.indexOf("XSTART") == 0) {
        if (start_stream == false) {
        start_stream = true;
        data_stream += str;

        } 
    }
    else if (start_stream == true) {
    data_stream += str;
    }

    // once we have an end header try splitting the data
    if (str.indexOf("XENDX") != -1) 
    {  
        // split data based on start + end headers
        var splits = data_stream.split("XENDX");
        for (var s = 0; s < splits.length; s++) 
        {
            
            var split = splits[s];
            if (split != "") 
            {
                // snip off the end header from string
                var position = split.indexOf("XSTART");
                var plen = split.length-position+1;
                var postcursor = split.replace("XSTART","");
                
        
                try
                {
                    console.log("Receiving Packet")
                    console.log(postcursor)
                    var json = JSON.parse(postcursor)
                    received_packet(info,json.client_id,json.code,json)
                }
                catch (ex)
                {
                    console.log("JSON Parse Error")
                }
            }

            // keep going if more
            if (splits.length > 0 && splits[splits.length-1] != "") 
            {
                data_stream = splits[splits.length-1];
            }
            else {

                data_stream = "";
                start_stream = false;

            }
        }
    }
        

    
}));

UDPserver.on('error',function(error){
    console.log('Error: ' + error);
    server.close();
});

UDPserver.bind(port)
//#endregion UDP Server

//#region fucntions
function create_id(){
    var id =""
    for (var a = 0; a < 5; a++){
        var random_number = Math.floor((Math.random() * CHARS.length))
        var random_char = CHARS[random_number]
        id+= random_char
    }

    if(CLIENTS[id] != undefined){
        return create_id();

    }
    return id;
    


}

function received_packet(socket,client_id, code, json)
{   
    
    switch(code)
    {
        case "HOST":
            HOSTS[socket.address] = { 
                socket: socket, 
                client_id: client_id,
                host_name: json.player_name, 
                status: "New", 
                PLAYERS: []
            }

            HOSTS_TO_IP[client_id] = {
                address:socket.address
            }

            send_packet_udp(socket,{
                code:"HOST_SUCCESS",
                room_code:HOSTS[client_id].client_id})

            break;

        case "UDPCONNECT":
            var client_id = create_id();
            CLIENTS[socket.address] = 
            {
                socket: socket,
                client_id: client_id,
                room_code: "",
                player_name: ""
        
            };
            CLIENT_COUNT++;
            var UDP_connect_success_msg = 
            {
                code:"UDP_CONNECT_SUCCESS",
                client_id:client_id,
            }
            send_packet_udp(socket,UDP_connect_success_msg)
            break;

            
        case "JOINHOST":
            if(HOSTS_TO_IP[json.room_code] != undefined)
            {

            var host_ip = HOSTS_TO_IP[json.room_code].address
            HOSTS[host_ip].PLAYERS.push(CLIENTS[client_id])
            CLIENTS[socket.address].room_code = json.room_code
            CLIENTS[socket.address].player_name = json.player_name

            send_packet_udp(HOSTS[host_ip].socket,
                { code:"PLAYER_JOINED",
                client_id: client_id,
                player_name: CLIENTS[socket.address].player_name,
                });

            send_packet_udp(CLIENTS[socket.address].socket,
                {
                    code:"JOIN_SUCCESS",
                    room_code:json.room_code,
                    client_id:client_id,
                })
            }
            else
            {
                send_packet(CLIENTS[socket.address].socket,
                    {
                        code:"JOIN_FAIL"
                    })
            }
            break;
        case "DISCONNECT":
            // DISCONECT CODE
            console.log("Disconnect")
            if(HOSTS_TO_IP[client_id] != undefined)
            {   
                var host_ip = HOSTS_TO_IP[client_id].address
                console.log("Disconnect Host")
                var _msg = 
                {
                    code:"DISCONNECT"
                }
                HOSTS[host_ip].PLAYERS.forEach(player => send_packet(player.socket,_msg));
                HOSTS[host_ip].PLAYERS.forEach(player => player.room_code = "");
                HOSTS[host_ip] = undefined;

            }

            if(CLIENTS[socket.address].room_code != "")
            {
                console.log("Client")
                var host_ip = HOSTS_TO_IP[CLIENTS[socket.address].room_code]
                var indexToRemove = HOSTS[host_ip].PLAYERS.indexOf(CLIENTS[socket.address])
                HOSTS[CLIENTS[socket.address].room_code].PLAYERS.splice(indexToRemove,1)
                var _msg = 
                {
                    code:"REMOVE_PLAYER",
                    client_id:client_id
                }
                send_packet(HOSTS[host_ip].socket,_msg)
                CLIENTS[socket.address].room_code = ""
            }

            
            break;

    }
}
//#endregion
//#region Packet sending


function send_packet_udp(socket,json)
{
    var _msg = JSON.stringify(json)
    console.log("Being Sent UDP:")
    console.log(_msg)
    var data = ""
    data += _msg //+ "=::="
	data = "XSTART" + data + "XENDX"
    UDPserver.send(data,socket.port,socket.address, (error) => {
        if (error) {
            console.error(error)
        } 
        else {
        console.log(_msg)}
    })

}
//#endregion