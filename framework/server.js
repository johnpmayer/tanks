
var express = require('express');
var json = require('express-json');
var bodyParser = require('body-parser');
var cookieParser = require('cookie-parser');
var session = require('express-session');

var app = express();
var server = require('http').Server(app);
var io = require('socket.io')(server);

server.listen(2013);

var options = {
  root: __dirname,
  dotfiles: 'deny',
  headers: {
  }
};

app.use(json());
app.use(bodyParser.urlencoded({
  extended: true}));
app.use(cookieParser());
app.use(session({
  secret: 'mozillapersona',
  resave: false,
  saveUninitialized: true
}));

require('express-persona')(app, {
  audience: 'http://www.wecamtoplay.com:2013'
});

app.all('/', function(req, res) {
  res.sendFile("index.html", options);
});

app.use('/js', express.static(__dirname + '/js'));
app.use('/music', express.static(__dirname + '/music'));

var lobby = {};

app.get('/lobby', function(req, res) {
  if (!req.session || !req.session.email) {
    res.status(401).end();
    return;
  }
  res.json([]);
});

app.get('/session', function(req, res) {
  if (!req.session || !req.session.email) {
    res.json({email:null});
    return;
  }
  res.json({email: req.session.email});
});

app.post('/room', function(req, res) {
  res.send('CREATE');
});

io.on('connection', function (socket) {

  function log(){
    var array = [">>> "];
    for (var i = 0; i < arguments.length; i++) {
      array.push(arguments[i]);
    }
    socket.emit('log', array);
  }

  /*
     socket.on('message', function (message) {
     log('Got message: ', message);
     socket.broadcast.emit('message', message); // should be room only
     });

     socket.on('create or join', function (room) {
     var numClients = io.clients(room).length;

     log('Room ' + room + ' has ' + numClients + ' client(s)');
     log('Request to create or join room', room);

     if (numClients == 0){
     socket.join(room);
     socket.emit('created', room);
     } else if (numClients == 1) {
     io.sockets.in(room).emit('join', room);
     socket.join(room);
     socket.emit('joined', room);
     } else { // max two clients
     socket.emit('full', room);
     }
     socket.emit('emit(): client ' + socket.id + ' joined room ' + room);
     socket.broadcast.emit('broadcast(): client ' + socket.id + ' joined room ' + room);

     });

*/

});
