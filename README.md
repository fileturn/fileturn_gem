# Fileturn

Ruby Gem Support for [FileTurn](https://fileturn.net/) Api. FileTurn converts your files to different formats. 

## Installation

Add this line to your application's Gemfile:

    gem 'fileturn'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fileturn

## Configuration

Retrieve your API Token from [Dashboard](https://fileturn.net/dashboard/api_token).

	FileTurn.configure(:api_token => "[YOUR KEY]")
	
Thats it - now you are ready to use FileTurn.

## Usage

### Converting your files

There are multiple ways to convert a file. If your file is public, we can fetch the file and you just need to specify the url. 

	conversion = FileTurn::Conversion.process!(
		:url => "http://crypto.stanford.edu/DRM2002/darknet5.doc",
		:type => "WordToPdf"
	)

If your file is stored locally, you can use

	file = FileTurn::Conversion.process!(
		:file => File.open("localfile.doc"),
		:type => "WordToPdf"
	)

Thats all you have to do to convert files. Upon calling that, your file will be queued for converting. 

### How will i know when my conversion is done?

#### Conversion Object

There are few ways to check if your file is done. You can repeatedly call one of these:

	conversion.reload!.completed? 
	conversion.reload!.failed?
	conversion.reload!.processing?
	conversion.reload!.created?

When your conversion is done, the conversion object will have temporary download urls.

	if conversion.completed?
		download_url = conversion.temporary_download_urls
		time_taken_for_conversion = conversion.processing_time_in_seconds
	end

In the case you get a failure, you can retrieve the details using

	conversion.error_type
	conversion.error_details

#### Notifications

You can also request notification to be sent to you whenever the status of a conversion changes via webhooks. Go into your [Dashboard](https://fileturn.net/dashboard/notifications) and specify a webhook url. 

## Other Conversion Options

You can fetch information of a single conversion using an id.

	FileTurn::Conversion.find(id)

Or all the conversions
	
	FileTurn::Conversion.all

## Account Details

You can fetch account details 

	account = FileTurn::Account.load # fetch data from server

	# plan details
	account.plan.name
	account.plan.max_file_size_in_mb
	account.plan.conversions_per_month
	account.plan.max_requests_per_second

	# stats for account (for current billing cycle)
	account.subscription.stats.conversions_left
	account.subscription.stats.successful_conversions
	account.subscription.stats.failed_conversions
	account.subscription.stats.processing_conversions

