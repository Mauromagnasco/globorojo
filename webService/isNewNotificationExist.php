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
    	
    $sql = "select count(*) cnt from rb_notification where rb_user = $userId and rb_read_yn = 'N'";
    $cntNewNotification = $db->queryArray( $sql );
    $cntNewNotification = $cntNewNotification[0]['cnt'];
    if( $cntNewNotification == 0 ){
    	$isNewNotification = "N";
    }else{
    	$isNewNotification = "Y";
    }
    $data['isNewNotification'] = $isNewNotification;
    	 
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
