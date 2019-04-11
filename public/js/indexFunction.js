/*----------------------------------------------------------*/
/* 				DISPLAY/HIDE MODAL DISCLAIMER	 			*/
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

window.addEventListener('keypress', function (e) {
	if (e.keyCode == 13) {
		closeModal();
	}
});

/*----------------------------------------------------------*/
/* 					  REFRESH DE LA PAGE		 	   		*/
/*----------------------------------------------------------*/
var main = document.getElementsByTagName('main')[0];
var buttonRefresh = document.getElementById('btnRefresh');

function refreshItems() {
	main.innerHTML = "";
	displayItems();
}

function generateAll(){
    closeSidebarMenu();
	// generateStyle();
    refreshItems();
    displayRefreshPhrase();
    displayQuote();
}

buttonRefresh.addEventListener('click', generateAll);

window.onload = function(){
	generateStyle();
	refreshItems();
	displayRefreshPhrase();
	displayQuote();
	displayFiltres();
};

/*-----------------------------*/
/*            STYLE            */
/*-----------------------------*/
var styleLink = document.getElementById('style');
var logo = document.getElementById('logo');
var randomNumber = Math.floor(Math.random() * 5) + 1;

function generateStyle() {

	if (styleLink.getAttribute('theme')) {
		var currentTheme = styleLink.getAttribute('theme');
	}

	if (randomNumber != currentTheme) {
		styleLink.setAttribute('theme', randomNumber);
		styleLink.setAttribute('href', '../public/css/style' + randomNumber + '.css');
		logo.setAttribute('src', '../public/img/logo' + randomNumber + '.png');
	} else {
		generateStyle();
	}
}

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
				if (items[i]['ite_id']!=null)
					main.innerHTML += displayItem(items[i]);
			}

			/* Refresh on click */
			var actualItems = document.getElementsByClassName('item');
			for (var i = actualItems.length - 1; i >= 0; i--) {
				actualItems[i].addEventListener('mouseup', checkButton);
				actualItems[i].addEventListener('click', generateAll);
				var actualImage = actualItems[i].children[0].firstChild;
				if (actualImage.src.includes('/public/img/logo')){
					actualImage.style.backgroundColor = headerColor[randomNumber-1];
				};
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

	for (var i = 0; i < 5; i++) {
		if (localStorage.getItem('checkbox'+i) != null){
			if (exclusion == ""){
				exclusion = localStorage.getItem('checkbox'+i);
			}
			else{
				exclusion += "+" + localStorage.getItem('checkbox'+i);
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

var headerColor = ["#000", "#2b4162", "#FCF8CC", "#66bd84", "#000"];

function displayItem(item) {
	var html;
	if(item){
		html = '<a class="item" href="' + item["ite_link"] + '" target="_blank" >' +
		'<figure>';
		if (item["ite_enclosure"] != null)
			html += '<img src="' + item["ite_enclosure"] + '" alt=""/> ';
		else{
			html += '<img src="./public/img/logo' + randomNumber + '.png" alt=""/> ';
		}
		html +='<figcaption>' + item["ite_title"] + '</figcaption>' +
		'</figure>' +
		'</a>';
	}
	return html;
}

function checkButton(event) {
	if (event.button == 1) {
		closeSidebarMenu();
		refreshItems();
		displayRefreshPhrase();
	}
}

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
			btnRefresh.addEventListener('click', generateAll);
		}
	};

	req.open("GET", "http://localhost:3000/random-btnQuote");
	req.send();
}

/*----------------------------------------------------------*/
/*       	   		DISPLAY/HIDE SIDEBAR                  	*/
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

switchButton.addEventListener('click', switchDisplay);

/*----------------------------------------------------------*/
/* 					    DISPLAY QUOTE 						*/
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

/*----------------------------------------------------------*/
/* 					DISPLAY LES FILTRES 					*/
/*----------------------------------------------------------*/
function displayFiltres() {
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

			var actualFilters = document.getElementsByClassName('checkbox');
			for (var i = actualFilters.length - 1; i >= 0; i--) {
				actualFilters[i].addEventListener('change', function(){
					if (this.checked){
						localStorage.setItem(this.id, this.value);
					}
					else{
						localStorage.removeItem(this.id);
					}
				});
			}
		}
	};

	req.open("GET", "http://localhost:3000/random-defaultfilter");
	req.send();
}

function displayFiltre(filtre) {
	var html;
	if (filtre) {
		if (localStorage.getItem('checkbox' + filtre["fll_filtre"]) == filtre["fll_localise"])
			html = '<input type="checkbox" id="checkbox' + filtre["fll_filtre"] + '" class="checkbox" value="' + filtre["fll_localise"] + '" checked>';
		else
			html = '<input type="checkbox" id="checkbox' + filtre["fll_filtre"] + '" class="checkbox" value="' + filtre["fll_localise"] + '">';
			
		html += '<label class="label-check" for="checkbox' + filtre["fll_filtre"] + '">#' + filtre["fll_localise"].charAt(0).toUpperCase() + filtre["fll_localise"].slice(1) + '</label>';
	}
	return html;
}

/*----------------------------------------------------------*/
/*                    CLOSE SIDEBAR MENU                    */
/*----------------------------------------------------------*/
function closeSidebarMenu(){
	document.getElementsByClassName('sidebar')[0].classList.remove('opened');

	topbar.classList.remove('top');
	middlebar.classList.remove('middle');
	bottombar.classList.remove('bottom');
}
