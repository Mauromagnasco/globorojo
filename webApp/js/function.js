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
var showScore;
var APP_SECRET_KEY;
var WS_PATH;
var CURRENT_USER_ID;
var hashtagList = [];
var isShowRed = "N";
$(document).ready( function(){
	
	$("img").attr("unselectable", "on");
	
	APP_SECRET_KEY = $("#APP_SECRET_KEY").val( );
	WS_PATH = $("#WS_PATH").val( );
	CURRENT_USER_ID = $("#CURRENT_USER_ID").val( );
	
	if( detectmob() ){
		$("#reportCopyPostUrl").hide();
	}
	$("div#mainContainer.start, div#mainContainer.signup, div#mainContainer.login").niceScroll();
	$("#videoScoreContainer").niceScroll();
	$("#videoShareBody").niceScroll();
	
	$("a.js-link").click(function (event){ 
	  		event.preventDefault();
	  		fnJsLink( this );
	});
	
	$("#videoScorePanelScore").click( function(){
		$("area[type='giveScore']").eq(5).click();
	});
	var objList = $("body").find('img[usemap]').rwdImageMaps();
	$('area[type="giveScore"]').on('click', function(event) {
		event.stopPropagation();
		var score = $(this).attr('alt');
		if( score != 'submitScore'){
			if( $("#videoScoreMain").find("#isGiven").val() == "Y" ) return;
			var videoId = $("#videoScoreMain").find("#videoId").val( );
			showScore = score;
			$("#givenScore").val(score);
			$("#videoScoreMain").find("#videoScorePanel").find("img").attr("src", "/img/pieRed" + Math.round( score ) + "_290.png");
			$("#videoScorePanelScore").show();
		}else{
			var imgSrc = $("#videoScoreMain").find("#videoScorePanel").find("img").attr("src" );
			if( imgSrc.length == 22 )return;
			var score = $("#videoScoreContainer").find("div#videoScoreMain").find("#givenScore").val();
			var videoId = $("#videoScoreContainer").find("div#videoScoreMain").find("#videoId").val();
			isGiveScore = true;
			$.ajax({
		        url: WS_PATH + "saveVideoScore.php",
		        dataType : "json",
		        type : "POST",
		        data : { userId : CURRENT_USER_ID, videoId : videoId, score : score },
		        beforeSend: function (request) {
		        	var timeStamp = getMicrotime(true).toString();
		        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
		        	request.setRequestHeader('X-MICROTIME', timeStamp );
				},
		        success : function(data){
		        	isGiveScore = false;
		        	if( data.result == "success" ){
		        		
		        		$("div#videoItem").find("input#videoId[value=" + videoId+ "]").parents("div#videoItem").find("#videoItemScore").find("img").attr("src", "/img/pieRed" + Math.round( data.videoScore ) + "Play_290.png");
		        		$("div#searchVideoList").find("input#videoId[value=" + videoId+ "]").parents("div#searchVideoItemByList").eq(0).find("div#searchVideoItemByListScore").attr("class", "whiteScore" + Math.round( data.videoScore ) );
		        		
		        		var videoNo = $("#videoScoreMain").find("#videoNo").val( );
		        		var videoType = $("#videoScoreMain").find("#videoType").val( );
		        		isShowRed = "N";
		        		showScorePopup( videoId, videoNo, videoType );
		        	}else if( data.result == "failed" ){
		        		alert( data.error );
		        		/*if( data.error == "ALREADY" ){
		            		alert( "You've already give score on this Video.");
		            		// $("#videoScoreContainer").addClass("scorePanelHide");
		            		return;        			
		        		}else if( data.error == "OWNER" ){
		            		alert( "You can't give score on your Video.");
		            		return;        			
		        		} */
		        	}
		        }
			});				
			
			
		}
    	
	});
	$('area[type="giveScore"]').on('mousemove', function(event) {
		if($("#videoScorePanelScore").css("display") != "none" )
			return;
		if( $("#videoScoreMain").find("#isGiven").val( ) == "Y" )
			return;		
		var score = $(this).attr('alt');
		if( score != 'submitScore'){
			var srcImg = $("#videoScoreMain").find("#videoScorePanel").find("img").attr("src");
			if( srcImg.length == 22){
				$("#videoScoreMain").find("#videoScorePanel").find("img").attr("src", "/img/pieNoRed" + Math.round( score ) + "_290.png");
			}else{
				$("#videoScoreMain").find("#videoScorePanel").find("img").attr("src", "/img/pieRed" + Math.round( score ) + "_290.png");
			}
		}					
	});
	$('area[type="giveScore"]').on('mouseout', function(event) {
		if($("#videoScorePanelScore").css("display") != "none" )
			return;
		if( $("#videoScoreMain").find("#isGiven").val( ) == "Y" )
			return;		
		var score = $(this).attr('alt');
		if( score != 'submitScore'){
			var srcImg = $("#videoScoreMain").find("#videoScorePanel").find("img").attr("src");
			if( srcImg.length == 22){
				$("#videoScoreMain").find("#videoScorePanel").find("img").attr("src", "/img/pieNoRed" + Math.round( score ) + "_290.png");
			}else{
				$("#videoScoreMain").find("#videoScorePanel").find("img").attr("src", "/img/pieRed" + Math.round( score ) + "_290.png");
			}		
		}
	});		
	
	$('button#reportCopyPostUrl').zclip({
		path:'/js/ZeroClipboard.swf',
		copy:function(){ return "http://" + $("#hostServer").val() + "/video.php?id=" + base64_encode($("#videoShareBody").find("#videoId").val()); },
		afterCopy: function() { alert("The URL is successfully copied.");  }
	});	
	
	$("#reportToAdmin, #reportDeleteVideo, #reportCopyPostUrl").click( function(event){
		event.stopPropagation();
	});

	$("#videoShareContainer").css("z-index", -1);
	$("#videoShareContainer").css("opacity", "0");
	$("#videoShareContainer").css("filter", "alpha(opacity=0)");
	
	var cache_status = statusHtmlStorage('hashtagList');
	if (cache_status == 1) {
	    hashtagList = JSON.parse(localStorage.getItem('hashtagList'));
	} else {
		$.ajax({
	        url: WS_PATH + "getDefaultHashtag1.php",
	        dataType : "json",
	        type : "POST",
	        beforeSend: function (request) {
	        	var timeStamp = getMicrotime(true).toString();
	        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
	        	request.setRequestHeader('X-MICROTIME', timeStamp );
			},
	        data : { },
	        success : function(data){
	            if(data.result == "success"){
	            	hashtagList = data.hashtagList;
	            	setHtmlStorage('hashtagList', JSON.stringify(data.hashtagList), 60 *60 * 24 );
	            }
	        }
	    });
	}	
	
	
		
	$("#reportToAdmin").click( function(){
		var videoId = $(this).parents("#videoReportBody").find("#videoId").val();
		$.ajax({
	        url: WS_PATH + "reportVideo.php",
	        dataType : "json",
	        type : "POST",
	        beforeSend: function (request) {
	        	var timeStamp = getMicrotime(true).toString();
	        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
	        	request.setRequestHeader('X-MICROTIME', timeStamp );
			},	        
	        data : { userId : CURRENT_USER_ID, videoId : videoId },
	        success : function(data){
	        	if( data.result == "success" ){		
	        		alert("Message sent successfully.");
	        	}
	        }
		});
	});
	
	$("#reportDeleteVideo").click( function(){
		var videoId = $(this).parents("#videoReportBody").find("#videoId").val();
		$.ajax({
	        url: WS_PATH + "deleteVideo.php",
	        dataType : "json",
	        type : "POST",
	        beforeSend: function (request) {
	        	var timeStamp = getMicrotime(true).toString();
	        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
	        	request.setRequestHeader('X-MICROTIME', timeStamp );
			},	        
	        data : { videoId : videoId },
	        success : function(data){
	        	if( data.result == "success" ){
	        		// window.location.href = "search.php";
	        		window.location.reload();
	        	}
	        }
		});
	});
	
	$("#defaultCategory").click( function(){
		$(this).fadeOut();
		var hashtag = $("#hashtag").val();
		for( var i = 0 ; i < hashtagList.length; i ++ ){
			// if( hashtag.toLowerCase() == hashtagList[i].h.toLowerCase() || hashtag.toLowerCase() == hashtagList[i].p.toLowerCase()){
			if( hashtag.toLowerCase() == hashtagList[i].h.toLowerCase() ){				
				$("#hashtag").val( hashtagList[i].p );
				break;
			}
		}		
		
	});
	$("#createCategory").click( function(){
		$(this).fadeOut();
	});
	$("#defaultCategory1").click( function(){
		$(this).fadeOut();
		var keyword = $("#searchTxtKeyword").val();
		for( var i = 0 ; i < hashtagList.length; i ++ ){
			// if( hashtag.toLowerCase() == hashtagList[i].h.toLowerCase() || hashtag.toLowerCase() == hashtagList[i].p.toLowerCase()){
			if( keyword.toLowerCase() == hashtagList[i].h.toLowerCase() ){				
				$("#searchTxtKeyword").val( hashtagList[i].p );
				onClickSearch();
				break;
			}
		}		
		
	});	
});
function onClearText( obj ){
	$(obj).parents("div.inputItem").eq(0).find("input").val("");
}
function onClearTextarea( obj ){
	$(obj).parents("div.inputItem").eq(0).find("textarea").val("");
}
function showPlayPopup( videoId, videoNo, videoType ){
	$("#redTooltip").hide();
	$.ajax({
        url: WS_PATH + "getVideoInfoForScore1.php",
        dataType : "json",
        type : "POST",
        data : { userId : CURRENT_USER_ID, videoId : videoId },
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},
        success : function(data){
        	$("#videoPlayerContainer").find("#videoInfoArea1").find("a").eq(0).text( "@" + data.rb_creator_username );
        	$("#videoPlayerContainer").find("#videoInfoArea1").find("a").eq(0).attr("href", "/profile.php?id=" + base64_encode( data.rb_creator ) );
        	$("#videoPlayerContainer").find("#videoInfoArea1").find("a").eq(1).text( "#" + data.rb_hashtag + " " + Number( data.rb_video_score ).toFixed(2) );
        	$("#videoPlayerContainer").find("#videoInfoArea1").find("a").eq(1).attr("href", "/search.php?h=" + base64_encode( data.rb_hashtag ) );
        }
	});	
	
	var videoUrl = videoNo;
	if( videoType == "Y" || videoType == "V" || videoType == "K" || videoType == "T" || videoType == "F" || videoType == "D" || videoType == "C"){
		var strHTML = '<iframe style="width:100%; height: 100%;" src="' + videoUrl + '" frameborder="0" allowfullscreen scrolling="no"></iframe>';
	}
	
	$("#videoPlayerIframe").html( strHTML );	

	$("#videoPlayerIframe").show();
	$("#videoPlayerContainer").find("#videoId").val( videoId );
	$("#videoPlayerContainer").find("#videoNo").val( videoNo );
	$("#videoPlayerContainer").find("#videoType").val( videoType );
	$("#videoPlayerContainer").show();
}
function onCloseVideoPlayerContainer( ){
	$("#videoPlayerIframe").html("");
	$("#videoPlayerIframe").hide();
	$("#videoPlayerContainer").hide();
	$("#videoPlayerContainer").find("#videoInfoArea").find("a").text("");
}

