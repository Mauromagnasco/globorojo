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
function onVideoSave( ){
	var videoId = $("#videoId").val( );
	var videoUrl = $("#videoUrl").val( );
	var content = $("#content").val( );
	var hashtag = $("#hashtag").val( );
	var score = $("#score").val( );
	
	$.ajax({
        url: "async-saveVideo.php",
        dataType : "json",
        type : "POST",
        data : { videoId : videoId, videoUrl : videoUrl, content : content, hashtag : hashtag, score : score },
        success : function(data){
            if(data.result == "success"){
                alert("Video saved successfully.");
                return;
            }
        }
    });	
		
}