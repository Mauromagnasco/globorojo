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
$(document).ready( function(){
	$("#username").focus();
	$("#password").keyup( function(event){
		if( event.keyCode == 13 ){
			onSignInSubmit();
		}
	})
});
function onSignInSubmit( ){
	var username = $("#username").val( );
	var password = $("#password").val( );
	$.ajax({
        url: "async-signIn.php",
        dataType : "json",
        type : "POST",
        data : { username : username, password : password },
        success : function(data){
            if(data.result == "success"){
                window.location.href = "index.php";
                return;
            }else{
            	alert("Username and Password is incorrect.");
            	$("#username").focus();
            	return;
            }
        }
    });		
}