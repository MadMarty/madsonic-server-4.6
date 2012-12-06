
/// Default

function noop() {
}

function popup(mylink, windowname) {
    return popupSize(mylink, windowname, 400, 200);
}

function popupSize(mylink, windowname, width, height) {
    var href;
    if (typeof(mylink) == "string") {
        href = mylink;
    } else {
        href = mylink.href;
    }

    var w = window.open(href, windowname, "width=" + width + ",height=" + height + ",scrollbars=yes,resizable=yes");
    w.focus();
    w.moveTo(300, 200);
    return false;
}

/// Row&Columns

function refreshPage() {
	window.location.href = window.location.href;
}

function persistentTopLinks(newURI, follow) {
    var id;
    var follow = (typeof(follow)=="undefined") ? true : follow;
    var url = this.location;
    var m = url.toString().match(/.*\/(.+?)\./);
    if (m[1].match(/^.*Settings$/)) {
        m[1] = "settings";
    }
    switch (m[1]) {
        case "home": id = "homeLink"; break
        case "podcastReceiver": id = "podcastLink"; break
        case "status": id = "statusLink"; break
        case "more": case "db": id = "moreLink"; break
        case "logfile": id = "statusLink"; break
        case "settings": id = "settingsLink"; break
    }
    parent.upper.document.getElementById(id).href = newURI;
    parent.upper.document.getElementById(id + "Desc").href = newURI;
    if (follow) {
        parent.main.src = newURI;
        location = newURI;
    }
}

/// Add similar artists

(function() {
	
	Node.prototype.insertAfter = function(newNode, refNode) {
		if(refNode.nextSibling) {
			return this.insertBefore(newNode, refNode.nextSibling);
		} else {
			return this.appendChild(newNode);
		}
	};
	
	var loaded = function() {
		load.injectDependency('./script/similar_artists/similar_artists.js');
	};
	
    var load = function() {
    	load.injectDependency('./script/jquery-1.7.1.min.js');
    	load.tryReady(0);
    };
    
    load.injectDependency = function(script) {
        var sa = document.createElement('script');
        sa.type = 'text/javascript';
        sa.async = 'async';
        sa.src = script;
        var s = document.getElementsByTagName('script')[0];
        s.parentNode.insertAfter(sa, s);
    };
    
    load.tryReady = function(time_elapsed) {
    	// Continually polls to see if jQuery is loaded.
		
    	if(typeof(jQuery) === undefined) { // if jQuery isn't loaded yet...
		
    		if (time_elapsed <= 15000) { // and we havn't given up trying...
    			setTimeout(function() {
    				load.tryReady(200);
    			}, 200);
    		}
    		else {
    			alert("Timed out while loading jQuery.");
    		}
    	}
    	else {
    		loaded();
    	}
	};
	
	load();
})();
  
  