function showScorePopup( videoId, videoNo, videoType ){
	$("#redTooltip").hide();
	$("#videoScoreMain").find("#videoNo").val( videoNo );
	$("#videoScoreMain").find("#videoType").val( videoType );
	$.ajax({
        url: WS_PATH + "getVideoInfoForScore1.php",
        dataType : "json",
        type : "POST",
        data : { userId : CURRENT_USER_ID, videoId : videoId },
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        success : function(data){
        	onCloseVideoPlayerContainer();
        	onCloseVideoShareContainer();
        	onCloseVideoScoreContainer();
        	onCloseVideoReportContainer();        	
        	
        	$("#videoScoreMain").find("#videoId").val( videoId );
        	$("#videoScoreMain").find("#videoInfoArea").find("a").eq(0).text( "@" + data.rb_creator_username );
        	$("#videoScoreMain").find("#videoInfoArea").find("a").eq(0).attr("href", "/profile.php?id=" + base64_encode( data.rb_creator ) );
        	$("#videoScoreMain").find("#videoInfoArea").find("a").eq(1).text( "#" + data.rb_hashtag + " " + Number( data.rb_video_score ).toFixed(1) );
        	$("#videoScoreMain").find("#videoInfoArea").find("a").eq(1).attr("href", "/search.php?h=" + base64_encode( data.rb_hashtag ) );
        	if( data.isScored == "Y"){
        		$("#videoScoreMain").find("#videoScoreInfoByMeArea").show();
	        	$("#videoScoreMain").find("#videoScoreInfoByMeArea").find("a").eq(0).html(
	        			'<a href="profile.php?id=' + base64_encode( CURRENT_USER_ID ) + '">@' + data.myUsername + '</a>' 
	        				+ ' (' + ((data.myHashtagScore * 1).toFixed(1)) + ')' 
	        				+ ' : ' + data.myGivenScore + '</div>' );
	        	$("#videoScoreUserGaveScoreList").show();
	        	
	        	if( isShowRed == "Y" ){
	        		$("#videoScorePanelScore").show();
		        	// $("#videoScoreMain").find("#videoScorePanel").find("img").attr("src", "/img/pieRed" + Math.round( data.rb_video_score ) + "_290.png");
		        	$("#videoScoreMain").find("#isGiven").val( "Y" );
	        	}else{
	        		$("#videoScorePanelScore").hide();
		        	// $("#videoScoreMain").find("#videoScorePanel").find("img").attr("src", "/img/pieNoRed" + Math.round( data.rb_video_score ) + "_290.png");
		        	$("#videoScoreMain").find("#isGiven").val( "Y" );	        		
	        	}

        	}else if ( data.rb_creator == CURRENT_USER_ID ){
        		$("#videoScoreUserGaveScoreList").show();
        		$("#videoScoreMain").find("#videoScoreInfoByMeArea").hide();
        		$("#videoScorePanelScore").hide();
        		// $("#videoScoreMain").find("#videoScorePanel").find("img").attr("src", "/img/pieNoRed" + Math.round( data.rb_video_score ) + "_290.png");
        		$("#videoScoreMain").find("#isGiven").val( "Y" );
        	}else{
        		$("#videoScoreMain").find("#videoScoreInfoByMeArea").hide();
        		$("#videoScoreUserGaveScoreList").hide();
        		$("#videoScorePanelScore").hide();
        		// $("#videoScoreMain").find("#videoScorePanel").find("img").attr("src", "/img/pieNoRed" + Math.round( data.rb_video_score ) + "_290.png");
        		$("#videoScoreMain").find("#isGiven").val( "N" );
        	}
        	
        	if( data.isScored != "Y" && data.rb_creator != CURRENT_USER_ID )
        		$("#videoScoreMain").find("#videoScorePanel").find("img").attr("src", "/img/pieNoRed0" + "_290.png");
        	else if( isShowRed == "N" )
        		$("#videoScoreMain").find("#videoScorePanel").find("img").attr("src", "/img/pieNoRed" + Math.round( data.rb_video_score ) + "_290.png");
        	else
        		$("#videoScoreMain").find("#videoScorePanel").find("img").attr("src", "/img/pieRed" + Math.round( data.rb_video_score ) + "_290.png");
        	
        	$("#videoScoreMain").find("#videoScore").val( data.rb_video_score );
        	$("#videoScoreMain").find("#videoScoreViewCnt").text( "Views : " + data.cntView );
        	$("#videoScoreMain").find("#videoScoreShareCnt").text( "Shares : " + data.cntShare );
        	$("#videoScoreMain").find("#videoScoreCommentCnt").text( "Comments : " + data.cntComment);
        	$("#videoScoreMain").find("#videoScoreScoreCnt").text( "Scores : " + data.cntScore );
        	// $("#videoScoreMain").find("#videoScoreAvg").text( "Avg. Score : " + Math.round(Number(data.rb_video_score) * 10 ) / 10 );
        	$("#videoScoreMain").find("#givenScore").val( data.myGivenScore );
        	// 
        	
        	showScore = data.rb_video_score;
        	$("#videoScoreUserGaveScoreList").html("");
        	for( var i = 0; i < data.scoreList.length; i ++ ){
        		var obj = $("<div></div>");
        		$(obj).html('<a href="profile.php?id=' + base64_encode( data.scoreList[i].rb_user ) + '">@' + data.scoreList[i].rb_username + '</a>' 
        				+ ' (' + (data.scoreList[i].rb_hashtag_score * 1).toFixed(1) + ')' 
        				+ ' : ' + data.scoreList[i].rb_given_score + '</div>');
        		$("#videoScoreUserGaveScoreList").append( $(obj) );
        	}
        	$("#videoScoreContainer").removeClass("scorePanelHide");
        }
	});
}
var isGiveScore = false;
function onCloseVideoScoreContainer( ){
	$("#videoScoreContainer").addClass("scorePanelHide");
	return;
	if( isGiveScore == true ) return;
	if( $("#isGiven").val() == "Y"){
		
		var score = $("#videoScoreContainer").find("div#videoScoreMain").find("#givenScore").val();
		var videoId = $("#videoScoreContainer").find("div#videoScoreMain").find("#videoId").val();
		$("#videoScoreContainer").find(".popupBtnPrev").attr("click","");
		isGiveScore = true;
		$.ajax({
	        url: WS_PATH + "saveVideoScore.php",
	        dataType : "json",
	        type : "POST",
	        data : { userId : CURRENT_USER_ID, videoId : videoId, score : score },
	        beforeSend: function (request) {
	        	var timeStamp = getMicrotime(true).toString();
	        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
	        	request.setRequestHeader('X-MICROTIME', timeStamp );
			},	        
	        success : function(data){
	        	isGiveScore = false;
	        	$("#videoScoreContainer").find(".popupBtnPrev").attr("click","onCloseVideoScoreContainer()");
	        	if( data.result == "success" ){	            	
	        		$("#videoScoreContainer").addClass("scorePanelHide");
	        		$("div#videoItem").find("input#videoId[value=" + videoId+ "]").parents("div#videoItem").find("#videoItemScore").find("img").attr("src", "/img/pieRed" + Math.round( data.videoScore ) + "Play_290.png");
	        	}else if( data.result == "failed" ){
	        		if( data.error == "ALREADY" ){
	            		alert( "You've already give score on this Video.");
	            		$("#videoScoreContainer").addClass("scorePanelHide");
	            		return;        			
	        		}else if( data.error == "OWNER" ){
	            		alert( "You can't give score on your Video.");
	            		$("#videoScoreContainer").addClass("scorePanelHide");
	            		return;        			
	        		}
	        	}
	        }
		});			
	}else{
		$("#videoScoreContainer").addClass("scorePanelHide");
	}
	
}
function fnVideoShare( obj ){

}
function fnVideoShareEmail( obj ){
	var videoId = $(obj).parents("#videoShareBody").find("#videoId").val();
	var email = $(obj).parents("#videoShareBody").find("#emailShare").val();
	if( email == "" ){ alert("Please input the Email Address."); return; }
	if( !validateEmail(email) ){ alert("Please input the Email Address correctly."); return; }
	
	$.ajax({
        url: WS_PATH + "shareVideoEmail.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        data : { userId : CURRENT_USER_ID, videoId : videoId, email : email },
        success : function(data){
        	alert( "Email sent successfully." );
        }
	});	
}
function fnVideoScore( videoId, score ){
	if( isGiveScore == true ) return;
	if( $("#isLogin").val() == "N" ){
		alert("You have to login for this.");
		return;
	}
	isGiveScore = true;
	$.ajax({
        url: WS_PATH + "saveVideoScore.php",
        dataType : "json",
        type : "POST",
        data : { userId : CURRENT_USER_ID, videoId : videoId, score : score },
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        success : function(data){
        	isGiveScore = false;
        	if( data.result == "success" ){
            	var videoScore = data.videoScore;
            	
            	$("#videoScoreMain").find("#videoScorePanel").find("img").attr("src", "/img/pieRed" + Math.round( videoScore ) + "_290.png");
            	$("#videoScoreMain").find("#videoScoreAvg").text("Avg. Score : " + Math.round( Number(videoScore) * 10 ) / 10 );
            	
            	var objDiv = $("<div></div>");
            	var objA = $("<a></a>");
            	objA.attr("href", "profile.php?id=" + base64_encode( data.userId ));
            	objA.text( "@" + data.username );
            	objDiv.append( objA );
            	objDiv.html( objDiv.html() + " : " + score );
            	$("#videoScoreUserGaveScoreList").append( objDiv );
            	
            	$("div#videoItem").find("input#videoId[value=" + videoId+ "]").parents("div#videoItem").find("#videoItemScore").find("img").attr("src", "/img/pieRed" + Math.round(videoScore) + "Play_290.png");
            	
        	}else if( data.result == "failed" ){
        		if( data.error == "ALREADY" ){
            		alert( "You've already give score on this Video.");
            		return;        			
        		}else if( data.error == "OWNER" ){
            		alert( "You can't give score on your Video.");
            		return;        			
        		}
        	}
        }
	});		
}
function fnAttachEvent( obj ){
	var videoId = $(obj).parents("#videoItem").find("#videoId").val();
	var videoNo = $(obj).parents("#videoItem").find("#videoNo").val();
	var videoType = $(obj).parents("#videoItem").find("#videoType").val();
	isShowRed = "N";
	if( $(obj).attr('alt') == "play" ){
		// showPlayPopup( videoId, videoNo, videoType );
		showScorePopup( videoId, videoNo, videoType );
	}else{
		showScorePopup( videoId, videoNo, videoType );
	}
}
function fnMouseOver( obj ){
	if( $(obj).attr('alt') == "play" ){
		return;
	}
	$(obj).parents("#videoItem").eq(0).find("#videoItemScore").find("img").attr("src", "/img/pieRed" + $(obj).attr('alt') + "Play_290.png");
}
function fnMouseOut( obj ){
	if( $(obj).attr('alt') == "play" ){
		return;
	}	
	var videoScore = $(obj).parents("#videoItem").find("#videoScore").val();
	$(obj).parents("#videoItem").eq(0).find("#videoItemScore").find("img").attr("src", "/img/pieRed" + Math.round( videoScore ) + "Play_290.png");
}
function onKeyUpCommentText( obj, event ){
	if( event.ctrlKey && event.keyCode == 13 ){
		$(obj).val( $(obj).val() + "\n" );
	}else if( event.keyCode == 13 ){
		onCommentSubmit( obj );
	}
}
var isCommenting = false;
function onCommentSubmit( obj ){
	if( $("#isLogin").val() == "N" ){
		alert("You have to login for this.");
		return;
	}
	if( isCommenting ) return;
	$("#loadingContainer").fadeIn();
	isCommenting = true;
	var videoId = $(obj).parents("#videoItem").eq(0).find("#videoId").val();
	var txtComment = $(obj).parents("div#videoCommentArea").eq(0).find("textarea#videoItemCommentText").val();
	if( txtComment == "" ){alert("Please input the comment."); return; }
	var test = txtComment;
	test = test.replace("\n", "");
	test = test.replace(/\s+/g, '');
	if( test == "" ){ return; }
	$.ajax({
        url: WS_PATH + "saveComment.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        data : { userId : CURRENT_USER_ID, videoId : videoId, txtComment : txtComment },
        success : function(data){
        	$("#loadingContainer").fadeOut();
        	isCommenting = false;
    		var objCloneComment = $("#cloneVideoItemComment").clone();
    		objCloneComment.show();
    		objCloneComment.attr("id", "videoItemComment");
    		objCloneComment.find("#commentId").val( data.commentId );
    		objCloneComment.find("#commentUserId").val( CURRENT_USER_ID );
    		
    		var strUsername = "@" + data.username;
    		strUsername = "<a href='/profile.php?id=" + base64_encode( data.userId ) + "'>" + strUsername + "</a>";    		
    		
    		var content = txtComment;
    		content = replaceUsername( content );
    		content = replaceHashtag( content );
    		objCloneComment.find("#videoItemCommentArea").html( strUsername + " : " + content );
    		
    		objCloneComment.find("a.js-link").click(function (event){ 
      	  		event.preventDefault();
      	  		fnJsLink( this );
      	  	});    		
    		
    		$(obj).parents("#videoItem").eq(0).find("#videoItemCommentList").append( objCloneComment ); // prepend
    		
    		$(obj).parents("#videoItem").eq(0).find("#videoItemCommentText").val("");
        }
	});	
}
function fnJsLink( obj ){
	var username = $(obj).attr("href");
	$.ajax({
        url: WS_PATH + "getUserIdFromUsername.php",
        dataType : "json",
        type : "POST",
        data : { username : username},
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        success : function(data){
        	if( data.result == "success" ){
        		window.location.href = "profile.php?id=" + base64_encode( data.userId ); 
        	}else{
        		alert("This user is not exist.");
        	}
        }
	});	
}
function onVideoShare( videoId ){
	$.ajax({
        url: WS_PATH + "getVideoInfo.php",
        dataType : "json",
        type : "POST",
        data : { videoId : videoId},
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        success : function(data){
        	if( data.result == "success" ){
        		
        		onCloseVideoPlayerContainer();
        		onCloseVideoShareContainer();
        		onCloseVideoScoreContainer();
        		onCloseVideoReportContainer();	       		
        		
        		var title = data.videoItem.rb_content;
        		var via = "balloonred author";
        		var urlFB = "https://www.facebook.com/sharer/sharer.php?u=" + encodeURIComponent( "http://" + $("#hostServer").val() + "/video.php?id=" + base64_encode( videoId ) );
        		var urlTW = "https://twitter.com/share?url=" + encodeURIComponent( "http://" + $("#hostServer").val() + "/video.php?id=" + base64_encode( videoId ) )
        					+ "&text=" + encodeURIComponent(title) + "&via=" + encodeURIComponent( $("#currentUsername").val() + " " + via);
        		$("#videoShareContainer").find("#shareOnFB").attr( "href", urlFB );
        		$("#videoShareContainer").find("#shareOnTW").attr( "href", urlTW );
        		$("#videoShareContainer").find("#videoId").val( videoId );
        		
        		$("#videoShareContainer").css("z-index", 30);
        		$("#videoShareContainer").css("opacity", "1");
        		$("#videoShareContainer").css("filter", "alpha(opacity=100)");	
        		$("#emailShare").val( "" ); 
        	}
        }
	});	

}

