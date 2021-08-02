var express = require('express');
var app = express();
const path = require('path')

const PORT = 80;

app.get('/', function(req, res){
	res.sendFile(path.join(__dirname, 'views/index.html'));
});

app.listen(PORT, () => console.log(`Example app listening on port ${PORT}!`))
