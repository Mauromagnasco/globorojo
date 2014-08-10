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
	$("img#imgEmailNotifications").click( function(){
		if( $(this).attr("src") == "/img/btnUnchecked.png" ){
			$(this).attr("src", "/img/btnChecked.png");
		}else{
			$(this).attr("src", "/img/btnUnchecked.png");
		}
	});
	$.ajax({
        url: WS_PATH + "getEmailNotificationStatus.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},
        data : { userId : CURRENT_USER_ID },
        success : function(data){	
        	if( data.result == "success" ){
        		if( data.mentionYn == "Y" )
        			$("img#imgEmailNotifications").eq(0).attr("src", "/img/btnChecked.png");
        		else
        			$("img#imgEmailNotifications").eq(0).attr("src", "/img/btnUnchecked.png");
        		
        		if( data.scoreYn == "Y" )
        			$("img#imgEmailNotifications").eq(1).attr("src", "/img/btnChecked.png");
        		else
        			$("img#imgEmailNotifications").eq(1).attr("src", "/img/btnUnchecked.png");
        		
        		if( data.commentYn == "Y" )
        			$("img#imgEmailNotifications").eq(2).attr("src", "/img/btnChecked.png");
        		else
        			$("img#imgEmailNotifications").eq(2).attr("src", "/img/btnUnchecked.png");
        		
        		if( data.followYn == "Y" )
        			$("img#imgEmailNotifications").eq(3).attr("src", "/img/btnChecked.png");
        		else
        			$("img#imgEmailNotifications").eq(3).attr("src", "/img/btnUnchecked.png");
        		
        		if( data.unfollowYn == "Y" )
        			$("img#imgEmailNotifications").eq(4).attr("src", "/img/btnChecked.png");
        		else
        			$("img#imgEmailNotifications").eq(4).attr("src", "/img/btnUnchecked.png");        		
        		
        	}
        }
	});		
});
function onSaveEmailNotifications( ){
	var mentionYn = $("img#imgEmailNotifications").eq(0).attr("src") == "/img/btnChecked.png" ? "Y" : "N";
	var scoreYn = $("img#imgEmailNotifications").eq(1).attr("src") == "/img/btnChecked.png" ? "Y" : "N";
	var commentYn = $("img#imgEmailNotifications").eq(2).attr("src") == "/img/btnChecked.png" ? "Y" : "N";
	var followYn = $("img#imgEmailNotifications").eq(3).attr("src") == "/img/btnChecked.png" ? "Y" : "N";
	var unfollowYn = $("img#imgEmailNotifications").eq(4).attr("src") == "/img/btnChecked.png" ? "Y" : "N";

	$.ajax({
        url: WS_PATH + "saveEmailNotificationStatus.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        data : { userId : CURRENT_USER_ID, mentionYn : mentionYn, scoreYn : scoreYn, commentYn : commentYn, followYn : followYn, unfollowYn : unfollowYn },
        success : function(data){
        	if( data.result == "success" ){
        		alert("Email Notification Setting has been saved.");
        		window.location.href = "profile.php";
        		return;
        	}
        }
	});	
}