function onVideoReport( videoId ){
	if( $("#isLogin").val() == "N" ){
		alert("You have to login for this.");
		return;
	}
	
	$.ajax({
        url: WS_PATH + "getVideoInfo.php",
        dataType : "json",
        type : "POST",
        data : { videoId : videoId},
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        success : function(data){
        	if( data.result == "success" ){
        		
        		onCloseVideoPlayerContainer();
        		onCloseVideoShareContainer();
        		onCloseVideoScoreContainer();
        		onCloseVideoReportContainer();        		
        		
        		var videoUserId = data.videoItem.rb_user;
        		
        		$("#videoReportContainer").show();
        		$("#hashtag").focus();
        		$("#videoReportContainer").find("#videoId").val( videoId );	
        		if( videoUserId == CURRENT_USER_ID ){
        			$("#reportToAdmin").hide();
        			$("#resetArea").show();
        		}else{
        			$("#reportToAdmin").show();
        			$("#resetArea").hide();
        		}
        	}
        }
	});		
	

}

function onCloseVideoShareContainer(){
	$("#videoShareContainer").css("z-index", -1);
	$("#videoShareContainer").css("opacity", 0);
}
function onCloseVideoReportContainer( ){
	$("#videoReportContainer").hide();
	$("#hashtag").val("");
}
function onCommentReport( obj ){
	if( $("#isLogin").val() == "N" ){ alert("You have to login for this."); return;	}
	var commentId = $( obj ).parents("#videoItemComment").eq(0).find("#commentId").val();
	var userId = $( obj ).parents("#videoItemComment").eq(0).find("#commentUserId").val();

	if( userId == CURRENT_USER_ID ){
		if( confirm("Are you sure you want to delete this comment?") ){
			$.ajax({
		        url: WS_PATH + "deleteComment.php",
		        dataType : "json",
		        type : "POST",
		        beforeSend: function (request) {
		        	var timeStamp = getMicrotime(true).toString();
		        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
		        	request.setRequestHeader('X-MICROTIME', timeStamp );
				},
		        data : { commentId : commentId },
		        success : function(data){
		        	if( data.result == "success" ){
		        		alert("Comment deleted successfully.");
		        		$(obj).parents("#videoItemComment").eq(0).remove();
		        	}
		        }
			});        				
		}
	}else{
		if( confirm("Are you sure you want to report this comment?") ){
			$.ajax({
		        url: WS_PATH + "reportComment.php",
		        dataType : "json",
		        type : "POST",
		        beforeSend: function (request) {
		        	var timeStamp = getMicrotime(true).toString();
		        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
		        	request.setRequestHeader('X-MICROTIME', timeStamp );
				},        			        
		        data : { userId : CURRENT_USER_ID, commentId : commentId },
		        success : function(data){
		        	if( data.result == "success" ){
		        		alert("Comment reported successfully.");
		        	}
		        }
			});        				
		}
	}

}
function detectmob() { 
	 if( navigator.userAgent.match(/Android/i)
	 || navigator.userAgent.match(/webOS/i)
	 || navigator.userAgent.match(/iPhone/i)
	 || navigator.userAgent.match(/iPad/i)
	 || navigator.userAgent.match(/iPod/i)
	 || navigator.userAgent.match(/BlackBerry/i)
	 || navigator.userAgent.match(/Windows Phone/i)
	 ){
	    return true;
	  }
	 else {
	    return false;
	  }
}
function onExpandComments( obj ){
	$(obj).parents("div#videoItem").eq(0).find("div#videoItemComment").fadeIn();
	$(obj).parents("div#videoItemComment").eq(0).hide();
}
function onMenu( ){
	if( $("#menuList").hasClass("menuHeight")){
		$("#menuList").removeClass("menuHeight");
		$(".menuListBackground").hide();		
	}else{
		$("#menuList").addClass("menuHeight");
		$(".menuListBackground").show();		
	}
}
function isPad() { 
	if( navigator.userAgent.match(/iPad/i) ){
		return true;
	}else {
		return false;
	}
}

