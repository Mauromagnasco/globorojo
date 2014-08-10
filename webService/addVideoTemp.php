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
    
    $videoUrl = mysql_escape_string( $_POST['videoUrl'] );
    $description = mysql_escape_string( $_POST['description'] );
    $hashtag = mysql_escape_string( $_POST['hashtag'] );
    $isCheckedFB = mysql_escape_string( $_POST['isCheckedFB'] );
    $isCheckedTW = mysql_escape_string( $_POST['isCheckedTW'] );

    $sql = "insert into rb_video_temp( rb_url, rb_description, rb_hashtag, rb_facebook, rb_twitter, rb_created_time, rb_updated_time )
    		value( '$videoUrl', '".addslashes($description)."', '$hashtag', '$isCheckedFB', '$isCheckedTW', now(), now())";
    $db->queryInsert( $sql );
    $videoId = $db->getPrevInsertId();
    
    $data['videoTempId'] = $videoId;
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
