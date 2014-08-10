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
	isNewNotificationExist( );

	$("#videoItemScore").find("img").rwdImageMaps();
	$('area[type="showScore"]').on('click', function() {
		fnAttachEvent( this );
	});
	/*$('area[type="showScore"]').on('mouseover', function() {
		fnMouseOver( this );
	});
	$('area[type="showScore"]').on('mouseout', function() {
		fnMouseOut( this );
	}); */
	$("#videoVideoList").niceScroll();
	
	$("#videoItemCommentList").find("a.js-link").click(function (event){ 
		event.preventDefault();
		fnJsLink( this );
	});	
	
	var videoId = $("#currentVideoId").val();
	$.ajax({
        url: WS_PATH + "getVideoInfo.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        data : { videoId : videoId },
        success : function(data){	
        	if(data.result == "success"){
            	var objClone = $("#cloneVideoItem").clone( );
            	objClone.show();
            	objClone.attr("id", "videoItem");
            	objClone.find("#videoId").val( data.videoItem.rb_video );
            	objClone.find("#videoUserId").val( data.videoItem.rb_user );	                	
            	objClone.find("#videoNo").val( data.videoItem.videoURL );
            	objClone.find("#videoType").val( data.videoItem.rb_video_type );
            	
            	objClone.find("#videoItemImage").attr("onclick", "window.location.href='profile.php?id=" + base64_encode(data.videoItem.rb_user) + "'");
            	objClone.find("#videoItemImage").find("#photo").attr("src", data.videoItem.rb_photo );
            	objClone.find("#videoItemImage").find("#score").attr("src", "/img/pieWhite" + Math.round(data.videoItem.rb_cred) + ".png" );
            	
            	objClone.find("#videoItemTitle").text( data.videoItem.rb_content );
            	objClone.find("#videoItemHashtag").html( "<a href='search.php?h=" + base64_encode(data.videoItem.rb_hashtag)+ "'>" + "#" + data.videoItem.rb_hashtag + "</a>");
            	
        		var strUsername = "@" + data.videoItem.rb_username;
        		strUsername = "<a href='/profile.php?id=" + base64_encode( data.videoItem.rb_user ) + "'>" + strUsername + "</a>";
            	objClone.find("#videoItemUsername").html( strUsername );
            	
            	objClone.find("#videoItemTimeAgo").text( data.videoItem.timeAgo );
            	objClone.find("#videoItemThumb").attr( "src", data.videoItem.rb_video_thumb_large );
            	
            	var videoId = data.videoItem.rb_video;
            	var videoNo = data.videoItem.videoURL;
            	var videoType = data.videoItem.rb_video_type;
            	
            	objClone.find("#videoItemThumb").attr("onclick","showPlayPopup( " + videoId + ", '" + videoNo + "', '" + videoType + "' )" );
            	objClone.find(".videoItemBtnPlay").attr("onclick","showPlayPopup( " + videoId + ", '" + videoNo + "', '" + videoType + "' )" );
            	
            	objClone.find("#videoItemScore").find("img").attr("src", "/img/pieRed" + Math.round(data.videoItem.rb_video_score) + "Play_290.png");
            	
            	var commentList = data.videoItem.commentList;
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
            	objClone.find('area[type="showScore"]').on('click', function() {
            		fnAttachEvent( this );
            	});
            	objClone.find("#videoItemScore").find("img[usemap]").rwdImageMaps();
            	// objClone.find("#videoItemScore").find("area#areaShowScore").rwdImageMaps();
            	objClone.find("#videoItemScore").find("img").attr("usemap", "#showScoreMap" + data.videoItem.rb_video );
            	objClone.find("#videoItemScore").find("map").attr("name", "showScoreMap" + data.videoItem.rb_video );
            	
            	$("#videoVideoList").append( objClone );        		        		
        	}
        }
	});
	
});
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
        			$("#homeRightNavIcon").find("img").attr("src", "img/btnMenuRed.png");
        		}
        	}
        }
	});
}

