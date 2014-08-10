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
function getPositions(regex, str) {
    var counts = [], m;
    while (m = regex.exec(str)) {
        counts.push(regex.lastIndex - m[0].length);
    }
    return counts;
}

function getStartEndPositions( str, ch ){
    var regex;
    if( ch == "@" )
        regex = /[@]/g;
    else if( ch == "#" )
    	regex = /[#]/g;
	var start = getPositions( regex, str );
	var end = [];
    for( var i = 0; i < start.length; i++ ){
        // start[i]
		var arr = getPositions(/[,?:;)!\s\n]/g, str.substring( start[i] ) );
		if( arr[ 0 ] == undefined )
    		end.push( str.length - 1 );
		else
        	end.push( start[i] + arr[0] - 1);
    }
    var result = [];
    for( var i = 0; i < start.length; i ++ ){
        var item = [];
        item["start"] = start[i];
        item["end"] = end[i];
        result[ i ] = item;
    }
    return result;
}

function replaceUsername( str ){
    var resultStr = str;
	var result = getStartEndPositions( resultStr, "@" );
    for( var i = 0; i < result.length; i ++ ){
        var strItem = str.substr( result[i]["start"], result[i]["end"] - result[i]["start"] + 1 );
        var strTemp = strItem.substring( 1 );
        resultStr = resultStr.replace( strItem, "<a class='js-link' href='" + strTemp + "'>" + strItem + "</a>" );
    }
    return resultStr;
}

function replaceHashtag( str ){
    var resultStr = str;
	var result = getStartEndPositions( resultStr, "#" );
    for( var i = 0; i < result.length; i ++ ){
        var strItem = str.substr( result[i]["start"], result[i]["end"] - result[i]["start"] + 1 );
        var strTemp = strItem.substring( 1 );
        resultStr = resultStr.replace( strItem, "<a href='search.php?h=" + base64_encode(strTemp) + "'>" + strItem + "</a>" );
    }
    return resultStr;        
}

function validateUsername( username ){
	var re = /[~!@\#$%^&*\()\=+_'\s]/gi;
	if( re.test(username) )
		return true;
	else
		return false;
	
}
function validateEmail(email) { 
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}

function base64_decode(data) {
	  // http://kevin.vanzonneveld.net
	  // +   original by: Tyler Akins (http://rumkin.com)
	  // +   improved by: Thunder.m
	  // +      input by: Aman Gupta
	  // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	  // +   bugfixed by: Onno Marsman
	  // +   bugfixed by: Pellentesque Malesuada
	  // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	  // +      input by: Brett Zamir (http://brett-zamir.me)
	  // +   bugfixed by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	  // *     example 1: base64_decode('S2V2aW4gdmFuIFpvbm5ldmVsZA==');
	  // *     returns 1: 'Kevin van Zonneveld'
	  // mozilla has this native
	  // - but breaks in 2.0.0.12!
	  //if (typeof this.window['atob'] === 'function') {
	  //    return atob(data);
	  //}
	  var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	  var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,
	    ac = 0,
	    dec = "",
	    tmp_arr = [];

	  if (!data) {
	    return data;
	  }

	  data += '';

	  do { // unpack four hexets into three octets using index points in b64
	    h1 = b64.indexOf(data.charAt(i++));
	    h2 = b64.indexOf(data.charAt(i++));
	    h3 = b64.indexOf(data.charAt(i++));
	    h4 = b64.indexOf(data.charAt(i++));

	    bits = h1 << 18 | h2 << 12 | h3 << 6 | h4;

	    o1 = bits >> 16 & 0xff;
	    o2 = bits >> 8 & 0xff;
	    o3 = bits & 0xff;

	    if (h3 == 64) {
	      tmp_arr[ac++] = String.fromCharCode(o1);
	    } else if (h4 == 64) {
	      tmp_arr[ac++] = String.fromCharCode(o1, o2);
	    } else {
	      tmp_arr[ac++] = String.fromCharCode(o1, o2, o3);
	    }
	  } while (i < data.length);

	  dec = tmp_arr.join('');

	  return dec;
}
function base64_encode(data) {
	  // http://kevin.vanzonneveld.net
	  // +   original by: Tyler Akins (http://rumkin.com)
	  // +   improved by: Bayron Guevara
	  // +   improved by: Thunder.m
	  // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	  // +   bugfixed by: Pellentesque Malesuada
	  // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	  // +   improved by: Rafa©© Kukawski (http://kukawski.pl)
	  // *     example 1: base64_encode('Kevin van Zonneveld');
	  // *     returns 1: 'S2V2aW4gdmFuIFpvbm5ldmVsZA=='
	  // mozilla has this native
	  // - but breaks in 2.0.0.12!
	  //if (typeof this.window['btoa'] === 'function') {
	  //    return btoa(data);
	  //}
	  var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	  var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,
	    ac = 0,
	    enc = "",
	    tmp_arr = [];

	  if (!data) {
	    return data;
	  }

	  do { // pack three octets into four hexets
	    o1 = data.charCodeAt(i++);
	    o2 = data.charCodeAt(i++);
	    o3 = data.charCodeAt(i++);

	    bits = o1 << 16 | o2 << 8 | o3;

	    h1 = bits >> 18 & 0x3f;
	    h2 = bits >> 12 & 0x3f;
	    h3 = bits >> 6 & 0x3f;
	    h4 = bits & 0x3f;

	    // use hexets to index into b64, and append result to encoded string
	    tmp_arr[ac++] = b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);
	  } while (i < data.length);

	  enc = tmp_arr.join('');

	  var r = data.length % 3;

	  return (r ? enc.slice(0, r - 3) : enc) + '==='.slice(r || 3);

	}

