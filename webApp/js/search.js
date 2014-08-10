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
var scoreType = 2;
$(document).ready( function(){
	var watchMode;
	if($.cookie('RB_WATCH') == undefined ){
		$.cookie("RB_WATCH", "B", { expires: 2 * 7 });
		watchMode = "B";
	}else{
		watchMode = $.cookie('RB_WATCH');
	}
	if( watchMode == "B" ){
		$("#watchMode").val("B");
		$("#searchSearchLeftNavIcon").find("img").attr("src", "/img/btnBigCircle.png");		
	}else{
		$("#watchMode").val("S");
		$("#searchSearchLeftNavIcon").find("img").attr("src", "/img/btnSmallCircle.png");
	}
	onChangeWatchMode();
	
	setTimeout(function(){ $("#redTooltip").fadeOut();}, 5000);
	
	$("#searchTxtKeyword").focus();
	$("#searchVideoList").niceScroll();
	$("#searchUserList").niceScroll();
	// Changing the Tab
	$("div#searchOrderModeItem").click( function(e){
		if( isLoading == true ) return;
		if( $(this).hasClass("redSelected") ){
			
			if( $("#searchOrderMode").find("div#searchOrderModeItem").index($(this)) == 1 ){
				// show the score type list
				$("div#searchPeriodModeList").fadeIn();
				$("div#periodListBackground").fadeIn();
				return;
			}else{
				return;
			}
		}
		$(this).parents("#searchOrderMode").eq(0).find("div#searchOrderModeItem").removeClass("redSelected");
		$(this).addClass("redSelected");
		isLoading = false;
		isLoaded = false;
		$("#searchVideoList").html( "" );		
		fnLoadByHashtag( 0, $("#currentTime").val() );
	});
	$("div#searchUserOrderModeItem").click( function(e){
		if( isLoading == true ) return;
		if( $(this).hasClass("redSelected") ) return;
		$(this).parents("#searchUserOrderMode").eq(0).find("div#searchUserOrderModeItem").removeClass("redSelected");
		$(this).addClass("redSelected");
		isLoading = false;
		isLoaded = false;
		$("#searchUserList").html( "" );		
		fnLoadByUsername( 0, $("#currentTime").val() );
	});	
	
	$("div#searchPeriodModeItem").click( function(){
		$("div#searchPeriodModeItem").removeClass("searchPeriodModeItemSelected");
		$(this).addClass("searchPeriodModeItemSelected");
		reloadPage( );
		
	});
	$("div#searchOrderModeItem").eq(0).addClass("redSelected");
	$("div#searchUserOrderModeItem").eq(0).addClass("redSelected");
	$("#searchModeHashtag").click();
	
	$("#searchUserList").hide();
	$("#searchTxtKeyword").keyup( function(event){
		if( event.keyCode == 13 ){
			onClickSearch();
		}
	});
	
	$("#searchVideoList").scroll(function(e){
	    var scrollTop = $("#searchVideoList").scrollTop();
	    var scrollHeight = $("#searchVideoList").height();
	    var absoluteHeight = $("#searchVideoList").get(0).scrollHeight;
	    if( scrollTop + scrollHeight > absoluteHeight - 50 ){
	    	if( isLoading == true ) return;
	    	if( isLoaded == false ){
	    		var cntLoaded;
	    		var type = $("#searchModeVideo").css("background-image");

	    		if( $("#searchSearchMode").find("div.searchModeItem").eq(0).hasClass("redSelected") && type.indexOf("iconVideoList") > - 1){
	    			cntLoaded = $("#searchVideoList").find("div#searchVideoItemByList").length;
	    		}else{
	    			cntLoaded = $("#searchVideoList").find("div#videoItem").length;
	    		}	    		
	    		fnLoadByHashtag( cntLoaded, $("#currentTime").val() );	    		
	    	}
	    }
	});
	$("#searchUserList").scroll(function(e){
	    var scrollTop = $("#searchUserList").scrollTop();
	    var scrollHeight = $("#searchUserList").height();
	    var absoluteHeight = $("#searchUserList").get(0).scrollHeight;
	    if( scrollTop + scrollHeight > absoluteHeight - 50 ){
	    	if( isLoading == true ) return;
	    	if( isLoaded == false ){  		
	    		fnLoadByUsername( $("#searchUserList").find("div#searchUserItem").length, $("#currentTime").val() );	    		
	    		
	    	}
	    }
	});
});
function onChangeWatchMode( ){
	var watchMode = $("#watchMode").val();
	if( watchMode == "B" ){
		$("#redTooltip").find("span").text("You are watching: Everyone");		
	}else{
		$("#redTooltip").find("span").text("You are watching: People you follow");
	}
	$("#redTooltip").fadeIn();
}
function onClickSearchMode( obj ){
	if( isLoading == true ) return;
	var objParent = $(obj).parents("#searchSearchMode");
	var ind = objParent.find("div.searchModeItem").index( $(obj) );
	if( ind == 0){
		objParent.find("div.searchModeItem").removeClass("redSelected");
		objParent.find("div.searchModeItem").eq(0).addClass("redSelected");
		$("#searchOrderMode").show();
		$("#searchUserOrderMode").hide();
		$("#searchVideoList").show();
		$("#searchUserList").hide();
		isLoading = false;
		isLoaded = false;
		$("#searchVideoList").html( "" );
		$("#searchTxtKeyword").attr("placeholder", "Search #Category");
		fnLoadByHashtag( 0, $("#currentTime").val() );
	}else if( ind == 1){		
		objParent.find("div.searchModeItem").removeClass("redSelected");
		objParent.find("div.searchModeItem").eq(1).addClass("redSelected");
		$("#searchOrderMode").hide();
		$("#searchUserOrderMode").show();
		$("#searchVideoList").hide();
		$("#searchUserList").show();
		isLoading = false;
		isLoaded = false;
		$("#searchUserList").html( "" );
		$("#searchTxtKeyword").attr("placeholder", "Search @username");
		fnLoadByUsername( 0, $("#currentTime").val() );
	}
}
function onClickSearch( ){
	if( $("#searchSearchMode").find("div.searchModeItem").eq(1).hasClass("redSelected") ){
		isLoading = false;
		isLoaded = false;
		$("#searchUserList").html( "" );
		fnLoadByUsername( 0, $("#currentTime").val() );
	}else{
		isLoading = false;
		isLoaded = false;
		$("#searchVideoList").html( "" );		
		fnLoadByHashtag( 0, $("#currentTime").val() );
	}
}
function fnLoadByHashtag( cntLoaded, currentTime ){
	if( isLoading == true ) return;
	// 0 : Date, 1 : Score, 2 : Cred
	var orderMode = $("#searchOrderMode").find("div#searchOrderModeItem").index( $("#searchOrderMode").find("div.redSelected") );
	var viewMode;	// 1 : Mosaic View, 2 : List View
	var txtKeyword = $("#searchTxtKeyword").val( );
	var period = $("div#searchPeriodModeList").find("div#searchPeriodModeItem").index( $("div#searchPeriodModeList").find("div.searchPeriodModeItemSelected") ) * 1 + 1;
	// if( txtKeyword == "" ) { alert("Please input the search word."); return; }
	var sort = $("#searchOrderMode").find("div.redSelected").find("div").attr("sort");
	var cntLazyLoad;
	
	if( $("#searchModeVideo").css("background-image").indexOf("iconVideoList.png") != -1 ){
		viewMode = 1;
		cntLazyLoad = 6;		
	}else{
		viewMode = 2;
		cntLazyLoad = 2;		
	}
	
	// if( txtKeyword == "" ) return;
	isLoading = true;
	var ajaxPath = "";
	if( $("#watchMode").val() == "S"){
		ajaxPath = "getMyVideoList.php";
	}else{
		ajaxPath = "getSearchVideoList.php";
	}
	
	$("#loadingContainer").fadeIn();
	$.ajax({
        url: WS_PATH + ajaxPath,
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},
        data : { type : orderMode, txtKeyword : txtKeyword, cntLoaded : cntLoaded, currentTime : currentTime, cntLazyLoad : cntLazyLoad, userId : CURRENT_USER_ID, period : period, sort : sort },
        success : function( data ){
            if(data.result == "success"){
            	if( viewMode == 1 ){
                	for( var i = 0 ; i < data.videoList.length; i ++ ){
                		var objClone = $("#cloneSearchVideoItemByList").clone();
                		objClone.show();
                		objClone.attr("id", "searchVideoItemByList");
                		objClone.find("a").attr("href", "/video.php?id=" + base64_encode(data.videoList[i].rb_video) );
                		objClone.find("#videoId").val( data.videoList[i].rb_video );
                		objClone.find("#videoNo").val( data.videoList[i].videoURL );
                		objClone.find("#videoType").val( data.videoList[i].rb_video_type );
                		objClone.find("#searchVideoItemByListThumb").attr("src", data.videoList[i].rb_video_thumb_small );
                		
                		var strUsername = "@" + data.videoList[i].rb_username;
                		strUsername = "<a href='/profile.php?id=" + base64_encode( data.videoList[i].rb_user ) + "'>" + strUsername + "</a>";
                		objClone.find("#searchVideoItemByListUsername").html( strUsername );
                		
                		objClone.find("#searchVideoItemByListHashtag").html( "<a href='/search.php?h=" + base64_encode( data.videoList[i].rb_hashtag )+ "'>#" + data.videoList[i].rb_hashtag + "</a>" );
                		
                		objClone.find("#searchVideoItemByListContent").text( data.videoList[i].rb_content );
                		var roundScore = Math.round( data.videoList[i].rb_video_score );
                		objClone.find("#searchVideoItemByListScore").addClass( "whiteScore" + roundScore );
                		
	                	var videoId = data.videoList[i].rb_video;
	                	var videoNo = data.videoList[i].videoURL;
	                	var videoType = data.videoList[i].rb_video_type;
	                	
	                	objClone.find("img#btnSmallPlay").attr("onclick","showPlayPopup( " + videoId + ", '" + videoNo + "', '" + videoType + "' )" );
	                	objClone.find("img#btnSmallScore").attr("onclick","showScorePopup( " + videoId + ", '" + videoNo + "', '" + videoType + "' )" );
	                	
                		
                		$("#searchVideoList").append( objClone );
                	}
                	
                	if( $("#searchVideoList").find("div#searchVideoItemByList").length == 0 ){
                		$("#searchVideoList").html( "<div class='noData'>This Hashtag doesn't have results.</div>" );
            		}
                    if( data.videoList.length == 0 ){
                    	isLoaded = true;
                    }
                	isLoading = false;
                	$("#loadingContainer").fadeOut();                	
                	$("#searchVideoList").getNiceScroll().resize();
            	}else if( viewMode == 2 ){
            		
            		for( var i = 0 ; i < data.videoList.length; i ++ ){
	                	var objClone = $("#cloneVideoItem").clone( );
	                	objClone.show();
	                	objClone.attr("id", "videoItem");
	                	objClone.find("#videoId").val( data.videoList[i].rb_video );
	                	objClone.find("#videoUserId").val( data.videoList[i].rb_user );	                	
	                	objClone.find("#videoNo").val( data.videoList[i].videoURL );
	                	objClone.find("#videoType").val( data.videoList[i].rb_video_type );
	                	
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
	                	/*objClone.find('area[type="showScore"]').on('mouseover', function() {
	                		fnMouseOver( this );
	                	});
	                	objClone.find('area[type="showScore"]').on('mouseout', function() {
	                		fnMouseOut( this );
	                	});*/
	                	objClone.find("#videoItemScore").find("img[usemap]").rwdImageMaps();
	                	// objClone.find("#videoItemScore").find("area#areaShowScore").rwdImageMaps();
	                	objClone.find("#videoItemScore").find("img").attr("usemap", "#showScoreMap" + data.videoList[i].rb_video );
	                	objClone.find("#videoItemScore").find("map").attr("name", "showScoreMap" + data.videoList[i].rb_video );
	                	
	                	$("#searchVideoList").append( objClone );
	                }
                	if( $("#searchVideoList").find("div#videoItem").length == 0 ){
                		$("#searchVideoList").html( "<div class='noData'>This Hashtag doesn't have results.</div>" );
            		}
                    if( data.videoList.length == 0 ){
                    	isLoaded = true;
                    }
                	isLoading = false;
                	$("#loadingContainer").fadeOut();                	
                	$("#searchVideoList").getNiceScroll().resize();
            	}
            }
        }
	});
}
function fnLoadByUsername( cntLoaded, currentTime ){
	if( isLoading == true ) return;
	
	// 1 : Date, 2 : Meri.to
	var orderMode = $("#searchUserOrderMode").find("div#searchUserOrderModeItem").index( $("#searchUserOrderMode").find("div.redSelected") ) * 1 + 1;
	var txtKeyword = $("#searchTxtKeyword").val( );
	// if( txtKeyword == "" ) return;
	$("#loadingContainer").fadeIn();
	isLoading = true;
	var sort = $("#searchUserOrderMode").find("div.redSelected").find("div").attr("sort");
	var ajaxPath = "";
	if( $("#watchMode").val() == "S"){
		ajaxPath = "getMyUserList.php";
	}else{
		ajaxPath = "getSearchUserList.php";
	}
	
	$.ajax({
        url: WS_PATH + ajaxPath,
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},
        data : { txtKeyword : txtKeyword, cntLoaded : cntLoaded, currentTime : currentTime, cntLazyLoad : 6, type : orderMode, userId : CURRENT_USER_ID, sort : sort },
        success : function( data ){
            if(data.result == "success"){
        		for( var i = 0 ; i < data.userList.length; i ++ ){
        			var objClone = $("#cloneSearchUserItem").clone();
        			objClone.show();
        			objClone.attr("id", "searchUserItem");
        			objClone.find("#userId").val( data.userList[i].rb_user );
        			objClone.find("#searchUserItemPhoto").attr("src", data.userList[i].rb_photo );
        			objClone.find("#searchUserItemPhoto").attr("onclick", "window.location.href='profile.php?id=" + base64_encode(data.userList[i].rb_user) + "'");
        			
            		var strUsername = "@" + data.userList[i].rb_username;
            		strUsername = "<a href='/profile.php?id=" + base64_encode( data.userList[i].rb_user ) + "'>" + strUsername + "</a>";        			
        			
        			objClone.find("#searchUserItemUsername").html( strUsername );
        			objClone.find("#searchUserItemName").text( data.userList[i].rb_name);
        			objClone.find("#searchUserItemCredTxt").text( "Meri.to : " + data.userList[i].rb_cred );
        			
            		var roundCred = Math.round( data.userList[i].rb_cred );
            		objClone.find("#searchUserItemCredGraph").addClass( "whiteScore" + roundCred );
            		objClone.find("#searchUserItemCredGraph").attr("onclick", "window.location.href='/profile.php?id=" + base64_encode( data.userList[i].rb_user )+ "';");
            		
            		var followingImg, followerImg;
            		
            		if( data.userList[i].isFollowing == "Y" )
            			followerImg = "img/btnRedLeft.png";
            		else
            			followerImg = "img/btnGreyLeft.png";
            		
            		if( data.userList[i].isFollower == "Y" )
            			followingImg = "img/btnRedRight.png";
            		else
            			followingImg = "img/btnGreyRight.png";            		
            		
            		objClone.find("#searchUserItemFriendship").find("img").eq(0).attr("src", followerImg);
            		objClone.find("#searchUserItemFriendship").find("img").eq(1).attr("src", followingImg);
        			$("#searchUserList").append( objClone );
        		}
        		
        		$("#loadingContainer").fadeOut();

                if( $("#searchUserList").find("div#searchUserItem").length == 0 ){
                	$("#searchUserList").html( "<div class='noData'>This Username doesn't have results.</div>" );
                }
                if( data.userList.length == 0 ){
                	isLoaded = true;
                }
            	isLoading = false;        		
        		
        		$("#searchUserList").getNiceScroll().resize();
        		
            }
        }
	});
}
function onHideTooltip( ){
	$("#redTooltip").fadeOut();
}
function onClickWatch( obj ){
	if( isLoading == true ) return;
	
	if( $("#watchMode").val() == "B" ){
		$(obj).find("img").attr("src", "/img/btnSmallCircle.png");
		$("#watchMode").val("S");
		$.cookie("RB_WATCH", "S", { expires: 2 * 7 });		
	}else{
		$(obj).find("img").attr("src", "/img/btnBigCircle.png");
		$("#watchMode").val("B");
		$.cookie("RB_WATCH", "B", { expires: 2 * 7 });
	}
	onChangeWatchMode( );
	reloadPage( );
}
function reloadPage( ){
	$("div#periodListBackground").fadeOut();
	$("div#searchPeriodModeList").fadeOut();
	$("#searchSearchMode").find("div.redSelected").click();
}
function onHidePeriodListBackground( ){
	$("#periodListBackground").hide();
	$("#searchPeriodModeList").hide();
	
}
function onChangeSearchMode( obj ){
	var img = $(obj).css("background-image");
	if( img.indexOf("iconVideoList") == -1 )
		$(obj).css("background-image", "url(/img/iconVideoList.png)");
	else
		$(obj).css("background-image", "url(/img/iconVideoMosaic.png)");
	$("#searchSearchMode").find("div.searchModeItem").eq(0).click();
}
function onClearSearchWord( ){
	$("#searchTxtKeyword").val("");
	reloadPage( );
}
function onClickUserSort( obj ){
	if( isLoading == true ) return;
	
	if( $(obj).parents("div").eq(0).hasClass("redSelected") ){
		if( $(obj).attr("sort") == 1 ){
			$(obj).attr("sort", 2);
			$(obj).html("&#9650;");
		}else{
			$(obj).attr("sort", 1);
			$(obj).html("&#9660;");
		}
		reloadPage( );
	}else{
		$(obj).parents("div").eq(0).click();
	}
}
function onShowScoreMode( obj ){
	$(obj).parents("div").eq(0).click();
}