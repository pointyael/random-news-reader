/*----------------------------------------------------------*/
/*                 DISPLAY/HIDE MODAL A PROPOS              */
/*----------------------------------------------------------*/
var modal = document.getElementsByClassName('modal')[0];
var modal2 = document.getElementsByClassName('modal')[1];
var close = document.getElementsByClassName("close")[0];
var redirect = document.getElementsByClassName("redirect")[0]; 
function redirectGoogleNews() {
	modal2.classList.replace("displayNone", "displayFlex");
	closeModal();
	setTimeout(function () {
		window.location.href = "https://news.google.com/";
	},
		2000);
} 
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
/* 					  REFRESH DE LA PAGE		 	   		*
/
/*----------------------------------------------------------*/
var main = document.getElementsByTagName('main')[0];
var buttonRefresh = document.getElementById('btnRefresh');

function refreshItems() {
	main.innerHTML = "";
	displayItems();
}

function generateAll(){
    closeSidebarMenu();
	generateStyle();
    refreshItems();
    displayRefreshPhrase();
	displayQuote();
	displayFiltres();
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
var randomNumber;

function generateStyle() {
	randomNumber = Math.floor(Math.random() * 5) + 1;

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
/*           GENERATE WEBRADIO URL 4 PLAYER                 */
/*----------------------------------------------------------*/
function random_item(items) {
    return items[Math.floor(Math.random() * items.length)];
}

var items = ["http://fluoz-01.radiojar.com/cyva9z92cq5tv?",
    "http://18193.live.streamtheworld.com/SAM08AAC038_SC",
    "http://icepe4.infomaniak.ch/african1libreville-128",
    "http://20073.live.streamtheworld.com/DUBAI_EYE.mp3",

    "http://audiostreaming.twesto.com/megafm214",
    "http://voninahi.radioca.st/stream?s=1442699748",
    "http://direct.fipradio.fr/live/fip-lofi.mp3",
    "http://direct.franceculture.fr/live/franceculture-lofi.mp3",
    "https://scdn.nrjaudio.fm/fr/40041/aac_64.mp3?listenerid=f6a67f2bed4300af15bafc911e7b22f9&awparams=companionAds:true;playerid:&origine=playernostalgie&cdn_path=audio_lbs8",
    "http://live02.rfi.fr/rfiafrique-64.mp3",
    "http://ice-the.musicradio.com/SmoothScotlandMP3",
    "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_cymru2_mf_p?s=1516894190&e=1516908590&h=541489170db3f643d57a07129afabdf4",
    "http://abc.ihrcast.arn.com.au/iHRabc20",
    "https://schlagerzone.stream.laut.fm/schlagerzone?ref=radiode&t302=2019-04-10_12-22-11&uuid=f58a72b2-57c6-401a-a9c4-56618678fa39",
    "http://radiocast.rtp.pt/rdpafrica80a.mp3",
    "http://icy.unitedradio.it/VirginHardRock.mp3",
    "http://stream.tmwradio.com/bianconera.aac",
    "http://server6.20comunicacion.com:8102/;stream.jh16",
    "https://dg-hr-https-dus-dtag-cdn.sslcast.addradio.de/hr/hrinfo/live/mp3/128/stream.mp3?r=252491",
    "http://dg-ndr-http-fra-dtag-cdn.cast.addradio.de/ndr/ndrinfo/hamburg/mp3/128/stream.mp3",
    "http://live.radiokiss.gr/kissfm1006hq.mp3",
    "http://icecast.omroep.nl/funx-arab-bb-mp3",
    "http://top.showlikes.com/uploads/tracks/1928097711_141640704_702738033.mp3",
    "ttp://icecast.vrtcdn.be/sporza-mid.mp3",
    "https://streaming.radio.co/sc46fb8389/listen",
    "http://audio1.video.ria.ru/voicerus",
    "http://listen.shoutcast.com/radiobudva",
    "http://icy.unitedradio.it/VirginHardRock.mp3",
    "http://ice.abradio.cz/metalomanie128.mp3",
    "http://http-live.sr.se/p1-mp3-192",
    "http://http-live.sr.se/p4norrbotten-aac-32",
    "http://stream.open.fm/34",
    "http://162.210.196.140/records/radiouser2633647/record.mp3",
    "http://edge.espn.cdn.abacast.net/espn-deportesmp3-48",
    "http://15383.live.streamtheworld.com/RADIO_CAPITAL_SC",
    "http://16613.live.streamtheworld.com/ADN_SC",
    "http://c13icy.prod.playlists.ihrhls.com/249_icy",
    "http://http.qingting.fm/live/386/64k.mp3",
    "http://http.qingting.fm/live/344/64k.mp3",
    "http://http.qingting.fm/live/387/64k.mp3",
    "https://prclive4.listenon.in/BollywoodMix",
    "http://bb30.sonixcast.com:9628/stream/1/?esPlayer&cb=923521.mp3",
    "https://musicbird.leanstream.co/JCB094-MP3?args=web_02&uid=c5a362ee-4906-472a-a60e-9a7ce18e9620",
    "http://d.liveatc.net/rjtt_twr",
    "http://ewr2.liveatc.net/rjtt_control",
    "http://icy3.abacast.com/dialglobal-nbcsportsmp3-48?token=9636270f1bc18d9810d54fef88670bd0%2F70fdd99d",
];

var srcRadio = document.getElementById("src_radio");
var player = document.getElementById('player');
var btnShuffle = document.getElementById('btnShuffle');

function generateRadio() {
    var radioSrc = random_item(items);

    if (radioSrc != null) {
        srcRadio.setAttribute('src', radioSrc);
		player.load();
		player.play();
    }
}

function addRadioURLToLS(){
	var urlRadio = srcRadio.src;
	localStorage.setItem('urlRadio', urlRadio);
}

function removeRadioURLToLS(){
	localStorage.removeItem('urlRadio');
}

player.addEventListener('play', function(){
	addRadioURLToLS();
});

// player.addEventListener('pause', function(){
// 	removeRadioURLToLS();
// });

btnShuffle.addEventListener('click', function(){
	// if (localStorage.getItem('urlRadio') != null){
	// 	removeRadioURLToLS();
	// }
	addRadioURLToLS();

});

document.addEventListener('DOMContentLoaded', function(){
	if (localStorage.getItem('urlRadio') != null){
		srcRadio.setAttribute('src', localStorage.getItem('urlRadio'));
		player.load();
	}
});

// window.onload = function(){
// 	if (localStorage.getItem('urlRadio') != null){
// 		srcRadio.setAttribute('src', localStorage.getItem('urlRadio'));
// 		player.load();
// 	}
// }

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
				if (items[i]!=null && items[i]['ite_id']!=null)
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
		if (checkboxs[i].checked && checkboxs[i].name === "filters"){
			if (exclusion == ""){
				exclusion += checkboxs[i].value;
			}
			else{
				exclusion += "+" + checkboxs[i].value;
			}
		}
	}

	for (var i = 0; i < recupererMaxIdCheckbox; i++) {
		if (localStorage.getItem('checkbox'+i) != null){
			if (exclusion == ""){
				exclusion = filterSelected;
			}
			else{
				exclusion += "+" + filterSelected;
			}
		}
	}

	var lang = document.querySelector('input[name="langFilter"]:checked').value;
	console.log(exclusion);
	if (exclusion != ""){
		req.open("GET", "http://localhost:3000/random-items/" + exclusion + "/" + lang );
		// 0 par defaut -> pas de filtre de langue choisi
	}
	else{
		req.open("GET", "http://localhost:3000/random-items/" + lang);
	}

	req.send();
}

