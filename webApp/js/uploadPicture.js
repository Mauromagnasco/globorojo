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
var x = 0, y = 0, w = 0, h = 0;
var objCrop;
$(document).ready(function () {
	$('div#previewPhotoImage1').find("img").Jcrop({
		onSelect: onSelectArea,
		onRelease : onReleaseArea,
		aspectRatio : 1
	}, function(){
		objCrop = this;
	});

	$("input#imageUpload").change( function(){
		$(this).parents("form").ajaxForm({
			target: '#' + $(this).parents("form").find("#imagePrevDiv").val(),
			success : function(){
				$('div#previewPhotoImage1').find("img").Jcrop({
					onSelect: onSelectArea,
					onRelease : onReleaseArea,
					aspectRatio : 1
				}, function(){
					objCrop = this;
				});				
			}
		}).submit();
	});
	if (navigator.userAgent.match(/IEMobile\/10\.0/)) {
		$("#profileUploadPicture").hide();
	}
	
	$.ajax({
        url: WS_PATH + "getUserProfileInfo.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        data : { userId : CURRENT_USER_ID, currentUserId : CURRENT_USER_ID },
        success : function(data){
            if(data.result == "success"){
            	$("#previewPhotoImage1").find("img").attr("src", data.photo);
            }
        }
    });	
	
});
function onSelectArea( c ){
	x = c.x;
	y = c.y;
	w = c.w;
	h = c.h;
}
function onReleaseArea( ){
	x = 0;
	y = 0;
	w = 0;
	h = 0;
}
function onSavePicture( ){
	var sWidth = $("div#previewPhotoImage1").find("img").width();
	var sHeight = $("div#previewPhotoImage1").find("img").height();
	var srcImg = $("div#previewPhotoImage1").find("img").attr("src");
	$.ajax({
        url: WS_PATH + "cropPicture.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},        
        data : { userId : CURRENT_USER_ID, x : x, y : y, w : w, h : h, sWidth : sWidth, sHeight : sHeight, srcImg : srcImg },
        success : function(data){
            if(data.result == "success"){
            	window.location.href = "profile.php";
            }
        }
    });
}

function onProfileUploadPicture( ){
	$(".findFriends").find('input[type=file]').click();
}