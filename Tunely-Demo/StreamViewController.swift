//
//  StreamViewController.swift
//  Tunely-Demo
//
//  Created by Cole Stipe on 11/3/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit
import PubNub

var playlistTrackname = [String]()
var playlistArtistname = [String]()
var player:SPTAudioStreamingController?

class StreamViewController: UIViewController,SPTAudioStreamingPlaybackDelegate, UITableViewDataSource, UITableViewDelegate, PNObjectEventListener {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var listenersView: UICollectionView!
    
    // playlist of song objects
    var userPlaylistTrackStrings = [Song]()
    
    var listenersPic : [String] = []
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var streamName : String!
    
    @IBOutlet weak var SearchButton: UIButton!
    
    @IBAction func searchSongs(sender: AnyObject) {
        let searchSongView:SongSearchViewController = SongSearchViewController(nibName: "SongSearchViewController", bundle: nil)
        self.presentViewController(searchSongView, animated: true, completion: nil)
    }    
    
    let kClientID = "4d63faabbbed404384264f330f8610b7";
    let kCallBackURL = "SpotifyTesting://callback"
    
    //var player:SPTAudioStreamingController?
    
    
    var isPlaying = false;
    var TrackListPosition = 0;
    var firstPlay = true;
    var pausePressed = false;
    var skipSongs = false;
    
    var serializedPlaylist: [AnyObject] = []
    
    //array of songs returned by spotify search request
    var songs: [Song] = []
    
    
    @IBOutlet weak var PlayPause: UIBarButtonItem!
    //@IBOutlet weak var Next: UIButton!
    
    @IBOutlet weak var Back: UIBarButtonItem!
    @IBOutlet weak var Next: UIBarButtonItem!
    
    
    @IBAction func PlayPause(sender: AnyObject) {
        pausePressed = true
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            player?.playbackDelegate = self;
            print("no player")
        }
        if(firstPlay == true)
        {
            print("first play")
            updateSession()
            playUsingSession(session)
            //player?.playURI(userPlaylistTrackStrings[0], callback: nil)
            let tmpString = userPlaylistTrackStrings[0].trackID 
            let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
            player?.playURI(formattedTrackName, callback: nil)
            //isPlaying = true;
            firstPlay = false
        }
        else {
            player?.setIsPlaying(isPlaying, callback: nil)

            if(isPlaying == false){
                isPlaying = true;
                print("music paused")
            }
            else
            {
                print("music played")
                isPlaying = false;
            }
        }
        pausePressed = false
        //playUsingSession(session)
        
