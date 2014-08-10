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

$result = "success";
$error = "";
$data = array();

$imageData = mysql_escape_string($_POST['imageData']);
$imageType = mysql_escape_string($_POST['imageType']);
$imageData = str_replace( " ", "", $imageData);

$path = "img/profile/";
if( $imageType == "png" )
	$filename = RB_generateRandom(16)."_".time().".png";
else
	$filename = RB_generateRandom(16)."_".time().".jpg";

file_put_contents('../'.$path.$filename, base64_decode($imageData));

$data['photo'] = RB_photoURL($path.$filename);
$data['result'] = $result;
$data['error'] = $error;
header('Content-Type: application/json');
echo json_encode($data);

?>