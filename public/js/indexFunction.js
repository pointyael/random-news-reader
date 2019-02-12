/*----------------------------------------------------------*/
/* 					  REFRESH DE LA PAGE		 	   		*/
/*----------------------------------------------------------*/

function refreshItems() {
	var main = document.getElementsByTagName('main')[0];
	main.innerHTML = "";
	displayItems();
}

document.getElementsByClassName('float')[0].addEventListener('click', refreshItems);

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


/*----------------------------------------------------------*/
/* 							ITEMS 							*/
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
				actualItems[i].addEventListener('click', refreshItems);
			}
		}
	};
	
	req.open("GET", "http://localhost:3000/random-items");
	req.send();
}

function displayItem(item){
	var html = '<a class="item" href="' + item["ite_link"] + '" target="_blank" >' +
				'<figure>' +
					'<img src="https://www.freeiconspng.com/uploads/no-image-icon-13.png" alt=""/> '+
					'<figcaption>'+ item["ite_name"] +'</figcaption>'+
				'</figure>' +
			'</a>';
	return html;
}

window.onload = displayItems();