function onEnterHashtag(){
	var hashtag = $("#hashtag").val();
	if( hashtag.length > 0 ){
		var isExistStorage = false;
		for( var i = 0 ; i < hashtagList.length; i ++ ){
			// if( hashtag.toLowerCase() == hashtagList[i].rb_hashtag.toLowerCase() || hashtag.toLowerCase() == hashtagList[i].rb_parent_hashtag.toLowerCase()){
			if( hashtag.toLowerCase() == hashtagList[i].h.toLowerCase() ){
				$("#defaultCategory").eq(0).html('USE "' + hashtagList[i].p + '" INSTEAD');
				$("#defaultCategory").eq(0).fadeIn();
				isExistStorage = true;
				break;
			}else{
				$("#defaultCategory").eq(0).fadeOut();
			}
		}
		if( isExistStorage == false ){
			if( hashtag.length <=3 ) return;
			var xhr;
			if( xhr && xhr.readystate != 4 ){
				xhr.abort();
			}			
			$.ajax({
		        url: WS_PATH + "getParentHashtag.php",
		        dataType : "json",
		        type : "POST",
		        beforeSend: function (request) {
		        	var timeStamp = getMicrotime(true).toString();
		        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
		        	request.setRequestHeader('X-MICROTIME', timeStamp );
				},        			        
		        data : { keyword : hashtag },
		        success : function(data){
		        	if( data.result == "success" ){
						$("#defaultCategory").eq(0).html('USE "' + data.parentHashtag + '" INSTEAD');
						$("#defaultCategory").eq(0).fadeIn();
		        	}
		        }
			});			
		}
	}else{
		$("#defaultCategory").eq(0).fadeOut();
	}
}

