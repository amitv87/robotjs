var fs = require('fs');
var sjc = require('./strip-json-comments.js');
var keyMap = {}, CURSOR_JOB_INTERVAL = 200, platform = '';
var isDarwin, isWin, IsLinux;
if(/^darwin/.test(process.platform)){
  platform = 'darwin';
  isDarwin = true;
  keyMap = JSON.parse(sjc(fs.readFileSync(__dirname + '/keymap_darwin.json', 'utf8')));
}
else if(/^win/.test(process.platform)){
  platform = 'win';
  isWin = true;
  CURSOR_JOB_INTERVAL = 100;
}
else if(/^linux/.test(process.platform)){
  platform = 'linux';
  IsLinux = true;
}
else{
  console.log('platform not supported');
  return;
}

var robot = require('./build/Release/robotjs.node');

function sendKey(code, down, alt, shift, ctrl, meta){
  var keyCode = keyMap[code];
  if(isNaN(keyCode))
    keyCode = code;
  robot.sendKey(keyCode, down, alt, shift, ctrl, meta);
}

function sendClick(button, down, double){
  if(double && isDarwin)
    robot.mouseClick(button, double);
  else
    robot.sendClick(button, down);
}

function moveMouse(x, y){
  robot.moveMouse(x, y);
}

function dragMouse(x, y, button){
  robot.dragMouse(x, y, button);
}

function scroll(vertical, horizontal){
  if(isDarwin)
    robot.scroll(vertical / 30, horizontal / 30);
  else
    robot.scroll(vertical * 30, horizontal * 30);
}

function getCursor(force){
  return robot.getCursor(force);
}

function getMousePos(){
  return robot.getMousePos();
}

function getScreenSize(){
  return robot.getScreenSize();
}

module.exports = {
  scroll: scroll,
  sendKey: sendKey,
  sendClick: sendClick,
  moveMouse: moveMouse,
  dragMouse: dragMouse,
  getCursor: getCursor,
  getMousePos: getMousePos,
  getScreenSize: getScreenSize,
  robotInternal: robot,
}
