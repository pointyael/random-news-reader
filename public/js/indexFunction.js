/*----------------------------------------------------------*/
/* 					  REFRESH DE LA PAGE		 	   		*/
/*----------------------------------------------------------*/

function refreshPage() {
	/* appel de la fonction qui randomize le fil d'actualité */
}

document.getElementsByClassName('float')[0].addEventListener('click', refreshPage);

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