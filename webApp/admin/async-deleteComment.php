<?php
/**
 * Globo Rojo open source application
 *
 *  Copyright � 2013, 2014 by Mauro Magnasco <mauro.magnasco@gmail.com>
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
    
    $commentIds = $_POST['commentIds'];
    $sql = "delete from rb_user_video_comment where rb_user_video_comment in ( $commentIds )";
    $db->query( $sql );
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);
?>