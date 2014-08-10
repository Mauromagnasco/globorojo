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
var isLoaded = false;
var isLoading = false;
$(document).ready( function(){
	$("#notificationList").niceScroll();
	if( $("#isLogin").val() == "N" )
		return;
	fnChangeNotificationReadStatus( );
	var currentTime = $("#currentTime").val();
	$("#notificationList").html( "" );
	fnLoadNotification( 0, currentTime, 7 );
	
	$("#notificationList").scroll(function(e){
	    var scrollTop = $("#notificationList").scrollTop();
	    var scrollHeight = $("#notificationList").height();
	    var absoluteHeight = $("#notificationList").get(0).scrollHeight;
	    if( scrollTop + scrollHeight > absoluteHeight - 50 ){
	    	if( isLoading == true ) return;
	    	if( isLoaded == false ){
		    	var cntLoaded = $("#notificationList").find("div#notificationItem").length;
		    	var currentTime = $("#currentTime").val();
		    	fnLoadNotification( cntLoaded, currentTime, 7 );	    		
	    	}
	    }
	});		
	
});
function fnChangeNotificationReadStatus( ){
	$.ajax({
        url: WS_PATH + "setNotificationReadStatus.php",
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
        		
        	}
        }
	});	
}
function fnLoadNotification( cntLoaded, currentTime, cntLazyLoad ){
	isLoading = true;
	$("#loadingContainer").fadeIn();
	$.ajax({
        url: WS_PATH + "getNotificationList.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        data : { userId : CURRENT_USER_ID, cntLoaded : cntLoaded, currentTime : currentTime, cntLazyLoad : cntLazyLoad },
        success : function(data){
        	if(data.result == "success"){
        		for( var i = 0; i < data.notificationList.length; i ++ ){
        			var objClone = $("#cloneNotificationItem").clone();
        			objClone.show();
        			objClone.attr("id", "notificationItem");
        			objClone.find("#notificationItemPhoto").find("img").attr("src", data.notificationList[i].rb_sender_photo);
        			objClone.find("#notificationItemPhoto").attr("onclick", "window.location.href='profile.php?id=" + base64_encode(data.notificationList[i].rb_sender) + "'");
        			
    				var timeAgo;
    				var months = data.notificationList[i]['months'];
    				var days = data.notificationList[i]['days'];
    				var hours = data.notificationList[i]['hours'];
    				var minutes = data.notificationList[i]['minutes'];
    				var seconds = data.notificationList[i]['seconds'];
    				if( months == 1 ) timeAgo = "1 month ago";
    				else if( months > 1 ) timeAgo = months + " months ago";
    				else if( days == 1 ) timeAgo = "yesterday";
    				else if( days > 1 ) timeAgo = days + " days ago";
    				else if( hours == 1 ) timeAgo = "1 hour ago";
    				else if( hours > 1 ) timeAgo = hours + " hours ago";
    				else if( minutes == 1 ) timeAgo = " 1 minute ago";
    				else if( minutes > 1 ) timeAgo = minutes + " minutes ago";
    				else if( seconds > 0 ) timeAgo = seconds + " seconds ago";
    				else timeAgo = "undefined";
    				var content;
        			if( data.notificationList[i].rb_type == 1 ){
        				objClone.find("#notificationItemTitle").html( "<a href='profile.php?id=" + base64_encode( data.notificationList[i].rb_sender ) + "'>@" 
        						+ data.notificationList[i].rb_sender_username + "</a> commented your "
        						+ "<a href='/video.php?id=" + base64_encode( data.notificationList[i].rb_video ) + "'>post</a>" + " : " );
        				content = replaceUsername( data.notificationList[i].rb_content );
        				content = replaceHashtag( content );
        				// objClone.find("#notificationItemDescription").html( content );
        				objClone.find("#notificationItemDescription").html( '' );
        				objClone.find("#notificationItemTimeAgo").text( timeAgo );
        				objClone.find("#notificationItemContent").attr( "onclick", "window.location.href='/video.php?id=" + base64_encode( data.notificationList[i].rb_video ) + "';");
        			}else if( data.notificationList[i].rb_type == 2 ){
        				objClone.find("#notificationItemTitle").html( "<a href='profile.php?id=" + base64_encode( data.notificationList[i].rb_sender ) + "'>@" + data.notificationList[i].rb_sender_username + "</a> scored your " 
        						+ "<a href='/video.php?id=" + base64_encode( data.notificationList[i].rb_video ) + "'>post</a>" + " : " );
        				content = replaceUsername( data.notificationList[i].rb_content );
        				content = replaceHashtag( content );        				
        				objClone.find("#notificationItemDescription").html( content );
        				objClone.find("#notificationItemTimeAgo").text( timeAgo );
        				objClone.find("#notificationItemContent").attr( "onclick", "window.location.href='/video.php?id=" + base64_encode( data.notificationList[i].rb_video ) + "';");
        			}else if( data.notificationList[i].rb_type == 3 ){
        				objClone.find("#notificationItemTitle").html( "<a href='profile.php?id=" + base64_encode( data.notificationList[i].rb_sender ) + "'>@" + data.notificationList[i].rb_sender_username + "</a> is following you :" );
        				objClone.find("#notificationItemDescription").text( '' );
        				objClone.find("#notificationItemTimeAgo").text( timeAgo );
        				objClone.find("#notificationItemContent").attr( "onclick", "window.location.href='/profile.php?id=" + base64_encode( data.notificationList[i].rb_sender ) + "';");
        			}else if( data.notificationList[i].rb_type == 4 ){
        				objClone.find("#notificationItemTitle").html( "<a href='profile.php?id=" + base64_encode( data.notificationList[i].rb_sender ) + "'>@" + data.notificationList[i].rb_sender_username + "</a>" + " " 
        						+ "<a href='/video.php?id=" + base64_encode( data.notificationList[i].rb_video ) + "'>mentioned</a>" 
        						+ " you : " );
        				objClone.find("#notificationItemDescription").html( "" );        				
        				objClone.find("#notificationItemTimeAgo").text( timeAgo );
        				objClone.find("#notificationItemContent").attr( "onclick", "window.location.href='/video.php?id=" + base64_encode( data.notificationList[i].rb_video ) + "';");
        			}else if( data.notificationList[i].rb_type == 5 ){
        				objClone.find("#notificationItemTitle").html( "<a href='profile.php?id=" + base64_encode( data.notificationList[i].rb_sender ) + "'>@" + data.notificationList[i].rb_sender_username + "</a> is unfollowing you :" );
        				objClone.find("#notificationItemDescription").text( '' );
        				objClone.find("#notificationItemTimeAgo").text( timeAgo );
        				objClone.find("#notificationItemContent").attr( "onclick", "window.location.href='/profile.php?id=" + base64_encode( data.notificationList[i].rb_sender ) + "';");
        			}
        			objClone.find("#notificationItemPhoto").click( function( event){
        				event.preventDefault();
        			});
        			objClone.find("a.js-link").click(function (event){ 
        				event.preventDefault();
        				fnJsLink( this );
        			});	        			
        			$("#notificationList").append( objClone );
        		}
        		
                if( $("#notificationList").find("div#notificationItem").length == 0 ){
                	$("#notificationList").html( "<div class='noData'>There are no notifications.</div>" );
                }
                if( data.notificationList.length == 0 ){
                	isLoaded = true;
                }
            	isLoading = false;
            	$("#loadingContainer").fadeOut();        		
        		
        		$("#notificationList").getNiceScroll().resize();
        	}
        }
	});		
}