function sha1(str) {
	  //  discuss at: http://phpjs.org/functions/sha1/
	  // original by: Webtoolkit.info (http://www.webtoolkit.info/)
	  // improved by: Michael White (http://getsprink.com)
	  // improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	  //    input by: Brett Zamir (http://brett-zamir.me)
	  //   example 1: sha1('Kevin van Zonneveld');
	  //   returns 1: '54916d2e62f65b3afa6e192e6a601cdbe5cb5897'

	  var rotate_left = function (n, s) {
	    var t4 = (n << s) | (n >>> (32 - s));
	    return t4;
	  };

	  /*var lsb_hex = function (val) {
	   // Not in use; needed?
	    var str="";
	    var i;
	    var vh;
	    var vl;

	    for ( i=0; i<=6; i+=2 ) {
	      vh = (val>>>(i*4+4))&0x0f;
	      vl = (val>>>(i*4))&0x0f;
	      str += vh.toString(16) + vl.toString(16);
	    }
	    return str;
	  };*/

	  var cvt_hex = function (val) {
	    var str = '';
	    var i;
	    var v;

	    for (i = 7; i >= 0; i--) {
	      v = (val >>> (i * 4)) & 0x0f;
	      str += v.toString(16);
	    }
	    return str;
	  };

	  var blockstart;
	  var i, j;
	  var W = new Array(80);
	  var H0 = 0x67452301;
	  var H1 = 0xEFCDAB89;
	  var H2 = 0x98BADCFE;
	  var H3 = 0x10325476;
	  var H4 = 0xC3D2E1F0;
	  var A, B, C, D, E;
	  var temp;

	  // utf8_encode
	  str = unescape(encodeURIComponent(str));
	  var str_len = str.length;

	  var word_array = [];
	  for (i = 0; i < str_len - 3; i += 4) {
	    j = str.charCodeAt(i) << 24 | str.charCodeAt(i + 1) << 16 | str.charCodeAt(i + 2) << 8 | str.charCodeAt(i + 3);
	    word_array.push(j);
	  }

	  switch (str_len % 4) {
	  case 0:
	    i = 0x080000000;
	    break;
	  case 1:
	    i = str.charCodeAt(str_len - 1) << 24 | 0x0800000;
	    break;
	  case 2:
	    i = str.charCodeAt(str_len - 2) << 24 | str.charCodeAt(str_len - 1) << 16 | 0x08000;
	    break;
	  case 3:
	    i = str.charCodeAt(str_len - 3) << 24 | str.charCodeAt(str_len - 2) << 16 | str.charCodeAt(str_len - 1) <<
	      8 | 0x80;
	    break;
	  }

	  word_array.push(i);

	  while ((word_array.length % 16) != 14) {
	    word_array.push(0);
	  }

	  word_array.push(str_len >>> 29);
	  word_array.push((str_len << 3) & 0x0ffffffff);

	  for (blockstart = 0; blockstart < word_array.length; blockstart += 16) {
	    for (i = 0; i < 16; i++) {
	      W[i] = word_array[blockstart + i];
	    }
	    for (i = 16; i <= 79; i++) {
	      W[i] = rotate_left(W[i - 3] ^ W[i - 8] ^ W[i - 14] ^ W[i - 16], 1);
	    }

	    A = H0;
	    B = H1;
	    C = H2;
	    D = H3;
	    E = H4;

	    for (i = 0; i <= 19; i++) {
	      temp = (rotate_left(A, 5) + ((B & C) | (~B & D)) + E + W[i] + 0x5A827999) & 0x0ffffffff;
	      E = D;
	      D = C;
	      C = rotate_left(B, 30);
	      B = A;
	      A = temp;
	    }

	    for (i = 20; i <= 39; i++) {
	      temp = (rotate_left(A, 5) + (B ^ C ^ D) + E + W[i] + 0x6ED9EBA1) & 0x0ffffffff;
	      E = D;
	      D = C;
	      C = rotate_left(B, 30);
	      B = A;
	      A = temp;
	    }

	    for (i = 40; i <= 59; i++) {
	      temp = (rotate_left(A, 5) + ((B & C) | (B & D) | (C & D)) + E + W[i] + 0x8F1BBCDC) & 0x0ffffffff;
	      E = D;
	      D = C;
	      C = rotate_left(B, 30);
	      B = A;
	      A = temp;
	    }

	    for (i = 60; i <= 79; i++) {
	      temp = (rotate_left(A, 5) + (B ^ C ^ D) + E + W[i] + 0xCA62C1D6) & 0x0ffffffff;
	      E = D;
	      D = C;
	      C = rotate_left(B, 30);
	      B = A;
	      A = temp;
	    }

	    H0 = (H0 + A) & 0x0ffffffff;
	    H1 = (H1 + B) & 0x0ffffffff;
	    H2 = (H2 + C) & 0x0ffffffff;
	    H3 = (H3 + D) & 0x0ffffffff;
	    H4 = (H4 + E) & 0x0ffffffff;
	  }

	  temp = cvt_hex(H0) + cvt_hex(H1) + cvt_hex(H2) + cvt_hex(H3) + cvt_hex(H4);
	  return temp.toLowerCase();
	}
