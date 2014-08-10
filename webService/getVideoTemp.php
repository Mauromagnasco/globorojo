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
    
    $vid = mysql_escape_string( $_POST['vid'] );

    $sql = "select * from rb_video_temp where rb_video_temp = $vid";
    $dataResult = $db->queryArray( $sql );
    $dataResult = $dataResult[0];
    
    
    $data['rb_facebook'] = $dataResult['rb_facebook'];
    $data['rb_twitter'] = $dataResult['rb_twitter'];
    $data['rb_url'] = $dataResult['rb_url'];
    $data['rb_description'] = $dataResult['rb_description'];
    $data['rb_hashtag'] = $dataResult['rb_hashtag'];
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
