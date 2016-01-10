var fs = require('fs');
var sjc = require('./strip-json-comments.js');
var keyMap = {}, CURSOR_JOB_INTERVAL = 100, platform = '';


if(/^win/.test(process.platform)){
  platform = 'win';
  CURSOR_JOB_INTERVAL = 100;
}
else if(/^darwin/.test(process.platform)){
  platform = 'darwin';
  keyMap = JSON.parse(sjc(fs.readFileSync('./keymap_darwin.json', 'utf8')));
  CURSOR_JOB_INTERVAL = 200;
}
else if(/^linux/.test(process.platform)){
  platform = 'linux';
  CURSOR_JOB_INTERVAL = 200;
}
else{
  console.log('platform not supported');
  return;
}

var robot = require('./build/Release/robotjs.node');
function sendKey(code, down){
	var keyCode = keyMap[code];
	if(!keyCode)
		keyCode = code;
	robot.sendKey(keyCode, down);
}

function click(button, double){
	robot.mouseClick(button, double);
}

function moveMouse(x, y){
	robot.moveMouse(x, y);
}

function dragMouse(x, y, button){
	robot.dragMouse(x, y, button);
}

function scroll(vertical, horizontal){
	robot.scroll(vertical, horizontal);
}

function getCursor(force){
	return robot.getCursor(force);
}

function getMousePos(){
	console.log(robot.getMousePos());
}

function getScreenSize(){
	return robot.getScreenSize();
}

module.exports = {
	sendKey: sendKey,
	click: click,
	moveMouse: moveMouse,
	dragMouse: dragMouse,
	scroll: scroll,
	getMousePos: getMousePos,
	getCursor: getCursor,
	getScreenSize: getScreenSize
}