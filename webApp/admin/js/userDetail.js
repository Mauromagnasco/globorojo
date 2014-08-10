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
$(document).ready(function(){
	$("input#imageUpload").change( function(){
		$(this).parents("form").ajaxForm({
			target: '#' + $(this).parents("form").find("#imagePrevDiv").val()
		}).submit();
	});
});
function onUserSave( ){
	var userId = $("#userId").val( );
	var username = $("#username").val( );
	var password = $("#password").val( );
	var email = $("#email").val( );
	var name = $("#name").val( );
	var photo = $("#previewImage").find("img").attr("src");
	var cred = $("#cred").val( );
	var adminYn = $("#adminYn").val( );
	photo = photo.substring( 3 );
	if( username == "" ){ alert("Please input the Username."); return; }
	if( email == "" ){ alert("Please input the Email Address."); return; }
	if( !validateEmail( email ) ){ alert("Please input the Email Address correctly."); return; }
	if( userId == "" ){ if( password == "" ){ alert("Please input the Password."); return; } }
	
	$.ajax({
        url: "async-saveUser.php",
        dataType : "json",
        type : "POST",
        data : { userId : userId, username : username, password : password, email : email, name : name, photo : photo, cred : cred, adminYn : adminYn },
        success : function(data){
            if(data.result == "success"){
                alert("User saved successfully.");
                return;
            }
        }
    });	
		
}