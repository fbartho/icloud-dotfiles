var fs = require("fs");
var path = require("path");
var async = require("async");

var VERBOSE = true;

// The purpose of this script was to migrate all the iTunes Apps off of my main machine on to an external drive
// It then install symlinks back, so iTunes still sees the files.

var truePath = "/Users/fbarthelemy/Music/iTunes/iTunes Media/Mobile Applications";
var storagePath = "/Volumes/Pacific Sunset/iTunes/iTunes Media/Mobile Applications";

var verbose = function(){};
if (VERBOSE) {
	verbose = console.log;
}

verbose("Prerequisites");

var tStats = fs.lstatSync(truePath);
if (tStats.isSymbolicLink()) {
	console.error("iTunes Mobile Applications Folder cannot be a symlink, this is why you're using this!");
	return;
}
verbose("\t* Good, Target directory is not a symlink…");

if (!fs.existsSync(storagePath)) {
	console.error("Expected external drive to be connected");
	return;
}
verbose("\t* Good, Storage directory is connected…");

var processed = 0;
var filesMoved = 0;
var symlinksCreated = 0;

// Move the files
function moveNewFiles(completion) {
	fs.readdir(truePath, function(error, files) {
		verbose("\nRead all the items in iTunes",(files||[]).length);
		if (error) {
			completion(error);
			return;
		}
		async.each(
			files,
			function(file, next) {
				var tPath = path.join(truePath, file);
				var sPath = path.join(storagePath, file);
				fs.lstat(
					tPath,
					function(error, tstat) {
						if (error || tstat.isSymbolicLink()) {
							// File is missing, or it's a symlink, nothing needed to be done!
							next();
							return;
						}
						fs.lstat(
							sPath,
							function(error, sstat) {
								processed++;
								filesMoved++;
								if (!error || sstat) {
									// Delete a (duplicated) original from the storage location
									verbose("\t ** Original in iTunes Directory, already in storage. Removing from storage.",file);
									fs.unlinkSync(sPath);
									processed++;
								}
								// Move the "original" file to the storage location
								verbose("\tMoving file from iTunes to Storage",file);
								copyFile(tPath, sPath, function(error) {
									if (error) {
										next(error);
										return;
									}
									verbose("\t\tFile Copied: ",file);
									fs.unlinkSync(tPath);
									next();
								});
							}
						);
					}
				);
			},
			completion
		)
	});
}
// Link the files
function linkBack(completion) {
	fs.readdir(storagePath, function(error, files) {
		verbose("\nRead all the files from storage:",(files||[]).length);
		if (error) {
			completion(error);
			return;
		}
		async.each(
			files,
			function(file, next) {
				processed++;
				var tPath = path.join(truePath, file);
				var sPath = path.join(storagePath, file);
				fs.lstat(
					tPath,
					function(error, tStat) {
						if (!error && tStat.isSymbolicLink()) {
							// No link needed, already is symbolic
							next();
							return;
						}
						
						symlinksCreated++;
						
						// Create a symbolic link
						verbose("\tLinking:",sPath,tPath);
						fs.symlink(sPath,tPath,next);
					}
				);
			},
			completion
		);
	});
}

function copyFile(source, target, cb) {
  var cbCalled = false;

  var rd = fs.createReadStream(source);
  rd.on("error", function(err) {
    done(err);
  });
  var wr = fs.createWriteStream(target);
  wr.on("error", function(err) {
    done(err);
  });
  wr.on("close", function(ex) {
    done();
  });
  rd.pipe(wr);

  function done(err) {
    if (!cbCalled) {
      cb(err);
      cbCalled = true;
    }
  }
}

verbose("\nStarting process…");
moveNewFiles(function(error){
	if (error) {
		console.error(error);
		return;
	}
	linkBack(function(error) {
		if (error) {
			console.error(error);
			return;
		}
		console.log("All files processed! \n\tProcessed:",processed,"\n\tMoved:",filesMoved,"\n\tLinks Created:",symlinksCreated);
	});
});