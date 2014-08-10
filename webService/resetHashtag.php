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
	require_once("../common/DB_Connection.php");	
    require_once("../common/functions.php");
    require_once("../common/checkAuth.php");

    $result = "success";
    $error = "";
    $data = array();
    
    $videoId = mysql_escape_string( $_POST['videoId'] );
    $hashtag = mysql_escape_string( $_POST['hashtag'] );

    $sql = "update rb_video
    		   set rb_hashtag = '$hashtag'
    			 , rb_video_score = 0
    			 , rb_created_time = now()
    			 , rb_updated_time = now()
    		 where rb_video = $videoId";
    $db->query( $sql );
    
	$sql = "delete from rb_user_video_score where rb_video = $videoId";
	$db->query( $sql );    
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>