var headerColor = ["#000", "#2b4162", "#FCF8CC", "#66bd84", "#000"];

function getRandomColor() {
	var letters = '0123456789ABCDEF';
	var color = '#';
	for (var i = 0; i < 6; i++) {
	  color += letters[Math.floor(Math.random() * 16)];
	}
	return color;
  }

function displayItem(item) {
	var html;
	let randomColor = getRandomColor();
	if(item){
		html = '<a class="item" href="' + item["ite_link"] + '" target="_blank" >' +
		'<figure>';
		if (item["ite_enclosure"] != null)
			// Là il y a moyen de faire du XSS mais c'est improbable donc ça va.
			html += '<img src="' + item["ite_enclosure"] + '" alt=""/> ';
		else{
			html += '<div class="imgBackgroundColor" style="background-color:' + randomColor + '"><img src="../public/img/brokenImage.png" class="broken-image"/> </div> ';
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
			var phrase = JSON.parse(this.responseText);
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

	req.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {

			/* Recuperation */
			var quote = JSON.parse(this.responseText);
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
var divFiltre = document.getElementById('keywordsFilter');

function displayFiltres() {
	divFiltre.innerHTML = "";
	var req = new XMLHttpRequest();

	req.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {

			/* Recuperation */
			var filtres = JSON.parse(this.responseText);

			/* Affichage */
			for (var i = 0; i < filtres.length; i++) {
				divFiltre.innerHTML += displayFiltre(filtres[i]);
			}

			var customFiltre = localStorage.getItem('checkbox'+(filtres.length+1).toString());
			if (customFiltre != null){
				displayFiltreIntoLS(customFiltre);
			}

			var actualFilters = document.getElementsByClassName('checkbox');
			for (var i = actualFilters.length - 1; i >= 0; i--) {
				if(actualFilters[i].name === "filters"){
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
		}
	};

	req.open("GET", "http://localhost:3000/random-defaultfilter");
	req.send();
}

function displayFiltre(filtre) {
	var html;
	if (filtre) {
		if (localStorage.getItem('checkbox' + filtre["fll_filtre"]) != filtre["fll_localise"])
			html = '<input type="checkbox" name="filters" id="checkbox' + filtre["fll_filtre"] + '" class="checkbox" value="' + filtre["fll_localise"] + '">';
		else
			html = '<input type="checkbox" name="filters" id="checkbox' + filtre["fll_filtre"] + '" class="checkbox" value="' + filtre["fll_localise"] + '" checked>';

		html += '<label class="label-check" for="checkbox' + filtre["fll_filtre"] + '">#' + filtre["fll_localise"].charAt(0).toUpperCase() + filtre["fll_localise"].slice(1) + '</label>';
	}
	return html;
}

function addFiltre(){
	var html;
	var inputValue = document.getElementById('inputFilter').value;
	html = '<input id="checkbox'+ recupererMaxIdCheckbox() +'" type="checkbox" class="checkbox" value="' + inputValue + '" checked>';
	html += '<label class="label-check" for="checkbox'+ recupererMaxIdCheckbox() +'">#' + inputValue.charAt(0).toUpperCase() + inputValue.slice(1) + '</label>';
	localStorage.setItem("checkbox"+ recupererMaxIdCheckbox(), inputValue);
	divFiltre.innerHTML += html;

	var filtresCourant = document.getElementsByClassName('checkbox');
	var checkboxName = ('checkbox' + Number(recupererMaxIdCheckbox()-1));
	document.getElementById(checkboxName).addEventListener('click', function(){
		localStorage.removeItem(checkboxName);
	});
}

function recupererMaxIdCheckbox(){
	var maxIdCheckbox = 0;
	var inputsFiltre = 	document.getElementsByClassName('checkbox');
	for (var i = 0; i < inputsFiltre.length; i++) {
		var inputFiltre = inputsFiltre[i];
		if (localStorage.getItem(inputFiltre.id) != null)
			inputFiltre.checked = true;
	}
	for (var i = 0; i < inputsFiltre.length; i++) {
		if (maxIdCheckbox < inputsFiltre[i].id.charAt(8)){
			maxIdCheckbox = inputsFiltre[i].id.charAt(8);
		};
	}
	return Number(maxIdCheckbox)+1;
}

function displayFiltreIntoLS(filtrePerso){
	var html;
	var inputValue = filtrePerso;
	html = '<input id="checkbox'+ recupererMaxIdCheckbox() +'" type="checkbox" class="checkbox" value="' + inputValue + '" checked>';
	html += '<label class="label-check" for="checkbox'+ recupererMaxIdCheckbox() +'">#' + inputValue.charAt(0).toUpperCase() + inputValue.slice(1) + '</label>';
	divFiltre.innerHTML += html;
}

var btnAjouterFiltre = document.getElementById('btnAjouterFiltre');
btnAjouterFiltre.addEventListener('click', addFiltre);

/*----------------------------------------------------------*/
/*                    CLOSE SIDEBAR MENU                    */
/*----------------------------------------------------------*/
function closeSidebarMenu(){
	document.getElementsByClassName('sidebar')[0].classList.remove('opened');

	topbar.classList.remove('top');
	middlebar.classList.remove('middle');
	bottombar.classList.remove('bottom');
}
