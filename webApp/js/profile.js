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
	var userId = $("#userId").val();
	$.ajax({
        url: WS_PATH + "getUserProfileInfo.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},
        data : { userId : userId, currentUserId : CURRENT_USER_ID },
        success : function(data){	
        	if(data.result == "success"){
        		// if( userId == CURRENT_USER_ID ){
        			
        			for( var i = 0; i < data.categoryList.length; i ++ ){
        				var objClone = $("#cloneProfileHashtagItem").clone();
        				objClone.attr("id", "profileHashtagItem");
        				objClone.find("a").attr("href", "/search.php?h=" + base64_encode(data.categoryList[i].rb_hashtag));
        				objClone.find("a").text( "#" + data.categoryList[i].rb_hashtag );
        				objClone.find("span").text( Number(data.categoryList[i].score).toFixed(2) );
        				objClone.show();
        				$("#profileHashtagList").append( objClone );
        			}
        			$("div#profileCredibility").niceScroll();
        			var cred = data.rb_cred;
        			$("#profileCredibility").find("#name").text(data.rb_name);
        			$("#profileCredibility").find("#username").html( '<a style="color:#FFF;" class="js-link" id="username">@' + data.rb_username + '</a>' );
        			$("#profileCredibility").find("#profileCredibilityGraph").attr("class", "pieRed" + Math.round( cred, 0 ));
        			$("#profileCredibility").find("#profileCredibilityGraph").text( Number( cred ).toFixed(2) );
        			
        			$("#profileSetting").find("#profileName").val(data.rb_name);
        			$("#profileSetting").find("#profileUsername").val(data.rb_username);
        			$("#profileSetting").find("#profileEmail").val(data.rb_email);
        			
        			$("#profileInfo").find("#profilePhoto").attr("src", data.photo);
        			$("#profileEnlargePhoto").attr("src", data.photo);
        			if( userId != CURRENT_USER_ID  ){
        				
            			if( data.isFollower == "Y" ){
            				$("#followingStatus").find("img").eq(0).attr("src","img/btnRedLeft.png");
            			}else{
            				$("#followingStatus").find("img").eq(0).attr("src","img/btnGreyLeft.png");
            			}
            			
            			if( data.isFollowing == "Y" ){
            				$("#followingStatus").find("img").eq(1).attr("src","img/btnRedRight.png");
            			}else{
            				$("#followingStatus").find("img").eq(1).attr("src","img/btnGreyRight.png");
            			}
            			$("#followingStatus").find("p").show();
        			}else{
        				$("#followingStatus").find("p").hide();
        			}

        			
        			

        			
        			$("#profileInfo").find("#profileMenuVideo").text( "Videos (" + data.cntVideos + ")" );
        			
        			$("#profileInfo").find("#profileInfoFollowersNumber").text( data.cntFollowers );
        			$("#profileInfo").find("#profileInfoFollowingNumber").text( data.cntFollowing );
        			if( userId == CURRENT_USER_ID ){
        				$("#profileBtnSetting").show();
            			$("#profileBtnFollow").hide();        				
        			}else{
        				$("#profileBtnSetting").hide();
        				$("#profileBtnFollow").show();
        				if( data.isFollowing == "Y" )
        					$("#profileBtnFollow").text("UNFOLLOW");
        				else
        					$("#profileBtnFollow").text("FOLLOW");
        			}
        		// }
        	}else if( data.result == "failed" ){
        		
        	}
        }
    });	
	
	$("div#profileSetting").niceScroll();
	$("div#profileVideoList").niceScroll();
	
	
	$("input#imageUpload").change( function(){
		$(this).parents("form").ajaxForm({
			target: '#' + $(this).parents("form").find("#imagePrevDiv").val()
		}).submit();
	});
	
	$("div.profileMenuItem").click( function(){
		if( isLoading ) return;
		var ind = $(this).parents("#profileMenu").eq(0).find("div.profileMenuItem").index( $(this) );
		if( ind == 0 && $(this).hasClass("redSelected") ){
			return;
		}else if( ind == 0 ){
			reloadVideo( );
		}
		if( ind == 1 ){
			$(this).parents("#profileMenu").find("div.profileMenuItem").removeClass("redSelected");
			$(this).parents("#profileMenu").find("div.profileMenuItem").eq(1).addClass("redSelected");
			$("#profileVideoList").hide();
			$("#profileCredibility").show();
			$("#profileSetting").hide();
			$("#profileCredibility").getNiceScroll().resize();
		}else if( ind == 2 ){
			if( $(this).parents("#profileMenu").eq(0).find("div.profileMenuItem").eq(0).hasClass("redSelected") ){
				var backImg = $("#profileMenuListMode").css("background-image");
				if( backImg.indexOf("iconVideoList.png") >= 0 ){
					$("#profileMenuListMode").css("background-image", "url(/img/iconVideoMosaic.png)");
				}else{
					$("#profileMenuListMode").css("background-image", "url(/img/iconVideoList.png)");
				}
			}
			reloadVideo( );

		}
	});
	
	$("#profileVideoList").scroll(function(e){
	    var scrollTop = $("#profileVideoList").scrollTop();
	    var scrollHeight = $("#profileVideoList").height();
	    var absoluteHeight = $("#profileVideoList").get(0).scrollHeight;
	    if( scrollTop + scrollHeight > absoluteHeight - 50 ){
	    	if( isLoading == true ) return;
	    	if( isLoaded == false ){
		    	
		    	var cntLoaded;
				var backImg = $("#profileMenuListMode").css("background-image");
				if( backImg.indexOf("iconVideoList.png") >= 0 ){
					cntLoaded = $("#profileVideoList").find("div#profileVideoItemByList").length;
				}else{
					cntLoaded = $("#profileVideoList").find("div#videoItem").length;
				}
		    	var currentTime = $("#currentTime").val();
		    	fnLoadVideo( cntLoaded, currentTime)
	    	}
	    }
	});		
	
	$("div.profileMenuItem").eq(1).click();
});

