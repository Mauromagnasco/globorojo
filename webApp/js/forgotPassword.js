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
function onResetPassword( ){
	var email = $("#email").val();
	$.ajax({
        url: WS_PATH + "forgotPassword.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        data : { email : email },
        success : function(data){
            if(data.result == "success"){
                alert("Your password has been reset.\nCheck your email.");
            }else{
            	alert("This Email Address is not exist.");
            }
        }
    });		
}