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
	// connected
	$.ajax({
        url: WS_PATH + "socialConnectedInfo.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},	        
        data : { userId : CURRENT_USER_ID },
        success : function(data){
            if(data.result == "success"){
            	$("#btnConnectFacebook").attr( "data", data.connectFacebook );
            	$("#btnConnectTwitter").attr( "data", data.connectTwitter );
            	
            	if( data.connectFacebook == "Y" )
            		$("#btnConnectFacebook").text("DISCONNECT FACEBOOK");
            	else
            		$("#btnConnectFacebook").text("CONNECT FACEBOOK");
            	
            	if( data.connectTwitter == "Y" )
            		$("#btnConnectTwitter").text("DISCONNECT TWITTER");
            	else
            		$("#btnConnectTwitter").text("CONNECT TWITTER");            	
            }
        }
    });
});
function onConnectFacebook( obj ){
	var status = $(obj).attr("data");
	var vid = $("#vid").val();
	if( status == "Y" ){
		// connected
		$.ajax({
	        url: WS_PATH + "socialDisconnect.php",
	        dataType : "json",
	        type : "POST",
	        beforeSend: function (request) {
	        	var timeStamp = getMicrotime(true).toString();
	        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
	        	request.setRequestHeader('X-MICROTIME', timeStamp );
			},	        
	        data : { userId : CURRENT_USER_ID, snsType : 1 },
	        success : function(data){
	            if(data.result == "success"){
	                $(obj).attr("data", "N");
	                $(obj).text("CONNECT FACEBOOK");
	            }
	        }
	    });				
	}else{
		// disconnected
	    FB.login(function(response) {
	    	   if (response.authResponse) {
	    		   	var accessToken = FB.getAuthResponse()['accessToken'];
	    		   	FB.api('/me', function(response) {
	 		  	   	$.ajax({
	 		  			type: "POST",
	 		  			url: WS_PATH + "facebookConnect.php",
	 		  			data : { userId : CURRENT_USER_ID, response : response, accessToken : accessToken },
	 		  	        beforeSend: function (request) {
	 		  	        	var timeStamp = getMicrotime(true).toString();
	 		  	        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
	 		  	        	request.setRequestHeader('X-MICROTIME', timeStamp );
	 		  			},	 		  			
	 		  			success: function(data) {
	 		  				if (data.result == 'success'){
	 		  					if( vid == "" ){
		 			                $(obj).attr("data", "Y");
		 			                $(obj).text("DISCONNECT FACEBOOK");	 		  						
	 		  					}else{
	 		  						window.location.href = "addVideo.php?vid=" + vid;
	 		  					}
	 		  					
	 		  				}else{
	 		  					alert("This account is already connected.");
	 		  					return;
	 		  				}
	 		  			}
	 		  		}); 		  	   	
	  		    });
	    	   } else {
	    		   
	    	   }
	    	 }, {scope: 'offline_access, publish_actions, email, publish_stream'}); 		
	}
}
function onConnectTwitter( obj ){
	var status = $(obj).attr("data");
	var vid = $("#vid").val();
	if( status == "Y" ){
		// connected
		$.ajax({
	        url: WS_PATH + "socialDisconnect.php",
	        dataType : "json",
	        type : "POST",
	        beforeSend: function (request) {
	        	var timeStamp = getMicrotime(true).toString();
	        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
	        	request.setRequestHeader('X-MICROTIME', timeStamp );
			},	        
	        data : { userId : CURRENT_USER_ID, snsType : 2 },
	        success : function(data){
	            if(data.result == "success"){
	                $(obj).attr("data", "N");
	                $(obj).text("CONNECT TWITTER");
	            }
	        }
	    });			
	}else{
		// disconnected
		if( vid == "" ){
			window.location.href = "twitter_login.php?type=connect";
		}else{
			window.location.href = "twitter_login.php?type=connect&vid=" + vid;
		}
		
	}	
}