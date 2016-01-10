var robot = require('.');
setInterval(function(){
	var cur = robot.getCursor();
	if(cur)
		console.log(cur);
},100)