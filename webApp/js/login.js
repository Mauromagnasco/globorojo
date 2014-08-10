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
	$("#email").keyup( function(event){
		if( event.keyCode == 13 )
			$("#password").focus( );
	});	
	$("#password").keyup( function(event){
		if( event.keyCode == 13 )
			onLoginSubmit();
	});
});
function onLoginSubmit(){
	var email = $("#email").val();
	var password = $("#password").val();
	if( email == "" ){ alert("Please input the Email Address."); return; }
	if( password == "" ){ alert("Please input the Password."); return; }
	$.ajax({
        url: WS_PATH + "loginSubmit.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},
        data : { email : email, password : password },
        success : function(data){
            if(data.result == "success"){
                $.cookie("RB_USER", data.userId, { expires: 2 * 7 });
                window.location.href = "search.php";
                return;
            }else if( data.result == "failed" ){
            	alert("Login Failed.");
            	return;
            }
        }
    });
}
function onLoginFB(){
    FB.login(function(response) {
   	   if (response.authResponse) {
   		   	var accessToken = FB.getAuthResponse()['accessToken'];
   		   	FB.api('/me', function(response) {
		  	   	$.ajax({
		  			type: "POST",
		  			url: WS_PATH + "loginSocial.php",
		  			data : { snsId : response.id, snsType : 1 },
		  	        beforeSend: function (request) {
		  	        	var timeStamp = getMicrotime(true).toString();
		  	        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
		  	        	request.setRequestHeader('X-MICROTIME', timeStamp );
		  			},		  			
		  			success: function(data) {
		  				if (data.result == 'success'){
		  					$.cookie("RB_USER", data.userId, { expires: 2 * 7 });
		  					window.location.href = "index.php";
		  				}else{
		  					alert("This account is not registered.");
		  				}
		  			}
		  		}); 		  	   	
 		    });
   	   } else {
   		   
   	   }
   	 }, {scope: 'offline_access, publish_actions, email, publish_stream'}); 
}