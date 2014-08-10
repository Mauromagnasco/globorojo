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
	$("#btnSignUp").click( function(){
		var referalCode = $("#referalCode").val();
		if( referalCode == "" || referalCode.length != 20 ){
			alert("Please input the Referral Code correctly."); return;
		}
		window.location.href = "signup.php?ref=" + referalCode;
	});
	$("#btnLogin").click( function(){
		window.location.href = "login.php";
	});
});