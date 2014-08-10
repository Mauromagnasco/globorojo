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
	
	$("#username").keyup( function(event){
		if( event.keyCode == 13 )
			$("#email").focus();
	});
	
	$("#email").keyup( function(event){
		if( event.keyCode == 13 )
			$("#password").focus();
	});
	
	$("#password").keyup( function(event){
		if( event.keyCode == 13 )
			onSignupSubmit();
	});
});
function onSignupSubmit(){
	var username = $("#username").val();
	var email = $("#email").val();
	var password = $("#password").val();
	if( username == "" ){ alert("Please input the Username."); return; }

	if( validateUsername(username) ){
		alert("Username mustn't include space, special characters."); return;
	}
	if( email == "" ){ alert("Please input the Email Address."); return; }
	if( password == "" ){ alert("Please input the Password."); return; }
	if( !validateEmail( email ) ){ alert("Please input the Email Address correctly."); return; }
	
	$.ajax({
        url: WS_PATH + "signUpSubmit.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        data : { username : username , email : email, password : password },
        success : function(data){
            if(data.result == "success"){
                alert("Your account registered successfully.");
                window.location.href = "index.php";
                return;
            }else if( data.result == "failed" ){
            	alert("This account is already registered.");
            	return;
            }
        }
    });
}
function onSignUpFB(){
    FB.login(function(response) {
   	   if (response.authResponse) {
   		   	var accessToken = FB.getAuthResponse()['accessToken'];
   		   	FB.api('/me', function(response) {
		  	   	$.ajax({
		  			type: "POST",
		  			url: WS_PATH + "signUpFacebook.php",
		  	        beforeSend: function (request) {
		  	        	var timeStamp = getMicrotime(true).toString();
		  	        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
		  	        	request.setRequestHeader('X-MICROTIME', timeStamp );
		  			},
		  			data : { snsId : response.id, username : response.username, name : response.name, email : response.email, token : accessToken },
		  			success: function(data) {
		  				if (data.result == 'success'){
		  					if( data.firstYn == "Y" ){
		  						window.location.href = "index.php";	
		  					}else{
		  						alert( "This account is already registered." );
		  					}
		  				}else{
		  					if( data.error == "EMAIL_EXIST" ){
		  						alert( "This Email is already registered." );
		  					}
		  				}
		  			}
		  		}); 		  	   	
 		    });
   	   } else {
   	   }
   	 }, {scope: 'offline_access, publish_actions, email, publish_stream'}); 
}