function onEnterKeyword(){
	var keyword = $("#searchTxtKeyword").val();
	if( keyword.length > 0 ){
		var isExistStorage = false;
		for( var i = 0 ; i < hashtagList.length; i ++ ){
			if( keyword.toLowerCase() == hashtagList[i].h.toLowerCase() ){
				$("#defaultCategory1").eq(0).html('USE "' + hashtagList[i].p + '" INSTEAD');
				$("#defaultCategory1").eq(0).fadeIn();
				$("#searchBackground").show();
				isExistStorage = true;
				break;
			}else{
				$("#defaultCategory1").eq(0).fadeOut();
				$("#searchBackground").hide();
			}
		}
		if( isExistStorage == false ){
			if( keyword.length <=3 ) return;
			var xhr;
			if( xhr && xhr.readystate != 4 ){
				xhr.abort();
			}
			xhr = $.ajax({
		        url: WS_PATH + "getParentHashtag.php",
		        dataType : "json",
		        type : "POST",
		        beforeSend: function (request) {
		        	var timeStamp = getMicrotime(true).toString();
		        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
		        	request.setRequestHeader('X-MICROTIME', timeStamp );
				},        			        
		        data : { keyword : keyword },
		        success : function(data){
		        	if( data.result == "success" ){
		        		$("#defaultCategory1").eq(0).html('USE "' + data.parentHashtag + '" INSTEAD');
						$("#defaultCategory1").eq(0).fadeIn();
						$("#searchBackground").show();
		        	}
		        }
			});
		}
	}else{
		$("#defaultCategory1").eq(0).fadeOut();
		$("#searchBackground").hide();
	}
}

