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
    
    $videoId = mysql_escape_string($_POST['videoId']);
    $email = mysql_escape_string($_POST['email']);
    $userId = mysql_escape_string($_POST['userId']);
    
    $sql = "select * from rb_user where rb_user = $userId";
    $dataUser = $db->queryArray( $sql );
    $username = $dataUser[0]['rb_username'];
    
    $sql = "select * from rb_video where rb_video = $videoId";
    $dataVideo = $db->queryArray( $sql );
    $videoTitle = $dataVideo[0]['rb_content'];
    $videoHashtag = $dataVideo[0]['rb_hashtag'];
    
    $subject = "@$username wants to share $videoTitle with you.";
    $message= "$videoTitle via @$username #$videoHashtag http://".HOST_SERVER."/video.php?id=".base64_encode( $videoId );
    // $message.= "Via http://www.balloonred.com";
    
    RB_sendEmail( $email, $message, $subject );
    
    $sql = "update rb_video_share_count set rb_count = rb_count + 1 where rb_video = $videoId";
    $db->query( $sql );
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
