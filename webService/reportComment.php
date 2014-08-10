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

    $commentId = mysql_escape_string($_POST['commentId']);
    $userId = mysql_escape_string($_POST['userId']);
    
    $sql = "select * from rb_user_video_comment where rb_user_video_comment = $commentId";
    $dataComment = $db->queryArray( $sql );
    $videoId = $dataComment[0]['rb_video'];

    $sql = "select * from rb_user where rb_user = $userId";
    $dataUser = $db->queryArray( $sql );
    $username = $dataUser[0]['rb_username'];
    
    $subject = "Inappropriate Comment";
    $message = "This Comment is inappropriate.\n\r";
    $message.= "This is Report from $username.\n\r";
    $message.= "http://".HOST_SERVER."/video.php?id=".base64_encode( $videoId );
    	
    RB_sendEmail( CONTACT_EMAIL, $message, $subject );

    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