function reloadVideo( ){
	$("#profileMenu").find("div.profileMenuItem").removeClass("redSelected");
	$("#profileMenu").find("div.profileMenuItem").eq(0).addClass("redSelected");
	$("#profileVideoList").show();
	$("#profileCredibility").hide();
	$("#profileSetting").hide();
	$("#profileVideoList").html("");
	isLoading = false;
	isLoaded = false;
	fnLoadVideo( 0, $("#currentTime").val());	
}

function fnLoadVideo( cntLoaded, currentTime ){
	if( isLoading == true ) return;
	var viewType;
	var cntLazyLoad;
	
	var backImg = $("#profileMenuListMode").css("background-image");	
	if( backImg.indexOf("iconVideoList.png") >= 0 ){
		viewType = 1;
		cntLazyLoad = 8;
	}else{
		viewType = 2;
		cntLazyLoad = 2;
	}
		
	var userId = $("#profileInfo").find("#userId").val( );
	
	$("#loadingContainer").fadeIn();
	isLoading = true;
	$.ajax({
        url: WS_PATH + "getVideoListByUserId.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        data : { userId : userId, cntLoaded : cntLoaded, currentTime : currentTime, cntLazyLoad : cntLazyLoad },
        success : function(data){
        	if( viewType == 1 ){
        		for( var i = 0 ; i < data.videoList.length; i ++ ){
            		var objClone = $("#cloneProfileVideoItemByList").clone();
            		objClone.show();
            		objClone.attr("id", "profileVideoItemByList");
            		objClone.find("a").attr("href", "/video.php?id=" + base64_encode(data.videoList[i].rb_video) );
            		objClone.find("#videoId").val( data.videoList[i].rb_video );
            		objClone.find("#profileVideoItemByListThumb").attr("src", data.videoList[i].rb_video_thumb_small );
            		
            		var strUsername = "@" + data.videoList[i].rb_username;
            		strUsername = "<a href='/profile.php?id=" + base64_encode( data.videoList[i].rb_user ) + "'>" + strUsername + "</a>";
            		
            		objClone.find("#profileVideoItemByListHashtag").html( 
            				"<a href='search.php?h=" + base64_encode(data.videoList[i].rb_hashtag ) + "'>#" + data.videoList[i].rb_hashtag + "</a>");
            		
            		objClone.find("#profileVideoItemByListUsername").html( strUsername );
            		objClone.find("#profileVideoItemByListContent").text( data.videoList[i].rb_content );
            		var roundScore = Math.round( data.videoList[i].rb_video_score );
            		objClone.find("#profileVideoItemByListScore").addClass( "whiteScore" + roundScore );
            		
                	var videoId = data.videoList[i].rb_video;
                	var videoNo = data.videoList[i].videoURL;
                	var videoType = data.videoList[i].rb_video_type;
                	
                	objClone.find("img#btnSmallPlay").attr("onclick","showPlayPopup( " + videoId + ", '" + videoNo + "', '" + videoType + "' )" );
                	objClone.find("img#btnSmallScore").attr("onclick","showScorePopup( " + videoId + ", '" + videoNo + "', '" + videoType + "' )" );            		
            		
            		$("#profileVideoList").append( objClone );
            	}
        		
        		if( $("#profileVideoList").find("div#profileVideoItemByList").length == 0 ){
        			$("#profileVideoList").html( "<div class='noData'>This user has not uploaded any Videos.</div>" );
        		}

                if( data.videoList.length == 0 ){
                	isLoaded = true;
                }
            	isLoading = false;
            	
        		$("#loadingContainer").fadeOut();
        		$("#profileVideoList").getNiceScroll().resize();
        	}else if( viewType == 2 ){
        		 for( var i = 0 ; i < data.videoList.length; i ++ ){
                	var objClone = $("#cloneVideoItem").clone( );
                	objClone.show();
                	objClone.attr("id", "videoItem");
                	objClone.find("#videoId").val( data.videoList[i].rb_video );
                	objClone.find("#videoUserId").val( data.videoList[i].rb_user );
                	objClone.find("#videoType").val( data.videoList[i].rb_video_type );
                	objClone.find("#videoNo").val( data.videoList[i].videoURL );
                	
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
                	
                	var videoId = data.videoList[i].rb_video;
                	var videoNo = data.videoList[i].videoURL;
                	var videoType = data.videoList[i].rb_video_type;
                	
                	objClone.find("#videoItemThumb").attr("onclick","showPlayPopup( " + videoId + ", '" + videoNo + "', '" + videoType + "' )" );
                	objClone.find(".videoItemBtnPlay").attr("onclick","showPlayPopup( " + videoId + ", '" + videoNo + "', '" + videoType + "' )" );                	
                	
                	objClone.find("#videoItemScore").find("img").attr("src", "/img/pieRed" + Math.round(data.videoList[i].rb_video_score) + "Play_290.png");
                	
                	var commentList = data.videoList[i].commentList;
                	var commentExpand = false;
                	for( var j = 0 ; j < commentList.length; j ++ ){
                		var objCloneComment = $("#cloneVideoItemComment").clone();
                		if( commentList.length - 3 <= j )
                			objCloneComment.show();
                		else{
                			commentExpand = true;
                		}
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
                	//if( !isPad() )
                		//objClone.find("#videoItemScore").find("img").rwdImageMaps();
                	objClone.find("#videoItemScore").find("img[usemap]").rwdImageMaps();
                	objClone.find("#videoItemScore").find("img").attr("usemap", "#showScoreMap" + data.videoList[i].rb_video );
                	objClone.find("#videoItemScore").find("map").attr("name", "showScoreMap" + data.videoList[i].rb_video );                	
                	$("#profileVideoList").append( objClone );
                }
         		if( $("#profileVideoList").find("div#videoItem").length == 0 ){
        			$("#profileVideoList").html( "<div class='noData'>This user has not uploaded any Videos.</div>" );
        		}

                if( data.videoList.length == 0 ){
                	isLoaded = true;
                }
            	isLoading = false;
            	
        		$("#loadingContainer").fadeOut();
        		$("#profileVideoList").getNiceScroll().resize();
        	}
        	isLoading = false;
        }
	});
}
function onProfileFollowing( obj ){
	if( $("#isLogin").val() == "N" ){
		alert("You have to login for this.");
		return;
	}
	var type;
	if( $(obj).text() == "FOLLOW" ){
		type = "FOLLOW";
	}else{
		type = "UNFOLLOW";
	}
	var followingId = $("#userId").val( );
	$.ajax({
        url: WS_PATH + "setFollow.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},
        data : { userId : CURRENT_USER_ID, followingId : followingId, type : type },
        success : function(data){	
        	if(data.result == "success"){
        		if( type == "FOLLOW"){
            		var cnt = Number( $("#profileInfoFollowersNumber").text() );
            		cnt ++;
            		$("#profileInfoFollowersNumber").text( cnt );
            		$(obj).text("UNFOLLOW");
            		$("#followingStatus").find("img").eq(1).attr("src", "img/btnRedRight.png");
            		
        		}else{
            		var cnt = Number( $("#profileInfoFollowersNumber").text() );
            		cnt --;
            		$("#profileInfoFollowersNumber").text( cnt );
            		$(obj).text("FOLLOW");
            		$("#followingStatus").find("img").eq(1).attr("src", "img/btnGreyRight.png");
            		
        		}
        	}else if( data.result == "failed" ){
        		if( data.error == "ERROR_ME" ){
        			alert("You can't follow you.");
        			return;
        		}else if( data.error == "ERROR_ALREADY" ){
        			alert("You are already following this member.");
        			return;
        		}
        	}
        }
    });
}
function onProfileSetting( ){
	$("#profileVideoList").hide();
	$("#profileCredibility").hide();
	$("#profileSetting").show();
	$("#profileSetting").getNiceScroll().resize();
}
function onSaveProfileSetting( ){
	var name = $("#profileName").val( );
	var username = $("#profileUsername").val( );
	var password = $("#profilePassword").val( );
	var email = $("#profileEmail").val( );
	var bio = $("#profileBio").val( );
	if( name == "" ){ alert("Please input the name."); return; }
	// if( password == "" ){ alert("Please input the password."); return; }
	// if( bio == "" ){ alert("Please input the Biographical."); return; }
	if( bio != "" && bio.length > 140 ){ alert("Biographical length should be less than 140."); return;}
	
	if( validateUsername(username) ){
		alert("Username mustn't include space, special characters."); return;
	}
	
	$.ajax({
        url: WS_PATH + "saveProfileSetting.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        data : { userId : CURRENT_USER_ID, name : name, username : username, password : password, email : email, bio : bio },
        success : function(data){	
        	if( data.result == "success" ){
        		alert("Profile updated successfully.");
        		return;
        	}else{
        		if( data.error == "EMAIL" ){
        			alert("This Email Address is already exist.");
        		}else if( data.error == "USERNAME" ){
        			alert("This Username is already in use.");
        		}
        		
        	}
        }
	});
}
function onProfileDeletePicture(){
	if( !confirm("Are you sure?") ){
		return;
	}
	$.ajax({
        url: WS_PATH + "deleteProfilePicture.php",
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
        		alert("Picture deleted successfully.");
        		$("#profilePhoto").attr( "src", data.photo );
        		$("#profileEnlargePhoto").attr( "src", data.photo );
        		return;
        	}
        }
	});
}
function onProfileDeleteAccount(){
	if( !confirm("Are you sure you would like to delete your account permanently?") ){
		return;
	}	
	$.ajax({
        url: WS_PATH + "deleteProfileAccount.php",
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
        		alert("Account deleted successfully.");
        		window.location.href = "index.php";
        		return;
        	}
        }
	});	
}
function onProfileLogOut( ){
	if( !confirm("Are you sure you want to log out?") ) return;
	$.ajax({
        url: "async-logOut.php",
        dataType : "json",
        type : "POST",
        data : { },
        success : function(data){	
        	if( data.result == "success" ){	
        		window.location.href = "index.php";
        		return;
        	}
        }
	});
}
function onProfileApplication( ){
	window.location.href = "application.php";
}
function onProfileEmail( ){
	window.location.href = "emails.php";
}
function onProfileFindFriends( ){
	window.location.href = "findFriends.php";
	/*
    FB.api('/me/friends', function(response) {
        if(response.data) {
            $.each(response.data,function(index,friend) {
                alert(friend.name + ' has id:' + friend.id);
            });
        } else {
            alert("Error!");
        }
    });
    */
}
function onShowVideo( ){
	$("div.profileMenuItem").eq(1).click( );	
}
function onProfilePhotoUpload(){
	window.location.href = "uploadPicture.php";
}
function onShowEnlargePhoto( ){
	$("#profileEnlargePhoto").fadeIn();
	$("#divProfileEnlargePhoto").fadeIn();
}
function onHideEnlargePhoto( ){
	$("#profileEnlargePhoto").fadeOut();
	$("#divProfileEnlargePhoto").fadeOut();
}
