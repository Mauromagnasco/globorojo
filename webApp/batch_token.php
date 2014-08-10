<?php
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
	require_once("./common/DB_Connection.php");	
    require_once("./common/functions.php");

    $sql = "select * from rb_user_sns where rb_sns_type = 1";
    $list = $db->queryArray( $sql );
    for( $i = 0 ; $i < count( $list ); $i ++ ){
    	$oldToken = $list[$i]['rb_token'];
    	$url = "https://graph.facebook.com/oauth/access_token?client_id=".FACEBOOK_APP_ID."&client_secret=".FACEBOOK_APP_SECRET."&grant_type=fb_exchange_token&fb_exchange_token=$oldToken";
    	$result = file_get_contents($url);
    	parse_str( $result, $get_array);
    	$newToken = $get_array["access_token"];
    	$sql = "update rb_user_sns
    			   set rb_token = '$newToken'
    			 where rb_user = ".$list[$i]['rb_user'];
    	$db->query( $sql );
    	
    }
    
?>