        //self.player?.setIsPlaying(isPlaying, callback: nil)
        /*
        Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=loveland&type=track")
        .responseJSON { response in
        debugPrint(response)*/
        /*
        Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=loveland&type=track").response { request, response, data, error in
        
        let json = JSON(data: data!)
        
        print(json["tracks"]["items"].count);
        //print(json["tracks"]["items"])
        
        for var i = 0; i < json["tracks"]["items"].count; i++ {
        
        let data = json["tracks"]["items"][i]
        
        // return the object list
        let song = Song()
        
        song.title = data["name"].string!
        song.album = data["album"]["name"].string!
        song.artist = data["artists"][0]["name"].string!
        song.trackID = data["id"].string!
        
        print(song.title)
        print(song.artist)
        print(song.trackID)
        
        self.songs += [song]
        
        }
        }*/
        
        
    }
    @IBAction func SkipForwardSong(sender: AnyObject) {
        print("next song button pressed")
        
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        skipSongs = true;
        TrackListPosition=TrackListPosition+1;
        if(TrackListPosition < userPlaylistTrackStrings.count)
        {
            let tmpString = userPlaylistTrackStrings[TrackListPosition].trackID
            let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
            print(userPlaylistTrackStrings[TrackListPosition].title)
            //player!.setIsPlaying(false, callback: nil)
            //player!.stop(nil)
            player!.playURI(formattedTrackName, callback: { error -> Void in
                if error == nil {
                    self.skipSongs = false;
                    return
                }
            })
        }

        //debug
        //self.addSongtoPlaylist("1UfBAJfmofTffrae5ls6DA") //fairytale
        
        //player?.skipNext(nil)
        //skipSongs = false;
    }
    
    @IBAction func SkipBackSong(sender: AnyObject) {
        print("back song button pressed")
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        skipSongs = true;
        TrackListPosition=TrackListPosition-1;
        if(TrackListPosition >= 0)
        {
            let tmpString = userPlaylistTrackStrings[TrackListPosition].trackID
            let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
            //player!.setIsPlaying(false, callback: nil)
            //player!.stop(nil)

            player!.playURI(formattedTrackName, callback: { error -> Void in
                if error == nil {
                    self.skipSongs = false;
                    return
                }
            })
        }

        //debug
        //self.addSongtoPlaylist("1UfBAJfmofTffrae5ls6DA") //fairytale
        
        //player?.skipPrevious(nil)
        //skipSongs = false;
    }
    
    func addSongtoPlaylist(trackID: String)
    {
        // var userPlaylistTrackStrings = [NSURL]()
        
        print("song added to playlist!")
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        
        let formattedTrackName = NSURL(string: "spotify:track:"+trackID);
        print(formattedTrackName)
        
        //userPlaylistTrackStrings.append(formattedTrackName!)
        //userPlaylistTrackStrings.append(formattedTrackName!)
        
        
        //player?.queueURI(formattedTrackName, callback: nil)
        //player?.replaceURIs(userPlaylistTrackStrings, withCurrentTrack: (player?.currentTrackIndex)!, callback: nil)
        
        
        //self.player?.queueURI(<#T##uri: NSURL!##NSURL!#>, callback: <#T##SPTErrorableOperationCallback!##SPTErrorableOperationCallback!##(NSError!) -> Void#>)
        
    }
    
    
    
    func audioStreaming(player: SPTAudioStreamingController, didStopPlayingTrack uri: NSURL) {
        print("track ended" )
        if(pausePressed == false){
            print(skipSongs)
            if(skipSongs == false){
                print("fuck life")
                TrackListPosition=TrackListPosition+1;
            if(TrackListPosition < userPlaylistTrackStrings.count)
            {
                print("audio streaming next song")
                let tmpString = userPlaylistTrackStrings[TrackListPosition].trackID
                let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
                player.playURI(formattedTrackName, callback: nil)
            }
            }
        }
    }
    
    func updateSession() {

        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {
            let sessionDataObj = sessionObj as! NSData
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            
            //playUsingSession(firstTimeSession)
            session = firstTimeSession
            
        }
    }
    
    
    
    func playUsingSession(sessionObj:SPTSession) {
        print("playing using session called")
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            player?.playbackDelegate = self;
            
        }
        player?.loginWithSession(sessionObj, callback: { (error:NSError!) -> Void in
            if error != nil {
                print("enabling playback got error")
                return
            }
            //SPTRequest.requestItemAtURI(<#T##uri: NSURL!##NSURL!#>, withSession: <#T##SPTSession!#>, callback: <#T##SPTRequestCallback!##SPTRequestCallback!##(NSError!, AnyObject!) -> Void#>)
            //SPTTrack.trackWithURI(<#T##uri: NSURL!##NSURL!#>, session: <#T##SPTSession!#>, callback: <#T##SPTRequestCallback!##SPTRequestCallback!##(NSError!, AnyObject!) -> Void#>)
            
            //self.addSongtoPlaylist("3KUs7BeZGMze6HDDdFlb7j") //loveland
            //self.addSongtoPlaylist("24w8CSNGN34hYPCrjdRLob") //fairytale
            
            SPTTrack.trackWithURI(NSURL(string: "spotify:track:3f9zqUnrnIq0LANhmnaF0V"), session: sessionObj, callback: { (error:NSError!, trackObj:AnyObject!) -> Void in
                if error != nil {
                    print("track lookup got error")
                    return
                }
                //let track = trackObj as! SPTTrack
                //self.player?.playTrackProvider(track, callback: nil)
                print("song will play lol")
                //self.player?.playURI(NSURL(string: "spotify:track:4gqgQQHynn86YrJ9dEuMfc"), callback: nil)
                //player?.playURI(NSURL(string: "spotify:track:4gqgQQHynn86YrJ9dEuMfc"), callback: nil)
                
                //player?.playURIs(userPlaylistTrackStrings, fromIndex: 0, callback: nil)
                //player?.playURI(
                
                
                //player?.queuePlay(nil)
                
                
                //self.player?.play
                //self.player?.playURI(<#T##uri: NSURL!##NSURL!#>, callback: <#T##SPTErrorableOperationCallback!##SPTErrorableOperationCallback!##(NSError!) -> Void#>)
            })
            /*
            SPTRequest.requestItemAtURI(NSURL(string: "spotfiy:track:3f9zqUnrnIq0LANhmnaF0V"), withSession: sessionObj, callback: { (error:NSError!, albumObj:AnyObject!) -> Void in
            if error != nil {
            print("album lookup got error")
            return
            }
            let album = albumObj as! SPTAlbum
            self.player?.playTrackProvider(album, callback: nil)
            })*/
            
        })
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel?.text = streamName
        
        /*if (firstLoad == true) {
            appDelegate.client?.addListener(self)
            clnt = appDelegate.client
            firstLoad = false
        } */
        
        appDelegate.client?.addListener(self)

        
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        
        self.listenersView.registerNib(nib, forCellWithReuseIdentifier: "reuseIdentifier")
        
        /* Table Setup delegates */
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Return the number of sections
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items in the section
        return listenersPic.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseIdentifier", forIndexPath: indexPath) as! CollectionViewCell
        
        let url : NSURL = NSURL(string : listenersPic[indexPath.row])!
        let data : NSData = NSData(contentsOfURL: url)!
        
        cell.imageView.image = UIImage(data: data);
        
        return cell
    }
    
    
    /** End the stream */
    @IBAction func endStream(sender: AnyObject) {
        let hostedStream = defaults.stringForKey("hostedStream")
        
        if (hostedStream != nil) {
            
            // delete the stream object in the database
            let uri : String = "http://ec2-54-183-142-37.us-west-1.compute.amazonaws.com/api/streams/" + hostedStream!
            let headers : [String: String] = ["x-access-token": FBSDKAccessToken.currentAccessToken().tokenString]
            
            Alamofire.request(.DELETE, uri, headers:headers)
                .responseJSON { json in
                    
                    let deletedStream = JSON(data: json.data!)
                    
                    print (deletedStream)
                    
                    // Do not proceed if server did not respond
                    if (deletedStream == nil) {
                        print("No response from server or stream does not exist.")
                        return
                    }
                    
                    // delete the value for the hostedStream key
                    defaults.setObject(nil, forKey: "hostedStream")
                    
                    print("Deleted hosted stream.")
            }
            
            // unsubscribe from pubnub
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let targetChannel = appDelegate.client?.channels().last {
                print("unsubscribed from " + (targetChannel as! String))
                appDelegate.client?.unsubscribeFromChannels([targetChannel as! String], withPresence: true)
            }
            
            print(appDelegate.client?.channels())
            
            // go back to home after delete
            dismissViewControllerAnimated(true, completion: nil)
        }
            
        // the user is not in a stream
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    //TABLE VIEW:
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userPlaylistTrackStrings.count
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            player?.playbackDelegate = self;
            print("no player")
        }
        if(firstPlay == true)
        {
            print("first play")
            updateSession()
            playUsingSession(session)
            //player?.playURI(userPlaylistTrackStrings[0], callback: nil)
            //let tmpString = userPlaylistTrackStrings[0].trackID
            //let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
            //player?.playURI(formattedTrackName, callback: nil)
            //isPlaying = true;
            firstPlay = false
        }
        
        
        skipSongs = true
        let row = indexPath.row
        
        
        //player!.stop(nil)
        isPlaying = false;
        TrackListPosition = row
        
        
        let tmpString = userPlaylistTrackStrings[row].trackID //as! String
        print(userPlaylistTrackStrings[row].title)
        let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
        print("x")
        player?.playURI(formattedTrackName, callback: { error -> Void in
            if error == nil {
                self.skipSongs = false;
                return
            }
        })
        print("y")
        //skipSongs = false
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell?
        
        if (cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        if(userPlaylistTrackStrings.count > 0){
            cell!.textLabel?.text = userPlaylistTrackStrings[indexPath.row].title
            cell!.detailTextLabel?.text = userPlaylistTrackStrings[indexPath.row].artist + " - " + userPlaylistTrackStrings[indexPath.row].album
        }

        return cell!
    }
    
    
    
    
    
    
    /************************** PUBNUB FUNCTIONS ************************/
     
    /* Received a message */
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
        print("Received message: \(message.data.message) on channel " +
            "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
            "\(message.data.timetoken)")
        
        // If we receive a picture object
        if let pictureObject = message.data.message["pictureObject"] {
            if (pictureObject != nil) {
                
                // create the pic object
                let url = pictureObject["picURL"] as! String
                
                // we don't want to add a picture we already have
                if (listenersPic.contains(url)) {
                    return;
                }
                
                // add the picture to host's listenersPic array
                listenersPic.append(url);
                
                
                // construct the message to send (pictures of all current listeners)
                let listenersObject: [String: [String]] = [
                    "listenersObject": listenersPic
                ]
                
                listenersView.reloadData()
      
                
                // publish the pictures
                let targetChannel =  appDelegate.client?.channels().last as! String
                appDelegate.client!.publish(listenersObject, toChannel: targetChannel, compressed: false, withCompletion: { (status) -> Void in })

            }
        }
        
        // If we received a leave request with the user's picture, remove the picture from the listenerspic array
        if let leaveRequest = message.data.message["leaveRequest"] {
            if (leaveRequest != nil) {
                let urlToRemove = leaveRequest as! String;
                listenersPic = listenersPic.filter() { $0 != urlToRemove}
                
                let listenersObject: [String: [String]] = [
                    "listenersObject": listenersPic
                ]
                
                listenersView.reloadData()
                
                // publish updated pictures
                let targetChannel =  appDelegate.client?.channels().last as! String
                appDelegate.client!.publish(listenersObject, toChannel: targetChannel, compressed: false, withCompletion: { (status) -> Void in })
            }
        }
        
        
        // If we received a song, add it to the playlist and publish it
        if let songObject = message.data.message["songObject"] {
            if (songObject != nil) {
                
                // create the song object
                let song = Song()
                song.title = songObject["title"] as! String
                song.album = songObject["album"] as! String
                song.artist = songObject["artist"] as! String
                song.trackID = songObject["trackID"] as! String
                
                // add the song to the playlist
                userPlaylistTrackStrings.append(song)
                
                var playlist: [AnyObject] = []
                if (!self.serializedPlaylist.isEmpty) {
                    serializedPlaylist.append(song.toSerializableData())
                    playlist = serializedPlaylist
                }
                    
                else {
                    // construct the playlist
                    for (var i = 0; i < userPlaylistTrackStrings.count; i++) {
                        playlist.append(userPlaylistTrackStrings[i].toSerializableData())
                    }
                    serializedPlaylist = playlist
                }
                
                // construct the message to send
                let playlistObject: [String: [AnyObject]] = [
                    "playlistObject": playlist
                ]
                
                // publish the playlist
                let targetChannel =  appDelegate.client?.channels().last as! String
                appDelegate.client!.publish(playlistObject, toChannel: targetChannel, compressed: false, withCompletion: { (status) -> Void in })
                
                self.tableView.reloadData()
            }
        }
        
        
        
        
        // If the host user receives a request from a joined user, send the playlist
        if let joinRequest = message.data.message["joinRequest"] {
            if (joinRequest != nil) {
                
                print("A USER JOINED THE STREAM. REQUESTED PLAYLIST")
                
                var playlist: [AnyObject] = []
                if (!self.serializedPlaylist.isEmpty) {
                    playlist = serializedPlaylist
                }
                    
                else {
                    // construct the playlist
                    for (var i = 0; i < userPlaylistTrackStrings.count; i++) {
                        playlist.append(userPlaylistTrackStrings[i].toSerializableData())
                    }
                    serializedPlaylist = playlist
                }
                
                // construct the message to send
                let playlistObject: [String: [AnyObject]] = [
                    "playlistObject": playlist
                ]
                
                // publish the playlist
                let targetChannel =  appDelegate.client?.channels().last as! String
                appDelegate.client!.publish(playlistObject, toChannel: targetChannel, compressed: false, withCompletion: { (status) -> Void in })
            }
        }
        else {
            print("nooo")
        }
        self.tableView.reloadData()
        
        print("Received message: \(message.data.message) on channel " +
            "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
            "\(message.data.timetoken)")
    }
    
    // New presence event handling.
    func client(client: PubNub!, didReceivePresenceEvent event: PNPresenceEventResult!) {
        
        // Handle presence event event.data.presenceEvent (one of: join, leave, timeout,
        // state-change).
        if event.data.actualChannel != nil {
            
            // Presence event has been received on channel group stored in
            // event.data.subscribedChannel
        }
        else {
            
            // Presence event has been received on channel stored in
            // event.data.subscribedChannel
        }
        
        
        if event.data.presenceEvent != "state-change" {
            
            /*let targetChannel = client.channels().last as! String
            
            //let uuid : String = (self.client?.uuid())!
            let uuid: String = client.uuid()
            
            
            /*let pictureObject : [String : [String : String]] = ["picObject" : ["url" : defaults.stringForKey("userPicURL")! , "uuid" : uuid]] */
            
            var userPicture = UserPicture();
            userPicture.picURL = defaults.stringForKey("userPicURL")!
            userPicture.name = defaults.stringForKey("userName")!
            
            // construct picture object
            let pictureObject : [String : AnyObject] = [
                "pictureObject" : userPicture.toSerializableData()
            ]
            
            
            client.publish(pictureObject, toChannel: targetChannel,
                compressed: false, withCompletion: { (status) -> Void in
            }) */
            
            
            print("\(event.data.presence.uuid) \"\(event.data.presenceEvent)'ed\"\n" +
                "at: \(event.data.presence.timetoken) " +
                "on \((event.data.actualChannel ?? event.data.subscribedChannel)!) " +
                "(Occupancy: \(event.data.presence.occupancy))");
        }
        else {
            
            print("\(event.data.presence.uuid) changed state at: " +
                "\(event.data.presence.timetoken) " +
                "on \((event.data.actualChannel ?? event.data.subscribedChannel)!) to:\n" +
                "\(event.data.presence.state)");
        }
    }
    
    
    // Handle subscription status change.
    
    // Handle subscription status change.
    func client(client: PubNub!, didReceiveStatus status: PNStatus!) {
        
        if status.category == .PNUnexpectedDisconnectCategory {
            
            // This event happens when radio / connectivity is lost
        }
        else if status.category == .PNConnectedCategory {
            
            // Connect event. You can do stuff like publish, and know you'll get it.
            // Or just use the connected event to confirm you are subscribed for
            // UI / internal notifications, etc
            
            // Select last object from list of channels and send message to it.
            /*    let targetChannel = client.channels().last as! String
            client.publish("Hello from the PubNub Swift SDK", toChannel: targetChannel,
            compressed: false, withCompletion: { (status) -> Void in
            
            if !status.error {
            
            // Message successfully published to specified channel.
            }
            else{
            
            // Handle message publish error. Check 'category' property
            // to find out possible reason because of which request did
            ail.
            // Review 'errorData' property (which has PNErrorData data type) of status
            // object to get additional information about issue.
            //
            // Request can be resent using: status.retry()
            }
            })
            } */
            
            let targetChannel = client.channels().last as! String
            
            // construct picture object
            let pictureObject : [String : [String : String]] = [
                "pictureObject" : ["picURL" : defaults.stringForKey("userPicURL")! as String]
            ]
            
            
            client.publish(pictureObject, toChannel: targetChannel,
            compressed: false, withCompletion: { (status) -> Void in
            })
            
        }
        else if status.category == .PNReconnectedCategory {
            
            // Happens as part of our regular operation. This event happens when
            // radio / connectivity is lost, then regained.
        }
        else if status.category == .PNDecryptionErrorCategory {
            
            // Handle messsage decryption error. Probably client configured to
            // encrypt messages and on live data feed it received plain text.
        }
    }
    
    /************************ END PUBNUB FUNCTIONS ****************************/
    

}
