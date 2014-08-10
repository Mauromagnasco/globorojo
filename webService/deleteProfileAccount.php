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

    $userId = mysql_escape_string($_POST['userId']);
    
    $sql = "delete from rb_user where rb_user = $userId";
    $db->query( $sql );
    
    $sql = "delete from rb_user_sns where rb_user = $userId";
    $db->query( $sql );
    
    $sql = "delete from rb_friend where rb_following = $userId";
    $db->query( $sql );
    
    $sql = "delete from rb_friend where rb_follower = $userId";
    $db->query( $sql );
    
    $sql = "delete from rb_notification where rb_user = $userId";
    $db->query( $sql );

    $sql = "delete from rb_notification where rb_sender = $userId";
    $db->query( $sql );    

    $sql = "delete from rb_user_video_comment where rb_user = $userId";
    $db->query( $sql );    
    
    $sql = "delete from rb_user_video_score where rb_user = $userId";
    $db->query( $sql );    
    
    $sql = "delete from rb_video_share_count where rb_video in ( select rb_video from rb_video where rb_user = $userId)";
    $db->query( $sql );

    $sql = "delete from rb_video_view_count where rb_video in ( select rb_video from rb_video where rb_user = $userId)";
    $db->query( $sql );    
    
    $sql = "delete from rb_video where rb_user = $userId";
    $db->query( $sql );   
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>