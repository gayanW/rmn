package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextInteractionMode;
			
	/**
	 * ...
	 * @author Gayan
	 */
	
	[SWF(width = "150", height = "50", frameRate = "10")]
	
	public class Main extends Sprite
	{
		private var xmlData:XML;
		private var loader:URLLoader;
		
		private var status:TextField;
		
		// required xml data (coupon data)
		private var code:String = new String();
		private var site:String = new String();
		private var description:String = new String();
		private var startDate:String = new String("2015-01-01 23:59:59");
		private var expires:String = new String();
		
		private var str:String = new String();
		
		// output file
		private var outputFile:File;
		private var fileStream:FileStream;
		
		// CONSTANTS
		private static const MAX_FILE_SIZE:uint = 310 * 128; /* 1 Kilobit = 128 Byte */ 
		
		private var fileIndex:uint = 0;
		private var counter:uint = 0;
		
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			// show the program status on the stage
			status = new TextField();
			status.width = stage.stageWidth;
			status.height = stage.stageHeight;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.align = TextFormatAlign.JUSTIFY;
			textFormat.color = 0xFFFFFF;
			textFormat.size = 20;
			
			addChild(status);
			
			// create output (csv) file
			initOutputFile();
			
			// make a url request
			var url:String = "http://webservices.icodes-us.com"
			url += "/ws2_us.php?UserName=isiblean&SubscriptionID=876f1f9954de0aa402d91bb988d12cd4"
			url += "&RequestType=Codes&Action=Full&Relationship=All"
			
			var urlRequest:URLRequest = new URLRequest(url);
			
			loader = new URLLoader();
						
			loader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
			loader.load(urlRequest);
			
			// update status
			status.text = "DOWNLOADING XML DATA";
		}
		
		private function onUrlLoaderComplete(e:Event):void 
		{
			loader.removeEventListener(Event.COMPLETE, onUrlLoaderComplete);
			
			// update status
			status.text = "DOWNLOAD COMPLETE";
			
			// construct a xml data file using the loader data
			xmlData = new XML(loader.data);
			
			// start parsing the xml data
			parseXML();
				
		}
		
		private function parseXML():void 
		{
			var items:XMLList = xmlData.item;
						
			// loop through all the items
			for each(var item:XML in items)
			{
				description = item.description;
				code = item.voucher_code;
				startDate = item.start_date;
				expires = item.expiry_date;
				site = item.merchant_url;
				
				// tranquate start and expiry date
				startDate = startDate.substr(0, 10);
				startDate = startDate.split("-").join("/");
				expires = expires.substr(0, 10);
				expires = expires.split("-").join("/");
				
				// tranquate site url
				var regExp:RegExp = new RegExp("https*:\/\/(www\.)*", "ig");
				site = site.replace(regExp, "");
				site = site.replace("\/", "");
				
				str = code + "," + site + ',"' + description + '",'+ startDate + "," + expires + "\n";
				
				// write coupon data into the file
				fileStream.writeUTFBytes(str);
				
				//if (++counter % COUPONS_PER_FILE == 0)
					//createNewOutputFile();
					
				if (outputFile.size > MAX_FILE_SIZE)
					createNewOutputFile();
			}
			
			fileStream.close();
			
			// update status
			status.text = "PARSING COMPLETE (" + items.length() + ")";
			
		}
		
		private function initOutputFile():void
		{
			// create a reference a file
			outputFile = File.desktopDirectory.resolvePath("output_" + fileIndex.toString() + ".csv");
			
			// create a file stream to write to the file
			fileStream = new FileStream();
			fileStream.open(outputFile, FileMode.WRITE);
			
			// write the header data
			fileStream.writeUTFBytes("Code,Site,Description,StartDate,Expires\n");
			
			++fileIndex;
		}
		
		private function createNewOutputFile():void
		{
			// closes the current file 
			// and releases any resources associated with the current file stream
			fileStream.close();
						
			// change the outputFile reference to a new file
			outputFile = File.desktopDirectory.resolvePath("output_" + fileIndex.toString() + ".csv");
			
			// update file stream
			fileStream.open(outputFile, FileMode.WRITE);
			
			// write the header data
			fileStream.writeUTFBytes("Code,Site,Description,StartDate,Expires\n");
			
			++fileIndex;
		}
		
	}
	
}