function getMicrotime(get_as_float){
	var now = new Date().getTime() / 1000;
	var s = parseInt(now, 10);
	return (get_as_float) ? now : (Math.round((now - s) * 1000) / 1000) + ' ' + s;
}
function getHash( time, key ){
	var hash = sha1( base64_encode( time + "-" + key) );
	return hash;
	
}
function validateYouTube(url) {
	  var p = /^(?:https?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))((\w|-){11})(?:\S+)?$/;
	  return (url.match(p)) ? true : false;
}
function validateVimeo( url ){
	var regExp = /http|https:\/\/(www\.)?vimeo.com\/(\d+)($|\/)/;
	var match = url.match(regExp);
	if( match )
		return true;
	else
		return false;
}
function validateKickStarter( url ){
	var ind = url.indexOf( "kickstarter.com" );
	if( ind == -1)
		return false;
	else
		return true;
}
function validateFunnyOrDie( url ){
	var ind = url.indexOf( "funnyordie.com" );
	if( ind == -1)
		return false;
	else
		return true;
}
function validateTed( url ){
	var ind = url.indexOf( "ted.com" );
	if( ind == -1)
		return false;
	else
		return true;
}
function validateIndieGogo( url ){
	var ind = url.indexOf( "indiegogo.com" );
	if( ind == -1)
		return false;
	else
		return true;	
}
function validateFacebook( url ){
	var ind = url.indexOf( "facebook.com" );
	if( ind == -1)
		return false;
	else
		return true;	
}
function validateCollegeHumor( url ){
	var ind = url.indexOf( "collegehumor.com" );
	if( ind == -1)
		return false;
	else
		return true;
}
function hasWhiteSpace(s) {
	  return s.indexOf(' ') >= 0;
}

function removeHtmlStorage(name) {
    localStorage.removeItem(name);
    localStorage.removeItem(name+'_time');
}

function setHtmlStorage(name, value, expires) {

    if (expires==undefined || expires=='null') { var expires = 3600 * 24; } // default: 1 day

    var date = new Date();
    var schedule = Math.round((date.setSeconds(date.getSeconds()+expires))/1000);

    localStorage.setItem(name, value);
    localStorage.setItem(name+'_time', schedule);
}

function statusHtmlStorage(name) {

    var date = new Date();
    var current = Math.round(+date/1000);
    
    // Get Schedule
    var stored_time = localStorage.getItem(name+'_time');
    if (stored_time==undefined || stored_time=='null') { var stored_time = 0; }

    // Expired
    if (stored_time < current) {
        // Remove
        removeHtmlStorage(name);
        return 0;
    } else {
        return 1;
    }
}