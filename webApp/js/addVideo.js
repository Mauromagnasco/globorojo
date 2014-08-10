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
var isAjax = false;

$(document).ready( function(){	
	$("#videoURL").keyup( function(event){
		if( event.keyCode == 13 )
			$("#description").focus();
	});
	$("#description").keyup( function(event){
		if( event.keyCode == 13 )
			$("#hashtag").focus();
	});
	
	$("#hashtag").keyup( function(event){
		if( event.keyCode == 13 )
			onSaveVideo();
	});
	
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
            }
        }
    });	
	var vid = $("#vid").val();
	if( vid != "" ){
		$.ajax({
	        url: WS_PATH + "getVideoTemp.php",
	        dataType : "json",
	        type : "POST",
	        beforeSend: function (request) {
	        	var timeStamp = getMicrotime(true).toString();
	        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
	        	request.setRequestHeader('X-MICROTIME', timeStamp );
			},        
	        data : { vid : vid },
	        success : function(data){
	            if(data.result == "success"){
	                $("#videoURL").val( data.rb_url );
	                $("#description").val( data.rb_description );
	                $("#hashtag").val( data.rb_hashtag );
	                if( data.rb_facebook == "Y" ){
	                	$("div#shareSocial").eq(0).attr("status", "checked");
	                	$("div#shareSocial").eq(0).css("background", "url('/img/btnChecked.png')");
	                }else{
	                	$("div#shareSocial").eq(0).attr("status", "unchecked");
	                	$("div#shareSocial").eq(0).css("background", "url('/img/btnUnchecked.png')");	                	
	                }
	                
	                if( data.rb_twitter == "Y" ){
	                	$("div#shareSocial").eq(1).attr("status", "checked");
	                	$("div#shareSocial").eq(1).css("background", "url('/img/btnChecked.png')");
	                }else{
	                	$("div#shareSocial").eq(1).attr("status", "unchecked");
	                	$("div#shareSocial").eq(1).css("background", "url('/img/btnUnchecked.png')");	                	
	                }
	                
	            }
	        }
	    });			
	}
	
});

var isSaving = false;
function onSaveVideo( ){
	if( isSaving == true ) return;

	var isShareFB = $("div#shareSocial").eq(0).attr("status")=="checked"?"Y":"N";
	var isShareTW = $("div#shareSocial").eq(1).attr("status")=="checked"?"Y":"N";
	
	var isLogin = $("#isLogin").val( );
	if( isLogin == "N" ){ alert("You have to login for this."); window.location.href = "start.php"; }
	var videoUrl = $("#videoURL").val( );
	var description = $("#description").val( );
	var hashtag = $("#hashtag").val( );
	
	if( videoUrl == "" ){ alert("Please input the Video URL."); return; }
	// if( description == "" ){ alert("Please input the Description."); return; }
	if( validateUsername( hashtag ) ){ alert("Category mustn't include space, special characters."); return; }
	if( hashtag == "" ){ alert("Please input the Hashtag."); return; }
	var arr = hashtag.split(" ");
	if( arr.length > 1 ){ alert("Use one hashtag only."); return; }
	if( !validateYouTube( videoUrl ) && !validateVimeo( videoUrl ) && !validateKickStarter( videoUrl ) && !validateTed( videoUrl ) && !validateFacebook( videoUrl ) && !validateFunnyOrDie( videoUrl ) && !validateCollegeHumor( videoUrl )){
		alert("In the moment we can attach videos from Youtube, Vimeo, KickStarter, Ted, Facebook, FunnyOrDie and CollegeHumor only, sorry."); return;
	}
	isSaving = true;
	$("#loadingContainer").fadeIn();	
	$.ajax({
        url: WS_PATH + "addVideo.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        data : { userId : CURRENT_USER_ID, videoUrl : videoUrl, description : description, category : hashtag, shareFacebook : isShareFB, shareTwitter : isShareTW },
        success : function(data){
            if(data.result == "success"){
                alert( "Video registered successfully.");
                window.location.href = "search.php";
                return;
            }else{
            	alert( data.error );
            	$("#loadingContainer").fadeOut();
            	isSaving = false;
            	return;
            }
        }
    });		
}
function onClickFacebook( ){	
	if( $("#isFacebook").val() == "N" ){
		var isCheckedFB = $("div#shareSocial").eq(0).attr("status")=="checked"?"Y":"N";
		var isCheckedTW = $("div#shareSocial").eq(1).attr("status")=="checked"?"Y":"N";
		isAjax = true;
		var videoUrl = $("#videoURL").val( );
		var description = $("#description").val( );
		var hashtag = $("#hashtag").val( );
		
		$.ajax({
			url: WS_PATH + "addVideoTemp.php",
	        dataType : "json",
	        type : "POST",
	        beforeSend: function (request) {
	        	var timeStamp = getMicrotime(true).toString();
	        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
	        	request.setRequestHeader('X-MICROTIME', timeStamp );
			},
	        data : { videoUrl : videoUrl, description : description, hashtag : hashtag, isCheckedFB : isCheckedFB, isCheckedTW : isCheckedTW },
	        success : function(data){
	            if(data.result == "success"){
	            	window.location.href = "application.php?vid=" + data.videoTempId;
	            }
	        }
	    });
	}
}
function onClickTwitter( ){
	if( $("#isTwitter").val() == "N" ){
		var isCheckedFB = $("div#shareSocial").eq(0).attr("status")=="checked"?"Y":"N";
		var isCheckedTW = $("div#shareSocial").eq(1).attr("status")=="checked"?"Y":"N";
		isAjax = true;
		var videoUrl = $("#videoURL").val( );
		var description = $("#description").val( );
		var hashtag = $("#hashtag").val( );
		
		$.ajax({
	        url: WS_PATH + "addVideoTemp.php",
	        dataType : "json",
	        type : "POST",
	        beforeSend: function (request) {
	        	var timeStamp = getMicrotime(true).toString();
	        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
	        	request.setRequestHeader('X-MICROTIME', timeStamp );
			},
	        data : { videoUrl : videoUrl, description : description, hashtag : hashtag, isCheckedFB : isCheckedFB, isCheckedTW : isCheckedTW },
	        success : function(data){
	            if(data.result == "success"){
	            	window.location.href = "application.php?vid=" + data.videoTempId;
	            }
	        }
	    });
	}
}
function onShareSocial( obj ){
	if( isAjax == true ) return;
	var ind = $("div#shareSocial").index( $(obj));
	if( $(obj).attr("status") == "checked" ){
		$(obj).css("background", "url('/img/btnUnchecked.png')");
		$(obj).attr("status", "unchecked" );
	}else{
		$(obj).css("background", "url('/img/btnChecked.png')");
		$(obj).attr("status", "checked" );
		if( ind == 0 ){
			onClickFacebook( );
		}else{
			onClickTwitter( );
		}
	}
}