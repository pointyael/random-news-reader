/*----------------------------------------------------------*/
/* 					  REFRESH DE LA PAGE		 	   		*/
/*----------------------------------------------------------*/
var buttonRefresh = document.getElementById('btnRefresh');
var main = document.getElementsByTagName('main')[0];

function refreshItems() {
	main.innerHTML = "";
	displayItems();
}

buttonRefresh.addEventListener('click', function(){  generateStyle(); refreshItems();});

/*----------------------------------------------------------*/
/* 			DISPLAY/HIDE SIDEBAR AVEC LES FILTRES 			*/
/*----------------------------------------------------------*/

var switchButton = document.getElementsByClassName('switchButton')[0];
var sidebar = document.getElementsByClassName('sidebar')[0];

var topbar = document.getElementById('topbar');
var middlebar = document.getElementById('middlebar');
var bottombar = document.getElementById('bottombar');

function switchDisplay() {
	sidebar.classList.toggle('opened');
	topbar.classList.toggle('top');
	middlebar.classList.toggle('middle');
	bottombar.classList.toggle('bottom');
	if (sidebar.classList.contains('opened')){
		displayQuote();
	}
}

switchButton.addEventListener('click', switchDisplay);

/*----------------------------------------------------------*/
/* 				DISPLAY/HIDE MODAL A PROPOS		 			*/
/*----------------------------------------------------------*/

var modal = document.getElementsByClassName('modal')[0];
var close = document.getElementsByClassName("close")[0];

function checkLocalStorage() {
	if (localStorage.getItem('visited')) {
		modal.classList.replace("displayFlex", "displayNone");
	} else {
		localStorage.setItem('visited', 1);
		modal.classList.replace("displayNone", "displayFlex");
	}
}

function closeModal() {
	modal.classList.replace("displayFlex", "displayNone");
}

window.addEventListener('DOMContentLoaded', checkLocalStorage, false);
close.addEventListener('click', closeModal);

window.addEventListener('keypress', function(e) {
	if (e.keyCode == 13) {
		closeModal();
	}
});

/*----------------------------------------------------------*/
/* 						DISPLAY ITEMS 						*/
/*----------------------------------------------------------*/
function displayItems() {
	var req = new XMLHttpRequest();

	req.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			
			/* Recuperation */
			var items = JSON.parse(this.responseText);
			var main = document.getElementsByTagName('main')[0];

			/* Affichage */
			for (var i = 0; i < items.length; i++){
				main.innerHTML += displayItem(items[i]);
			}

			/* Refresh on click */
			var actualItems = document.getElementsByClassName('item');
			for (var i = actualItems.length - 1; i >= 0; i--) {
				actualItems[i].addEventListener('mouseup', checkButton);
				actualItems[i].addEventListener('click', refreshItems);
				actualItems[i].addEventListener('click', displayRefreshPhrase);
				actualItems[i].addEventListener('click', displayQuote);
			}
		}
	};
	
	req.open("GET", "http://localhost:3000/random-items");
	req.send();
}

function checkButton(event) {
	if (event.button == 1) {
		refreshItems();
		displayRefreshPhrase();
		displayQuote();
	}
}

function displayItem(item){
	var html = '<a class="item" href="' + item["ite_link"] + '" target="_blank" >' +
				'<figure>' +
					'<img src="' +  item["ite_enclosure"] +'" alt=""/> '+
					'<figcaption>'+ item["ite_title"] +'</figcaption>'+
				'</figure>' +
			'</a>';
	return html;
}

window.onload = displayItems();

/*----------------------------------------------------------*/
/* 						BTN REFRESH QUOTE 					*/
/*----------------------------------------------------------*/
function displayRefreshPhrase(){
	var req = new XMLHttpRequest();

	req.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {

			/* Recuperation */
			var phrase = JSON.parse(this.responseText)[0];
			var spanPhrase = document.getElementById('randomizePhrase');

			/* Affichage */
			spanPhrase.innerHTML = phrase["but_quote"];

			/* Refresh on click */
			var btnRefresh = document.getElementById('btnRefresh');
			btnRefresh.addEventListener('click', displayRefreshPhrase);
			btnRefresh.addEventListener('click', displayQuote);
		}
	};
	
	req.open("GET", "http://localhost:3000/random-btnQuote");
	req.send();
}

window.onload = displayRefreshPhrase();

/*----------------------------------------------------------*/
/* 							QUOTE 							*/
/*----------------------------------------------------------*/
function displayQuote(){
	var req = new XMLHttpRequest();

	req.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {

			/* Recuperation */
			var quote = JSON.parse(this.responseText)[0];
			var quoteSpan = document.getElementById('quote');

			/* Affichage */
			quoteSpan.innerHTML = quote["quo_quote"];
		}
	};
	
	req.open("GET", "http://localhost:3000/random-quote");
	req.send();
}

window.onload = displayQuote();

/*-----------------------------*/
/*            STYLE            */
/*-----------------------------*/
var styleLink = document.getElementById('style');
var logo = document.getElementById('logo');

function generateStyle() {

	if (styleLink.getAttribute('theme')) {
		var currentTheme = styleLink.getAttribute('theme');
	}

	var randomNumber = Math.floor(Math.random() * 5) + 1;

	if (randomNumber != currentTheme) {
		styleLink.setAttribute('theme', randomNumber);
    	styleLink.setAttribute('href', '../public/css/style'+randomNumber+'.css');
    	logo.setAttribute('src', '../public/img/logo'+randomNumber+'.png');
	} else {
		generateStyle();
	}
}

document.onload = generateStyle();
