/*----------------------------------------------------------*/
/* 					  REFRESH DE LA PAGE		 	   		*/
/*----------------------------------------------------------*/
var buttonRefresh = document.getElementById('btnRefresh');
var main = document.getElementsByTagName('main')[0];

function refreshItems() {
    main.innerHTML = "";
    displayItems();
}

buttonRefresh.addEventListener('click', function() {
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

switchButton.addEventListener('click', switchDisplay);

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
    setTimeout(function() {
            window.location.href = "https://news.google.com/";
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
window.addEventListener('keypress', function(e) {
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

    req.onreadystatechange = function() {
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
                actualItems[i].addEventListener('click', function() {
                    refreshItems();
                    displayRefreshPhrase();
                    displayQuote();
                    generateStyle();
                    closeSidebarMenu();
                });
            }
        }
    };

    var exclusion = "";
    var checkboxs = document.getElementsByClassName('checkbox');
    for (var i = 0; i < checkboxs.length; i++) {
        if (checkboxs[i].checked) {
            if (exclusion == "") {
                exclusion += checkboxs[i].value;
            } else {
                exclusion += "+" + checkboxs[i].value;
            }
        }
    }

    if (exclusion != "") {
        req.open("GET", "http://localhost:3000/random-items/" + exclusion);
    } else {
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
    if (item) {
        html = '<a class="item" href="' + item["ite_link"] + '" target="_blank" >' +
            '<figure>' +
            '<img src="' + item["ite_enclosure"] + '" alt=""/> ' +
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
function displayQuote() {
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
function closeSidebarMenu() {
    document.getElementsByClassName('sidebar')[0].classList.remove('opened');

    topbar.classList.remove('top');
    middlebar.classList.remove('middle');
    bottombar.classList.remove('bottom');
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
    "ttp://streamerepsilon.jazz.fm:8000/;stream.5h9c",
    "http://64.78.234.165:8030/BizTalkRadio?tok=484522873bnvu1fUXj0s3KENvq9UusRon0MKTFhqhu2JAAAAAAAAAAAAAAAAAA%3D"
];

function generateRadio() {
    var radioSrc = random_item(items);
    console.log(radioSrc);
    if (radioSrc != null) {
        document.getElementById("src_radio").setAttribute('src', radioSrc);
        document.getElementById('player').load();
    }
}