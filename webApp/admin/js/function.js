/**
 * Globo Rojo open source application
 *
 *  Copyright © 2013, 2014 by Mauro Magnasco <mauro.magnasco@gmail.com>
 *
 *  Licensed under GNU General Public License 2.0 or later.
 *  Some rights reserved. See COPYING, AUTHORS.
 *
 * @license GPL-2.0+ <http://spdx.org/licenses/GPL-2.0+>
 */
function onSignOut( ){
	$.ajax({
        url: "async-signOut.php",
        dataType : "json",
        type : "POST",
        data : {  },
        success : function(data){
            if(data.result == "success"){
                window.location.href = "index.php";
            }
        }
    });	
			
}