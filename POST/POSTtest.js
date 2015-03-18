var express = require('express');
var app = express();

app.get('/gps', function(req, res) {
/root/SommAppiOS/POSTtest.js	res.send('Hello World');
});

app.listen(process.env.PORT || 1337);