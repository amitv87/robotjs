var robot = require('.');
setInterval(function(){
	var cur = robot.getCursor(true);
	if(cur)
		console.log(cur.hidden);
},100)