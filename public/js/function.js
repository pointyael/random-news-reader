/*----------------------------------------------------------*/
/* 					  REFRESH DE LA PAGE		 	   		*/
/*----------------------------------------------------------*/

function refreshPage() {
    location.reload();
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