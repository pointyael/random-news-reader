/*----------------------------------------------------------*/
/* 					  REFRESH DE LA PAGE		 	   		*/
/*----------------------------------------------------------*/
var buttonRefresh = document.getElementById('btnRefresh');
var main = document.getElementsByTagName('main')[0];

function refreshItems() {
	main.innerHTML = "";
	displayItems();
}

buttonRefresh.addEventListener('click', function () {
	generateStyle();
	refreshItems();
	closeSidebarMenu();
});

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
	if (sidebar.classList.contains('opened')) {
		displayQuote();
	}
}

function displayFiltres(){
	var req = new XMLHttpRequest();

	req.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {

			/* Recuperation */
			var filtres = JSON.parse(this.responseText);
			var divFiltre = document.getElementById('keywordsFilter');

			/* Affichage */
			for (var i = 0; i < filtres.length; i++) {
				divFiltre.innerHTML += displayFiltre(filtres[i]);
			}
		}
	};
	
	req.open("GET", "http://localhost:3000/random-defaultfilter");
	req.send();
}

function displayFiltre(filtre) {
	var html;
	if(filtre)	{
		html = '<input type="checkbox" id="checkbox' + filtre["fll_filtre"] + '" class="checkbox" value="'+ filtre["fll_localise"] +'">' + 
		'<label class="label-check" for="checkbox' + filtre["fll_filtre"]+ '">#' + filtre["fll_localise"].charAt(0).toUpperCase() + filtre["fll_localise"].slice(1) + '</label>';
	}
	return html;
}

switchButton.addEventListener('click', switchDisplay);

window.onload = displayFiltres();

/*----------------------------------------------------------*/
/* 				DISPLAY/HIDE MODAL A PROPOS		 			*/
/*----------------------------------------------------------*/

var modal = document.getElementsByClassName('modal')[0];
var modal2 = document.getElementsByClassName('modal')[1];
var close = document.getElementsByClassName("close")[0];
var redirect = document.getElementsByClassName("redirect")[0];

function redirectGoogleNews() {
	modal2.classList.replace("displayNone", "displayFlex");
	closeModal();
	setTimeout( function() { window.location.href = "https://news.google.com/";
	},
	2000);
}

function checkLocalStorage() {
	if (localStorage.getItem('visited')) {
		closeModal();
	} else {
		openModal();
	}
}

function setLocalStorage() {
	localStorage.setItem('visited', 1);
}

function closeModal() {
	modal.classList.replace("displayFlex", "displayNone");
}

function openModal() {
	modal.classList.replace("displayNone", "displayFlex");
}

redirect.addEventListener('click', redirectGoogleNews);

close.addEventListener('click', closeModal);
close.addEventListener('click', setLocalStorage);

window.addEventListener('DOMContentLoaded', checkLocalStorage, false);
window.addEventListener('keypress', function (e) {
	if (e.keyCode == 13) {
		closeModal();
		setLocalStorage();
	}
});

/*----------------------------------------------------------*/
/* 						DISPLAY ITEMS 						*/
/*----------------------------------------------------------*/
function displayItems() {
	var req = new XMLHttpRequest();

	req.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {

			/* Recuperation */
			var items = JSON.parse(this.responseText);
			var main = document.getElementsByTagName('main')[0];

			/* Affichage */
			for (var i = 0; i < items.length; i++) {
				main.innerHTML += displayItem(items[i]);
			}

			/* Refresh on click */
			var actualItems = document.getElementsByClassName('item');
			for (var i = actualItems.length - 1; i >= 0; i--) {
				actualItems[i].addEventListener('mouseup', checkButton);
				actualItems[i].addEventListener('click', function(){
					refreshItems();
					displayRefreshPhrase();
					displayQuote();
					generateStyle();
					closeSidebarMenu();
				});
			}
		}
	};

	var exclusion="";
	var checkboxs = document.getElementsByClassName('checkbox');
	for (var i = 0; i < checkboxs.length; i++){
		if (checkboxs[i].checked){
			if (exclusion == ""){
				exclusion += checkboxs[i].value;
			}
			else{
				exclusion += "+" + checkboxs[i].value;
			}
		}
	}

	if (exclusion != ""){
		req.open("GET", "http://localhost:3000/random-items/"+exclusion);
	}
	else{
		req.open("GET", "http://localhost:3000/random-items");
	}

	req.send();
}

function checkButton(event) {
	if (event.button == 1) {
		refreshItems();
		displayRefreshPhrase();
		displayQuote();
	}
}

function displayItem(item) {
	var html;
	if(item){
		if (item["ite_enclosure"] != null)
			image = item["ite_enclosure"];
		else
			image = '/public/img/GoldfishNews.png';
		html = '<a class="item" href="' + item["ite_link"] + '" target="_blank" >' +
		'<figure>' +
		'<img src="' + image + '" alt="" /> ' +
		'<figcaption>' + item["ite_title"] + '</figcaption>' +
		'</figure>' +
		'</a>';
	}
	return html;
}

window.onload = displayItems();

/*----------------------------------------------------------*/
/* 					BTN REFRESH QUOTE 						*/
/*----------------------------------------------------------*/
function displayRefreshPhrase() {
	var req = new XMLHttpRequest();

	req.onreadystatechange = function () {
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
function displayQuote() {
	var req = new XMLHttpRequest();

	req.onreadystatechange = function () {
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
		styleLink.setAttribute('href', '../public/css/style' + randomNumber + '.css');
		logo.setAttribute('src', '../public/img/logo' + randomNumber + '.png');
	} else {
		generateStyle();
	}
}

document.onload = generateStyle();

/*----------------------------------------------------------*/
/*                    CLOSE SIDEBAR MENU                    */
/*----------------------------------------------------------*/
function closeSidebarMenu(){
	document.getElementsByClassName('sidebar')[0].classList.remove('opened');

	topbar.classList.remove('top');
	middlebar.classList.remove('middle');
	bottombar.classList.remove('bottom');
}
