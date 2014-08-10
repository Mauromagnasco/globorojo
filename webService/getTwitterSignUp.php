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
    
    $snsId = mysql_escape_string( $_POST['sns'] );

    $sql = "select * from rb_user_sns where rb_user_sns = $id";
    $dataUserSns = $db->queryArray( $sql );
    $dataUserSns = $dataUserSns[0];    
    
    $data['rb_nickname'] = $dataUserSns['rb_nickname'];
    $data['rb_email'] = $dataUserSns['rb_email'];
    $data['rb_photo'] = $dataUserSns['rb_photo'];
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
