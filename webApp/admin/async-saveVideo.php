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
	session_start();
	require_once("../common/DB_Connection.php");	
    require_once("../common/functions.php");

    $result = "success";
    $error = "";
    $data = array();
       
	$videoId = $_POST['videoId'];
	$videoUrl = $_POST['videoUrl'];
	$content = $_POST['content'];
	$hashtag = $_POST['hashtag'];
	$score = $_POST['score'];

    $sql = "update rb_video
    		   set rb_video_url = '$videoUrl'
    		   	 , rb_content = '$content'
    		   	 , rb_hashtag = '$hashtag'
    		   	 , rb_video_score = '$score'
    			 , rb_updated_time = now() 
    		 where rb_video = $videoId";
    $db->query( $sql );
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
