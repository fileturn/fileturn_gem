# Fileturn

Ruby Gem Support for [FileTurn](http://fileturn.net/) Api. FileTurn converts your files to different formats. 

## Installation

Add this line to your application's Gemfile:

    gem 'fileturn'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fileturn

## Configuration

Retrieve your API Key from [Dashboard](http://fileturn.net/dashboard/api_token).

	FileTurn.configure(:api_key => "[YOUR KEY]")
	
Thats it - now you are ready to use FileTurn.

## Usage

### Converting your files

There are multiple ways to convert a file. If your file is public, we can fetch the file and you just need to specify the url. 

	file = FileTurn::File.convert(
		:url => "http://crypto.stanford.edu/DRM2002/darknet5.doc",
		:convert_to => :pdf
	)
	
	unless file.errors
		# Woot done!
	end

If your file is stored locally, you can use

	file = FileTurn::File.convert(
		:file => File.open("localfile.doc"),
		:convert_to => :txt
	)

Thats all you have to do to convert files. Upon calling that, your file will be queued for converting. 

### How will i know when my file is done?

#### File Object

There are few ways to check if your file is done. You can repeatedly call one of these:

	file.reload.queued? 
	file.reload.success?
	file.reload.failed?

When your file is done, the file object will store a download link

	while(file.reload.queued?)
		sleep(5000)
	end
	
	if file.success?
		download_url = file.download_url
		time_taken_for_conversion = file.time_taken
	end

In the case you get a failure, you can retrieve the details using

	if(file.reload.failed?)
		file.notifications.last.details
	end

#### Notifications

You can also request notification to be sent to you whenver the status of a file changes. Go into your [Dashboard](http://fileturn.net/dashboard/notifications) and specify a notification url. 

We will hit this notification url with the new status of the file and the file_id. 

**Note: We will try queing your file twice in case of a a failure (ex/ we couldnt reach the url). You will recieve two notifications in that case. The first could be failed and second success.**

## Other File Options

You can fetch information of a single file using the file_id.

	FileTurn::File.find(file_id)

Or all the files
	
	FileTurn::File.all


## Account Details

You can also fetch account details like how much credit you have. 

	FileTurn::Account.load # fetch data from server
	FileTurn::Account.credits

Or you can use

	FileTurn::Account.load.credits

Thanks!