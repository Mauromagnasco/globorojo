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
<!--[if IE 8]> <html lang="en" class="ie8"> <![endif]-->  
<!--[if IE 9]> <html lang="en" class="ie9"> <![endif]-->  
<!--[if !IE]><!--> <html lang="en"> <!--<![endif]-->  
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
		$pageNo = 2;
	?>
	<link rel="stylesheet" type="text/css" href="http://www.datatables.net/media/blog/bootstrap_2/DT_bootstrap.css">
	
	<script type="text/javascript" src="js/jquery.dataTables.js"></script>
	<script type="text/javascript" src="js/DT_bootstrap.js"></script>
	<script type="text/javascript" src="js/videoList.js"></script>		
</head>

<body>

<?php require_once("top.php"); ?>

<div class="container" style="min-height: 530px;">     
    <div class="row">
		<?php require_once("leftMenu.php"); ?>
        <div class="col-md-9">
			<div class="panel panel-sea margin-bottom-40">
				<div class="panel-heading">
					<h3 class="panel-title floatleft" style="line-height:30px;"><i class="icon-user"></i> Video List</h3>
					<button class="floatright btn-u btn-u-red" onclick="onDeleteVideo()" style="width: 90px;"><i class="icon-trash"></i> Delete</button>
					<!-- button class="floatright btn-u btn-u-blue" onclick="onAddVideo()" style="margin-right:10px;width: 90px;"><i class="icon-plus"></i> Add</button -->
					<div class="clearboth"></div>
				</div>
				<?php
					$sql = "select t1.*, t2.rb_username
							  from rb_video t1, rb_user t2
							 where t1.rb_user = t2.rb_user";
					$dataVideo = $db->queryArray( $sql ); 
				?>
				<table class="table table-striped" id="example">
					<thead>
						<tr>
							<th style="width:60px;"><input type="checkbox" id="checkAll" onclick="onCheckAll( this )"/></th>
							<th style="width:60px;">No</th>
							<th style="width:300px;">Title</th>
							<th>Type</th>
							<th>Hashtag</th>
							<th>Username</th>
							<th>Score</th>
							<th>Created Time</th>
						</tr>
					</thead>
					<tbody>
						<?php for($i = 0 ; $i < count( $dataVideo); $i ++ ){
							$videoType = $dataVideo[$i]['rb_video_type'];
							if( $videoType == "Y" ){
								$videoType = "YouTube";
							}else if( $videoType == "V" ){
								$videoType = "YouTube";
							}else if( $videoType == "K" ){
								$videoType = "KickStarter";
							}
						?>
						<tr>
							<td><input type="checkbox" id="chkVideoId" value="<?php echo $dataVideo[$i]['rb_video']; ?>"/></td>
							<td><?php echo $i + 1; ?></td>
							<td><a href="videoDetail.php?id=<?php echo $dataVideo[$i]['rb_video']; ?>"/><?php echo $dataVideo[$i]['rb_content']; ?></a></td>
							<td><a href="videoDetail.php?id=<?php echo $dataVideo[$i]['rb_video']; ?>"/><?php echo $videoType; ?></a></td>
							<td><a href="videoDetail.php?id=<?php echo $dataVideo[$i]['rb_video']; ?>"/><?php echo "#".$dataVideo[$i]['rb_hashtag']; ?></a></td>
							<td><a href="videoDetail.php?id=<?php echo $dataVideo[$i]['rb_video']; ?>"/><?php echo "@".$dataVideo[$i]['rb_username']; ?></a></td>
							<td><a href="videoDetail.php?id=<?php echo $dataVideo[$i]['rb_video']; ?>"/><?php echo $dataVideo[$i]['rb_video_score']; ?></a></td>
							<td><a href="videoDetail.php?id=<?php echo $dataVideo[$i]['rb_video']; ?>"/><?php echo $dataVideo[$i]['rb_created_time']; ?></a></td>
						</tr>
						<?php } ?>
					</tbody>
				</table>
			</div>        			       
        </div>
    </div>          
</div>     
<?php require_once("footer.php"); ?>
</body>
</html> 