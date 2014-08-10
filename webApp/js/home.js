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
var isLoading = false;
var isLoaded = false;
$(document).ready( function(){
	$("#homeVideoList").niceScroll( );
	isNewNotificationExist( );
	// Changing the Tab
	$("div#homeOrderModeItem").click( function(e){
		if( isLoading == true ) return;
		$(this).parents("#homeOrderMode").eq(0).find("div#homeOrderModeItem").removeClass("greySelected");
		$(this).addClass("greySelected");
		var ind = $(this).parents("#homeOrderMode").eq(0).find("div#homeOrderModeItem").index( $(this) );
		$("#homeVideoList").html("");
		var currentTime = $("#currentTime").val();
		isLoaded = false;
		fnLoadHomeVideo( ind, 0, currentTime, 2 );
	});
	
	$("div#homeOrderModeItem").eq(0).click();
	
	$("#homeVideoList").scroll(function(e){
	    var scrollTop = $("#homeVideoList").scrollTop();
	    var scrollHeight = $("#homeVideoList").height();
	    var absoluteHeight = $("#homeVideoList").get(0).scrollHeight;
	    if( scrollTop + scrollHeight > absoluteHeight - 180 ){
	    	if( isLoading == true ) return;
	    	if( isLoaded == false ){
		    	var type = $("#homeOrderMode").eq(0).find("div#homeOrderModeItem").index( $("#homeOrderMode").find("div#homeOrderModeItem.greySelected").eq(0) );
		    	var cntLoaded = $("#homeVideoList").find("div#videoItem").length;
		    	var currentTime = $("#currentTime").val();
		    	var cntLazyLoad = 2;
		    	fnLoadHomeVideo( type, cntLoaded, currentTime, cntLazyLoad );	    		
	    	}
	    }
	    if( scrollTop == 0 ){
	    	// alert( "1" );
	    }
	});	
	
});
function fnLoadHomeVideo( type, cntLoaded, currentTime, cntLazyLoad ){
	
	isLoading = true;
	$("#loadingContainer").fadeIn();
	$.ajax({
        url: WS_PATH + "getHomeVideoList.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        data : { userId : CURRENT_USER_ID, type : type, cntLoaded : cntLoaded, currentTime : currentTime, cntLazyLoad : cntLazyLoad },	// ind : 0 - Date, 1 - Score, 2 - Cred
        success : function(data){
            if(data.result == "success"){
                for( var i = 0 ; i < data.videoList.length; i ++ ){
                	var objClone = $("#cloneVideoItem").clone( );
                	objClone.show();
                	objClone.attr("id", "videoItem");
                	objClone.find("#videoId").val( data.videoList[i].rb_video );
                	objClone.find("#videoUserId").val( data.videoList[i].rb_user );
                	objClone.find("#videoNo").val( data.videoList[i].videoURL );
                	objClone.find("#videoType").val( data.videoList[i].rb_video_type );
                	objClone.find("#videoScore").val( data.videoList[i].rb_video_score );
                	
                	objClone.find("#videoItemImage").attr("onclick", "window.location.href='profile.php?id=" + base64_encode(data.videoList[i].rb_user) + "'");
                	objClone.find("#videoItemImage").find("#photo").attr("src", data.videoList[i].rb_photo );
                	objClone.find("#videoItemImage").find("#score").attr("src", "/img/pieWhite" + Math.round(data.videoList[i].rb_cred) + ".png" );
                	objClone.find("#videoItemTitle").text( data.videoList[i].rb_content );
                	objClone.find("#videoItemHashtag").html( "<a href='search.php?h=" + base64_encode(data.videoList[i].rb_hashtag)+ "'>" + "#" + data.videoList[i].rb_hashtag + "</a>");
                	
            		var strUsername = "@" + data.videoList[i].rb_username;
            		strUsername = "<a href='/profile.php?id=" + base64_encode( data.videoList[i].rb_user ) + "'>" + strUsername + "</a>";
                	objClone.find("#videoItemUsername").html( strUsername );
                	
                	objClone.find("#videoItemTimeAgo").text( data.videoList[i].timeAgo );
                	objClone.find("#videoItemThumb").attr( "src", data.videoList[i].rb_video_thumb_large );
                	
                	objClone.find("#videoItemScore").find("img").attr("src", "/img/pieRed" + Math.round(data.videoList[i].rb_video_score) + "Play_290.png");
                	
                	var commentList = data.videoList[i].commentList;
                	var commentExpand = false;
                	for( var j = 0 ; j < commentList.length; j ++ ){
                		var objCloneComment = $("#cloneVideoItemComment").clone();
                		if( commentList.length - 3 <= j )
                			objCloneComment.show();
                		else
                			commentExpand = true;
                		objCloneComment.attr("id", "videoItemComment");
                		objCloneComment.find("#commentId").val( commentList[j].rb_user_video_comment );
                		objCloneComment.find("#commentUserId").val( commentList[j].rb_user );
                		var strUsername = "@" + commentList[j].rb_username;
                		strUsername = "<a href='/profile.php?id=" + base64_encode( commentList[j].rb_user ) + "'>" + strUsername + "</a>";
                		
                		var content = commentList[j].rb_content;
                		content = replaceUsername( content );
                		content = replaceHashtag( content );
                		objCloneComment.find("#videoItemCommentArea").html( strUsername + " : " + content );

                		objCloneComment.find("a.js-link").click(function (event){ 
                  	  		event.preventDefault();
                  	  		fnJsLink( this );
                  	  	});
                		
                		objClone.find("#videoItemCommentList").append( objCloneComment );
                	}
                	if( commentExpand ){
                		var objExpand = $("<div id='videoItemComment'><a style='font-weight:bold;' onclick='onExpandComments( this )'>Show all comments...</a></div>");
                		objClone.find("#videoItemCommentList").after( objExpand );
                	}
                	
                	objClone.find("#videoItemScore").find("img").attr("usemap", "#showScoreMap" + data.videoList[i].rb_video );
                	objClone.find("#videoItemScore").find("map").attr("name", "showScoreMap" + data.videoList[i].rb_video );
                	// objClone.find("#videoItemScore").find("area#areaShowScore").rwdImageMaps();
                	// if( !isPad() ){
                		objClone.find("#videoItemScore").find("img[usemap]").rwdImageMaps();
                	// }
                	objClone.find('area#areaShowScore').on('click', function() {
                		fnAttachEvent( this );
                	});
                	$("#homeVideoList").append( objClone );
                	
                }
                if( $("#homeVideoList").find("div#videoItem").length == 0 ){
                	$("#homeVideoList").html( "<div class='noData'>There are no posts in your feed, you should follow someone.</div>" );
                }

                if( data.videoList.length == 0 ){
                	isLoaded = true;
                	if( data.firstYn == "Y" )
                		$("#homeVideoList").append( '<button onclick="window.location.href=\'findFriends.php\'" id="profileFindFriends" class="form-control textCommon greySelected bordernone">FIND FRIENDS</button>' ); 	
                }
            	isLoading = false;
            	$("#loadingContainer").fadeOut();
            	$("#homeVideoList").getNiceScroll().resize();
            }else if( data.result == "failed" ){
            	alert("Username or Email is already registered.");
            	return;
            }
        }
    });	
}

function onGoProfile( ){
	if( $("#isLogin").val() == "N" ){
		alert("You have to login for this.");
		window.location.href='/';
		return;
	}
	window.location.href='profile.php';	
}
function onNotification(){
	if( $("#isLogin").val() == "N" ){
		alert("You have to login for this.");
		return;
	}	
	window.location.href='notification.php';
}
function isNewNotificationExist( ){
	if( $("#isLogin").val() == "N" ){
		return;
	}
	$.ajax({
        url: WS_PATH + "isNewNotificationExist.php",
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
        		if( data.isNewNotification == "Y" ){
        			$("#homeRightNavIcon").find("img").attr("src", "/img/btnMenuRed.png");
        		}
        	}
        }
	});
}