function onResetHashtag( obj ){
	
	var newHashtag = $("#hashtag").eq(0).val();
	var videoId = $(obj).parents("div#videoReportBody").eq(0).find("#videoId").val();

	$.ajax({
        url: WS_PATH + "resetHashtag.php",
        dataType : "json",
        type : "POST",
        data : { hashtag : newHashtag, videoId : videoId },
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        success : function(data){
        	if( data.result == "success" ){
        		alert("Hashtag has been reset successfully.");
        		onCloseVideoReportContainer( );
        		$("input#videoId[value=" + videoId + "]").parents("div#videoItem").eq(0).find("div#videoItemHashtag").find("a").attr("href", "search.php?h=" + base64_encode( newHashtag ));
        		$("input#videoId[value=" + videoId + "]").parents("div#videoItem").eq(0).find("div#videoItemHashtag").find("a").text( "#" + newHashtag );
        		// window.location.reload();
        	}else{
        		alert("Failed on resetting Hashtag.");
        	}
        }
	});
}

function hideCategoryMenu( ){
	$("#defaultCategory").fadeOut();
	$("#defaultCategory1").fadeOut();
	$("#createCategory").fadeOut();
	$("#searchBackground").hide();
}
function onShowVideoPlay( ){
	var videoId = $("#videoScoreContainer").find("#videoId").val();
	var videoNo = $("#videoScoreContainer").find("#videoNo").val();
	var videoType = $("#videoScoreContainer").find("#videoType").val();
	
	//onCloseVideoPlayerContainer();
	onCloseVideoShareContainer();
	onCloseVideoScoreContainer();
	onCloseVideoReportContainer();
	
	showPlayPopup( videoId, videoNo, videoType );	
}

