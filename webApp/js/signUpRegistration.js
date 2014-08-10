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
	var snsId = $("#userSnsId").val();
	$.ajax({
        url: WS_PATH + "signUpRegistration.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},
        data : { snsId : snsId },
        success : function(data){	
        	if(data.result == "success"){
        		$("#fullname").val( data.rb_nickname );
        		$("#email").val( data.rb_email );
        		$("#photo").val( data.rb_photo );
        	}
        }
	});	
});
function onSignUpRegistrationSubmit( ){
	var fullname = $("#fullname").val();
	var email = $("#email").val();
	var username = $("#username").val();
	var password = $("#password").val();
	var photo = $("#signUpPhoto").attr("src");
	var userSnsId = $("#userSnsId").val();
	if( fullname == "" ){ alert("Please input Full Name."); return;}
	if( email == "" ){ alert("Please input Email Address."); return;}
	if( username == "" ){ alert("Please input User Name."); return;}
	if( validateUsername(username) ){
		alert("Username mustn't include space, special characters."); return;
	}
	if( password == "" ){ alert("Please input Password."); return;}
   	$.ajax({
		type: "POST",
		url: WS_PATH + "signUpRegistration.php",
		data : { userSnsId : userSnsId, fullname : fullname, email : email, username : username, password : password, photo : photo },
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},		
		success: function(data) {
			if (data.result == 'success'){
				window.location.href = "index.php";
			}else if( data.result = 'failed' ){
				var userId = data.userId;
				if( confirm("Would you like to Login with Twitter?") ){
				   	$.ajax({
						type: "POST",
						url: WS_PATH + "signUpRegistrationMapping.php",
						data : { userSnsId : userSnsId, userId : userId },
				        beforeSend: function (request) {
				        	var timeStamp = getMicrotime(true).toString();
				        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
				        	request.setRequestHeader('X-MICROTIME', timeStamp );
						},						
						success: function(data) {
							if (data.result == 'success'){
								window.location.href = "login.php";
							}else{
								if( data.error == '1' )
									alert("Facebook is already connected on this account.");
								else if( data.error == '2' )
									alert("Twitter is already connected on this account.");
							}
						}
					});
				}else{
					return;
				}
			}
		}
	});
}