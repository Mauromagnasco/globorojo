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
            	$("#isFacebook").val( data.connectFacebook );
            	$("#isTwitter").val( data.connectTwitter );
            	onClickSocialItem( $("#socialTab").find("#socialItem").get(0) );            	
            }
        }
    });	
});
function onClickSocialItem( obj ){
	if( $(obj).hasClass("greyHighlightSelected") ) return;
	$(obj).parents("#socialTab").find("div#socialItem").removeClass("greyHighlightSelected");
	$(obj).addClass("greyHighlightSelected");
	$("#userList").html( "" );
	if( $(obj).parents("#socialTab").find("div#socialItem").index( $(obj) ) == 0 ){
		if( $("#isFacebook").val() == "N" ){
			$("#userList").html( '<div class="socialUnconnected">Facebook is not connected.</div>' 
					+ '<button onclick="window.location.href=\'application.php\'" class="form-control textCommon greySelected bordernone" style="margin-top: 60px;">APPLICATIONS</button>' );			
		}else{
			$.ajax({
		        url: WS_PATH + "facebookFriends.php",
		        dataType : "json",
		        type : "POST",
		        data : { userId : CURRENT_USER_ID},
		        beforeSend: function (request) {
		        	var timeStamp = getMicrotime(true).toString();
		        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
		        	request.setRequestHeader('X-MICROTIME', timeStamp );
				},		        
		        success : function(data){
		        	if( data.result == "success" ){
		        		for( var i = 0 ; i < data.userList.length; i ++ ){
		        			var objClone = $("#cloneUserItem").clone();
		        			objClone.show();
		        			objClone.attr("id", "userItem");
		        			objClone.find("#userId").val( data.userList[i].rb_user );
		        			objClone.find("#userItemPhoto").attr("src", data.userList[i].rb_photo );
		        			objClone.find("#userItemPhoto").attr("onclick", "window.location.href='profile.php?id=" + base64_encode(data.userList[i].rb_user) + "'");
		        			
		            		var strUsername = "@" + data.userList[i].rb_username;
		            		strUsername = "<a href='/profile.php?id=" + base64_encode( data.userList[i].rb_user ) + "'>" + strUsername + "</a>";        			
		        			
		        			objClone.find("#userItemUsername").html( strUsername );
		        			objClone.find("#userItemName").text( data.userList[i].rb_name );
		        			objClone.find("#userItemCredTxt").text( "Meri.to : " + data.userList[i].rb_cred );
		        			
		            		var roundCred = Math.round( data.userList[i].rb_cred );
		            		objClone.find("#userItemCredGraph").addClass( "whiteScore" + roundCred );
		            		objClone.find("#userItemCredGraph").attr("onclick", "window.location.href='/profile.php?id=" + base64_encode( data.userList[i].rb_user )+ "';");
		        			$("#userList").append( objClone );
		        		}
		        		if( data.userList.length == 0 ){
		        			$("#userList").html( '<div class="socialUnconnected">There are no Facebook friends.</div>' );
		        		}
		        	}else{
		        		$("#userList").html( '<div class="socialUnconnected">Facebook is not connected.</div>' );
		        	}
		        }
			});			
		}
	}else if( $(obj).parents("#socialTab").find("div#socialItem").index( $(obj) ) == 1 ){
		if( $("#isTwitter").val() == "N" ){
			$("#userList").html( '<div class="socialUnconnected">Twitter is not connected.</div>' 
					+ '<button onclick="window.location.href=\'application.php\'" class="form-control textCommon greySelected bordernone" style="margin-top: 60px;">APPLICATIONS</button>' );
		}else{
			$.ajax({
		        url: WS_PATH + "twitterFriends.php",
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
		        		for( var i = 0 ; i < data.userList.length; i ++ ){
		        			var objClone = $("#cloneUserItem").clone();
		        			objClone.show();
		        			objClone.attr("id", "userItem");
		        			objClone.find("#userId").val( data.userList[i].rb_user );
		        			objClone.find("#userItemPhoto").attr("src", data.userList[i].rb_photo );
		        			objClone.find("#userItemPhoto").attr("onclick", "window.location.href='profile.php?id=" + base64_encode(data.userList[i].rb_user) + "'");
		        			
		            		var strUsername = "@" + data.userList[i].rb_username;
		            		strUsername = "<a href='/profile.php?id=" + base64_encode( data.userList[i].rb_user ) + "'>" + strUsername + "</a>";        			
		        			
		        			objClone.find("#userItemUsername").html( strUsername );
		        			objClone.find("#userItemName").text( data.userList[i].rb_name );
		        			objClone.find("#userItemCredTxt").text( "Meri.to : " + data.userList[i].rb_cred );
		        			
		            		var roundCred = Math.round( data.userList[i].rb_cred );
		            		objClone.find("#userItemCredGraph").addClass( "whiteScore" + roundCred );
		            		objClone.find("#userItemCredGraph").attr("onclick", "window.location.href='/profile.php?id=" + base64_encode( data.userList[i].rb_user )+ "';");
		        			$("#userList").append( objClone );
		        		}
		        		if( data.userList.length == 0 ){
		        			$("#userList").html( '<div class="socialUnconnected">There are no Twitter friends.</div>' );
		        		}
		        	}else{
		        		$("#userList").html( '<div class="socialUnconnected">Twitter is not connected.</div>' );
		        	}
		        }
			});				
		}
	}
}