function onShowVideoReport( obj ){
	var videoId = $(obj).parents("div").eq(0).find("#videoId").val();	
	onVideoReport( videoId );
}

function onShowVideoShare( obj ){
	var videoId = $(obj).parents("div").eq(0).find("#videoId").val();	
	onVideoShare( videoId );
}
function onClickFollowingIcon( obj ){
	if( $("#isLogin").val() == "N" ){
		alert("You have to login for this.");
		return;
	}
	var type;

	if( $(obj).attr("src") == "img/btnRedRight.png" ){
		type = "UNFOLLOW";
	}else{
		type = "FOLLOW";
	}
	var followingId = $(obj).parents("div").eq(0).parents("div").eq(0).find("#userId").val();
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
        			$(obj).attr("src", "img/btnRedRight.png"); 
        		}else{
        			$(obj).attr("src", "img/btnGreyRight.png");
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
function onShowVideoScore( ){
	var videoId = $("#videoPlayerContainer").find("#videoId").val();
	var videoNo = $("#videoPlayerContainer").find("#videoNo").val();
	var videoType = $("#videoPlayerContainer").find("#videoType").val();
	isShowRed = "N";
	showScorePopup( videoId, videoNo, videoType );
}
function onBack( ){
	history.back();
	window.location.href = "search.php";
}