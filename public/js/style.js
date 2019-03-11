var styleLink = document.getElementById('style');
var logo = document.getElementById('logo');

var randomNumber = Math.floor(Math.random() * 2) + 1;

function generateStyle(){
    styleLink.setAttribute('href', '../public/css/style'+randomNumber+'.css')
    logo.setAttribute('src', '../public/img/logo'+randomNumber+'.png');
}

document.onload = generateStyle();