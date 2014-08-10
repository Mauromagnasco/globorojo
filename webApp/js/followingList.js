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
        url: WS_PATH + "followingList.php",
        dataType : "json",
        type : "POST",
        beforeSend: function (request) {
        	var timeStamp = getMicrotime(true).toString();
        	request.setRequestHeader('X-HASH', getHash(timeStamp, APP_SECRET_KEY));
        	request.setRequestHeader('X-MICROTIME', timeStamp );
		},	        
        data : { userId : $("#userId").val() },
        success : function(data){
            if(data.result == "success"){
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
            		
        			$("#userList").append( objClone );
        		}
        		if( data.userList.length == 0 ){
        			$("#userList").html( "<div class='noData'>This user doesn't follow anyone.</div>" );
        		}            	
            }
        }
    });	
});