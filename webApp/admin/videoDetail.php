<!-- 
 * Globo Rojo open source application
 *
 *  Copyright © 2013, 2014 by Mauro Magnasco <mauro.magnasco@gmail.com>
 *
 *  Licensed under GNU General Public License 2.0 or later.
 *  Some rights reserved. See COPYING, AUTHORS.
 *
 * @license GPL-2.0+ <http://spdx.org/licenses/GPL-2.0+>
 -->
<?php session_start(); ?>
<!DOCTYPE html>
<!--[if IE 8]><html lang="en" id="ie8" class="lt-ie9 lt-ie10"> <![endif]-->
<!--[if IE 9]><html lang="en" id="ie9" class="gt-ie8 lt-ie10"> <![endif]-->
<!--[if gt IE 9]><!-->
<html lang="en"> <!--<![endif]-->
<head>
    <title>Red Balloon</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
       
	<?php 
		require("asset.php");
		require("../common/config.php");
		require("../common/DB_Connection.php");		
		require("../common/functions.php");
    	if( isset($_GET['id']) && $_GET['id'] != "" ){
			$videoId = $_GET['id'];
			$sql = "select t1.*, t2.rb_username from rb_video t1, rb_user t2 where t1.rb_video = $videoId and t1.rb_user = t2.rb_user";
			$dataVideo = $db->queryArray( $sql );
			$dataVideo = $dataVideo[0];
			$type = "Edit";
		}else{
			$type = "Add";
		}    	
    	$pageNo = 2; 
	?>
	<link rel="stylesheet" type="text/css" href="http://www.datatables.net/media/blog/bootstrap_2/DT_bootstrap.css">
	
	<script type="text/javascript" src="js/jquery.dataTables.js"></script>
	<script type="text/javascript" src="js/DT_bootstrap.js"></script>
	<script type="text/javascript" src="js/videoDetail.js"></script>		
</head>
<body>
<?php require_once("top.php"); ?>
<div class="container" style="min-height: 530px;">     
    <div class="row">
	    <?php require_once("leftMenu.php"); ?>
	   	 <div class="col-md-9">
			<div class="panel panel-green margin-bottom-40">
                <div class="panel-heading">
                    <h3 class="panel-title"><i class="icon-user"></i> Video <?php echo $type;?></h3>
                </div>
                <div class="panel-body">
                	<div class="form-horizontal">
                		<input type="hidden" id="type" value="<?php echo $type;?>"/>
                		<input type="hidden" id="videoId" value="<?php echo $videoId?>"/>
                		
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Username</label>
                            <div class="col-lg-10">
                                <input type="text" value="<?php echo $dataVideo['rb_username']?>" class="form-control" id="username" placeholder="Username" readonly style="background:#FEFEFE; cursor: pointer;">
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Video URL</label>
                            <div class="col-lg-10">
                                <input type="text" value="<?php echo $dataVideo['rb_video_url']?>" class="form-control" id="videoUrl">
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Content</label>
                            <div class="col-lg-10">
                                <input type="text" value="<?php echo $dataVideo['rb_content']?>" class="form-control" id="content">
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Hashtag</label>
                            <div class="col-lg-10">
                                <input type="text" value="<?php echo $dataVideo['rb_hashtag']?>" class="form-control" id="hashtag">
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Score</label>
                            <div class="col-lg-10">
                                <input type="text" value="<?php echo $dataVideo['rb_video_score']?>" class="form-control" id="score">
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Type</label>
                            <div class="col-lg-10">
                            	<?php
                            	$videoType = $dataVideo['rb_video_type'];
                            	if( $videoType == "Y" ){
									$videoType = "YouTube";
								}else if( $videoType == "V" ){
									$videoType = "Vimeo";
								}else if( $videoType == "K" ){	
									$videoType = "KickStarter";
								}
                            	?>
                                <input type="text" value="<?php echo $videoType?>" class="form-control" readonly style="background:#FEFEFE; cursor: pointer;">
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Created Time</label>
                            <div class="col-lg-10">
                                <input type="text" value="<?php echo $dataVideo['rb_created_time']?>" class="form-control" readonly style="background:#FEFEFE; cursor: pointer;" >
                            </div>
                        </div>
                                                
                        <div class="form-group">
                            <div class="col-lg-offset-2 col-lg-10" style="text-align:center;">
                                <button class="btn-u btn-u-green" style="margin-right: 20px;width:90px;" onclick="onVideoSave()"><i class="icon-edit"></i> Save</button>
                                <button class="btn-u btn-u-red" style="width:90px;" onclick="window.location.href='videoList.php'"><i class="icon-list"></i> List</button>
                            </div>
                        </div>                                                                        
					</div>
				</div>
			</div>
		</div>
    </div>
</div>
</body>
</html>